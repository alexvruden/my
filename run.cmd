@echo off
chcp 1251 > nul
setlocal EnableDelayedExpansion
set /a mode_con_cols = 160
set /a mode_con_lines= 50
set /a srv_trigger=0
set /a term_trigger=0
set /a param_trigger=1
set /a strategy_trigger=0
set /a ecode=0
set /a ccall=0
set /a rand=0
set "home=%~dp0"
set /a homestrsize=0
set "home=%home:~0,-1%"
set "homenc=%home%"
for %%i in ("%home%") do set "home=%%~si"
for /L %%i in (1000,-1,1) do (
	if not "x!home:~%%i,1!"=="x" (
		set /a homestrsize=%%i + 2
		goto:@break_homestrsize
	)
)
:@break_homestrsize
if not exist %home%\script\run_agent.cmd (
	echo.
	echo.[5GЗапуск из архива без распаковки невозможен. 
	echo.
	echo.[5GНажмите любую клавишу для выхода.
	pause >nul
	exit
)
set "fakedir="
set /a profile_count=0
set "arg_1=%~1"
set "arg_2=%~2"
set "arg_3=%~3"
net session >nul 2>&1
if %errorLevel% neq 0 ( 
	echo.
	echo.[5GДля некоторых действий сценария необходимы высокие привилегии, запустите скрипт с правами 'Администратора'.
	echo.
	echo.[5GНажмите любую клавишу для выхода.
	pause >nul
	exit
)
if not exist %home%\run.config (
	(
	echo.# Generate from script. Do not edit this config
	echo.
	echo.show_popup=off
	echo.
	echo.check_update=on
	echo.new_version_available=
	echo.
	echo.daemon=on
	echo.custom_strategy=off
	echo.IPsetStatus=off
	echo.
	echo.# params for agent
	echo.
	echo.ip_router=
	echo.agent_mode=start
	echo.agent_start_strategy=none
	echo.agent_start_params=100
	)>%home%\run.config
)
set "foo="
schtasks /Query /TN dpiagent /FO CSV /V | find "%home%" 1>nul 2>&1
if %errorLevel% neq 0 (
	schtasks /End /TN dpiagent 1>nul 2>&1
	schtasks /Delete /TN dpiagent /F 1>nul 2>&1
	if !errorlevel! EQU 0 (
		if exist %home%\script\run_agent.cmd (
			schtasks /Create /F /TN dpiagent /NP /RU "SYSTEM" /SC ONSTART /TR "%home%\script\run_agent.cmd %home%" 1>nul 2>&1
			if !errorlevel! EQU 0 schtasks /Run /TN dpiagent 1>nul 2>&1
		)
	)
)
for /F "skip=1 eol=# tokens=1,2 delims==" %%a in (%home%\run.config) do set %%~a=%%~b
set foo=%%a
set foo=!foo: =!
if not "x!foo!"=="x" (
	set /a aoo=0
	for %%i in (show_popup new_version_available check_update daemon custom_strategy IPsetStatus ip_router agent_mode agent_start_strategy agent_start_params) do (
		if "x%%i"=="x!foo!" set /a aoo=1
		<nul set /p =.
	)
	if !aoo! equ 1 (
		set goo=%%b
		if not "x!foo!"=="xagent_start_strategy" (
			set goo=!goo: =!
		)
		set !foo!=!goo!
	)
)
set "foo=Есть обновление."
set /a goo=255
for /L %%c in (255,-1,0) do if "x!foo:~%%c,1!"=="x" set /a goo-=1
set /a goo=64-%goo%
for /L %%c in (1,1,%goo%) do set "foo=!foo! "
set "foo=%foo%https://github.com/alexvruden/my/releases"
if "x%show_popup%"=="xon" if "x%new_version_available%"=="xtrue" powershell -Command "[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$objNotifyIcon=New-Object System.Windows.Forms.NotifyIcon;$objNotifyIcon.BalloonTipText='%foo%';$objNotifyIcon.Icon=[system.drawing.systemicons]::Information;$objNotifyIcon.BalloonTipTitle='Bypassing Censorship';$objNotifyIcon.BalloonTipIcon='None';$objNotifyIcon.Visible=$True;$objNotifyIcon.ShowBalloonTip(5000);" 
mode con: cols=%mode_con_cols% lines=%mode_con_lines%
powershell -command "&{$H=Get-Host;$W=$H.UI.RawUI;$B=$W.BufferSize;$B.Width=%mode_con_cols%;$B.Height=9999;$W.BufferSize=$B;}" 1>nul 2>&1
set "arch="
set "archd="
for /f "tokens=2 delims=:" %%i in ('2^>nul powershell -Command "Get-CimInstance Win32_operatingsystem | select OSArchitecture | Format-List -Property *"') do set archd=%%i
set archd=%archd: =%
if "x%archd:~0,2%"=="x32" ( set "arch=windows-x86" ) else ( set "arch=windows-x86_64" )
set archd=%archd:~0,2%
set "foo="
set "winwsdir="
for /f "delims=" %%I in ('2^>nul dir /b /s /a:d %home%\bin\%arch%') do set "winwsdir=%%~I"
if defined winwsdir (
	if not exist %winwsdir%\winws.exe (
		set "winwsdir="
	) else (
		for /f "delims=" %%I in ('%winwsdir%\winws.exe --version') do set "foo=%%I"
	)
	set "fakedir=!winwsdir:~0,-24!\files\fake"
)
rem bol-van: автоматическое включение tcp timestamps в windows, которые отключены по умолчанию
netsh interface tcp set global timestamps=enabled 1>nul 2>&1
echo.]0;[Bypassing Censorship] WinWS: %foo%\
echo.[39;49m
echo.[7l
echo.[?12l
echo.[?25l
cls
echo.[5G[2mПроверка обновлений.[0m
call:check_update
echo.[5G[2mПроверка стратегий.[0m
cd /d %home%\strategy
for /f "delims=" %%i in ('2^>nul dir /b *.zip') do (
	if not exist %%~ni (
		tar -h 1>nul 2>&1
		if !errorlevel! equ 0 (
			tar -xf "%%~i" 1>nul 2>&1
		) else (
			powershell -command "Expand-Archive -Path '%%~i' -DestinationPath '.' -Force" 1>nul 2>&1
		)
	)
)
cd /d %home%
:menu
cls
for /f %%i in ('2^>nul powershell -command "$h=get-host;$h.ui.rawui.windowsize.width"') do set mode_con_cols_W=%%i
for /f %%i in ('2^>nul powershell -command "$h=get-host;$h.ui.rawui.BufferSize.width"') do set mode_con_cols_B=%%i
if %mode_con_cols_W% neq %mode_con_cols_B% (
	mode con: cols=%mode_con_cols_B% lines=%mode_con_lines% >nul
	powershell -command "&{$H=Get-Host;$W=$H.UI.RawUI;$B=$W.BufferSize;$B.Width=%mode_con_cols%;$B.Height=9999;$W.BufferSize=$B;}" 1>nul 2>&1
)
set "mode_con_cols=%mode_con_cols_B: =%"
set /a c1=5
set /a c2=9
set /a c3=13
set /a c4=30
set /a c5=55
set /a c6=80
set /a c7=100
set /a c8=%mode_con_cols% - 10
echo.[5G[2mОбновление меню каждые 60 сек.[0m
set /a srv_menu_count=1000
set /a strategy_menu_count=1000
set /a parameter_menu_count=1000
set /a agent_work=1000
set /a terminate_count=1000
set /a blockcheck_menu_count=1000
set /a find_strategy_menu_count=1000
set /a menu_choice=1000
if not exist %winwsdir%\winws.exe (
	echo.[5G[31mДля работы скрипта скачать новую версию драйверов и извлечь в директорию '[33m%homenc%\bin\[31m' [0m
)
<nul set /p =[5GСекундочку
if "x%new_version_available%"=="xtrue" echo.[5G[92mЕсть обновление.[0m
set "winws_pid="
set /a socks5=0
set /a found_winws=0
for /f "tokens=1,2 delims=," %%a in ('2^>nul tasklist /FI "IMAGENAME eq winws.exe" /fo csv /nh') do (
	if "x%%~a"=="xwinws.exe" (
		set /a found_winws+=1
		set "winws_pid!found_winws!=%%~b"
		<nul set /p =.
	)
)
set "strategy_run="
set /a profile_count=0
set "commandline="
set "daemon_status="
if %found_winws% GTR 0 ( 
	for /l %%m in (1,1,%found_winws%) do (
		for /f "tokens=* delims=" %%a in ('2^>nul powershell -Command "Get-WmiObject win32_process -Filter 'ProcessId ^= !winws_pid%%m!' | select commandline | Format-List -Property *"') do (
			set "rtg=%%a"
			set "rtg=!rtg:~14!"
			set "commandline=!commandline!!rtg!"
			<nul set /p =.
		)
		set "commandline%%m=!commandline!"
		set "commandline="
	)
	for /l %%m in (1,1,%found_winws%) do (
		for /f "tokens=2-6 delims=[]" %%a in ("!commandline%%m!") do (
			set /a profile_count+=1
			set "n!profile_count!=%%~a"
			set "custom_str=%%~b"
			set "ip!profile_count!=%%~c"
			set "pr!profile_count!=%%~d"
			set "pid!profile_count!=!winws_pid%%m!"
			set "daemon_status=%%~e"
			<nul set /p =.
		)
	)
	
)
echo.
echo.[1F[2K
set /a about_profile_strsize=%c8%-%c4%
set /a check_restart_str=0
if %profile_count% GTR 0 ( 
	for /l %%i in (1,1,%profile_count%) do (
		if %%i EQU 1 (
			for /l %%x in (%c1%,1,%c8%) do <nul set /p =(0[%%xGq(B
			echo.
			if not "x%daemon_status%"=="x%daemon%" set /a check_restart_str+=1
			if not "x%custom_str%"=="x%custom_strategy%" set /a check_restart_str+=1
			if not "x%ip1%"=="x%IPsetStatus%" set /a check_restart_str+=1
			if !check_restart_str! neq 0 (
				echo.
				echo.[%c1%G[31mПараметры изменены. [%c4%GДля применения новых параметров перезапустите стратегию[0m
				echo.
			)
			echo.[%c1%GРаботает стратегия:[%c4%G[0m!n%%i!
			echo.
			if "x!daemon_status!"=="xon" ( set "offon=да" ) else ( set "offon=нет" )
			echo.[%c4%G[33mЗапуск в скрытом окне[0m: !offon!
			if "x!custom_str!"=="xon" ( set "offon=да" ) else ( set "offon=нет" )
			echo.[%c4%G[33mЗапуск 'custom' стратегий[0m: !offon!
			if "x!ip%%i!"=="xon" ( set "offon=да" ) else ( set "offon=нет" )
			echo.[%c4%G[33mИспользовать список IP[0m: !offon!
			set /a foo=%c4%
			set /a foo=!foo! - 1
			for /l %%x in (1,1,!foo!) do <nul set /p =[%%xG[8m(0q(B[0m
			for /l %%x in (%c4%,1,%c8%) do <nul set /p =(0[%%xGq(B
			echo.
		)
		set "about_profile=!pr%%i!"
		echo.[%c1%GPID: !pid%%i![%c4%G[36m!about_profile:~0,%about_profile_strsize%![0m
	)
	for /l %%x in (%c1%,1,%c8%) do <nul set /p =(0[%%xGq(B
	echo.
	set "strategy_run=!n1!" 
) else (
	if %found_winws% gtr 0 (
		echo.[%c1%G[31mОбнаружен неизвестный процесс 'winws'[0m
		for /l %%x in (%c1%,1,%c8%) do <nul set /p =(0[%%xGq(B
		echo.
	)
)
if "x%arg_1%"=="xstart" (
	if "x%arg_2%"=="x" ( 
		set "strategy_name=%agent_start_strategy%" 
	) else ( 
		set "strategy_name=%arg_2%" 
	)
	for %%i in ("%home%\strategy\!strategy_name!") do set "foo=%%~sni"
	set "strategy_apath=%home%\strategy\!foo!"
	goto:terminate
)
if "x%arg_1%"=="xstop" (
	goto:terminate
)
set /a menu_count=1
set /a find_strategy_menu_count=!menu_count!
set "foo="
if defined count_strategy set "foo=[[32mпауза[0m]"
echo.[%c1%G[37m!menu_count!.[%c2%GПоиск стратегий[0m %foo%
if exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh (
	set /a menu_count+=1
	set /a blockcheck_menu_count=!menu_count!
	echo.[%c1%G[37m!menu_count!.[%c2%GBlockcheck[0m
)
set /a foo=%c1%-1
set "a1="
if %param_trigger% equ 0 ( set "a1=[..]" ) else ( echo. )
echo.[%foo%G[33m%a1%[%c2%G[33mПара[93mм[33mетры запуска стратегии[0m
if %param_trigger% neq 0 (
	echo.
	set /a foo=7
	if "x%daemon%"=="xon" ( 
		set /a foo=2
		set "offon=да " 
	) else ( 
		set /a foo=1
		set "offon=нет" 
	)
	set /a menu_count+=1
	set /a parameter_menu_count=!menu_count!
	echo.[%c1%G[37m!menu_count!.[%c2%GЗапуск в скрытом окне[%c5%G[[3!foo!m!offon![0m]
	set /a menu_count+=1
	if "x%custom_strategy%"=="xon" (
		set /a foo=2
		set "offon=да " 
	) else ( 
		set /a foo=1
		set "offon=нет" 
	)
	echo.[%c1%G[37m!menu_count!.[%c2%GЗапуск 'custom' стратегий[%c5%G[[3!foo!m!offon![0m]
	set /a foo=7
	if "x%IPsetStatus%"=="xon" ( 
		set /a foo=2
		set "offon=да " 
	) else ( 
		set /a foo=1
		set "offon=нет" 
	)
	set /a menu_count+=1
	echo.[%c1%G[37m!menu_count!.[%c2%GИспользовать список IP[%c5%G[[3!foo!m!offon![0m]
	echo.
)
rem ------------------------------------------------------------------------------------
set /a foo=%c1%-1
set /a about_strategy_strsize=%c8%-%c5%
if %strategy_trigger% equ 0 (
	echo.[%foo%G[33m[..][%c2%G[93mС[33mтратегии[0m
) else ( 
	echo.[%c2%G[93mС[33mтратегии[%c5%GОписание[0m
	echo.
	set "strategy_count_name="
	set "strategy_name_spath="
	set /a foo=0
	for /f "delims=" %%I in ('2^>nul dir /b /a:d %home%\strategy\') do (
		set /a fexist=0
		set "sfoo="
		for %%m in ("%home%\strategy\%%~I") do set "sfoo=%%~sm"
		if not "x!sfoo!"=="x" (
			for /f "delims=" %%a in ('2^>nul dir /x /b "!sfoo!\*.strategy"') do set /a fexist=1
			if !fexist! neq 0 (
				if not exist !sfoo!\about echo.нет описания>!sfoo!\about
				if not exist !sfoo!\custom md !sfoo!\custom 1>nul 2>&1
				if not exist !sfoo!\skip md !sfoo!\skip 1>nul 2>&1
				set /p about_strategy=<!sfoo!\about
				set /a menu_count+=1
				if !strategy_menu_count! equ 1000 set /a strategy_menu_count=!menu_count!
				if "x!strategy_run!"=="x%%~I" (
					set /a c0=%c1% - 2
					echo.[!c0!G[32m^>[%c1%G[37m!menu_count!.[%c2%G[32m%%~I [%c5%G[36m!about_strategy:~0,%about_strategy_strsize%![0m
				) else ( 	
					echo.[%c1%G[37m!menu_count!.[%c2%G%%~I [%c5%G[36m!about_strategy:~0,%about_strategy_strsize%![0m
				) 
				set "strategy_count_name!menu_count!=%%~I"
				set "strategy_name_spath!menu_count!=!sfoo!"
				set /a foo=1
			)
		)
	)
	if !foo! equ 0 ( 
		echo.[%c2%G[31mСтратегии не найдены. [0m
		echo.[%c2%GДобавьте файлы стратегий в папку '[33m%homenc%\strategy\[0m'
	) 
	echo.
)
rem ------------------------------------------------------------------------------------
set /a task=100
schtasks /Query /TN dpiagent 1>nul 2>&1
if %errorlevel% EQU 0 set /a task=0
set /a foo=%c1%-1
set "a1="
if %srv_trigger% equ 0 set "a1=[..]"
echo.[%foo%G[33m%a1%[%c2%G[93mА[33mвтоматизация[0m
if %srv_trigger% neq 0 ( 
	set /a srv_menu_count=%menu_count%+1
	if %task% EQU 0 (
		powershell -Command "Get-WmiObject win32_process -Filter 'name = \"cmd.exe\"' | select commandline" |find "run_agent.cmd" 1>nul 2>&1
		if !errorlevel! EQU 0 (
			if exist %home%\agent.log (
			 	for /f "delims=" %%i in (%home%\agent.log) do set "foo=%%i"			
			) else set "foo=.........неизвестное состояние..."
			echo.[%c3%GАгент : [32mвключен[0m
			echo.[%c3%GСтатус: [33m!foo:~9![0m
			set /a agent_work=1
		) else (
			echo.[%c3%GАгент : [31mвыключен[0m
			set /a agent_work=0
		)
		if !agent_work! equ 1 (
			if not "x!agent_mode!"=="xstart" (
				set /a menu_count+=1
				echo.[%c2%G[37m!menu_count!.[%c3%GОтправить агенту сигнал '[32mстарт[37m'[0m
			)
			if not "x!agent_mode!"=="xstop" (
				set /a menu_count+=1
				echo.[%c2%G[37m!menu_count!.[%c3%GОтправить агенту сигнал '[31mстоп[37m'[0m
			)
			set /a menu_count+=1
			echo.[%c2%G[37m!menu_count!.[%c3%G[33mОстановить агента[0m
		) else (
			set /a menu_count+=1
			echo.[%c2%G[37m!menu_count!.[%c3%G[33mЗапуск агента[0m
		)
		set /a menu_count+=1
		echo.[%c2%G[37m!menu_count!.[%c3%G[31mУдалить автоматизацию[0m
	) else (
		echo.[%c2%G[36m[[0m задача в планировщике заданий: [31mотсутствует[%c8%G[36m][0m
		if defined strategy_run (
			set /a menu_count+=1
			echo.[%c2%G[37m!menu_count!.[%c3%G[32mУстановить автоматизацию[0m
		) else (
			echo.[%c2%G[33mДля создания задачи в планировщике заданий запустите стратегию[0m
		)
	)
	echo.
)
rem ------------------------------------------------------------------------------------
set /a about_kill_strsize=%c8%-%c3%
if defined strategy_run (
	set /a menu_count+=1
	set /a terminate_count=!menu_count!
	echo.[%c1%G[37m!menu_count!.[%c2%G[33mЗав[93mе[33mршить мульти-стратегию '[0m!strategy_run![33m'[0m
	if %term_trigger% neq 0 ( 
		echo.[%c2%G[33mили отдельные профили ниже:
		for /l %%i in (1,1,%profile_count%) do (
			set /a menu_count+=1
			set "about_profile_kill=!pr%%i!"
			echo.[%c2%G[37m!menu_count!.[36m[%c3%G !about_profile_kill:~0,%about_kill_strsize%! [0m
		)
	)
)
echo.
echo.[%c1%G0.[%c2%GВыход
for /l %%x in (%c1%,1,%c8%) do <nul set /p =(0[%%xGq(B
echo.
echo.[?25l
:@choice_gtr_menu_count
set "str1choice=0123456789rcсafфаetеуmьvм"
REM cс		- 'С'тратегии
REM afфа	- 'А'втоматизация
REM etеу	- Зав'е'ршить стратегию
REM mьvм	- Пара'м'етры
set /a first_digit=1000
<nul set /p "=7#: "
choice /N /C:%str1choice% /D r /T 60 /M "#:" 1>nul 2>&1
if %errorlevel% EQU 255 call:cerror 421
if %errorlevel% EQU 0 call:cerror 422
set /a _errorlevel=%errorlevel%
set /a first_digit=%_errorlevel% - 1
set "first_digit_char="
for /l %%i in (0,1,50) do (
	if %first_digit% neq 1000 (
		if "x!str1choice:~%%i,1!"=="x!str1choice:~%first_digit%,1!" (
			set first_digit_char=!str1choice:~%%i,1!
			goto:@break435
		)
	)
)
:@break435
REM if %_errorlevel% GEQ 26 goto:...
if %_errorlevel% geq 22 goto:param_trigger
if %_errorlevel% GEQ 18 goto:terminate_trigger
if %_errorlevel% GEQ 14 goto:srv_menu_trigger
if %_errorlevel% GEQ 12 goto:strategy_trigger
if %_errorlevel% EQU 11 goto:menu
set "str2choice=0123456789z"
set /a second_digit=1000
set "second_digit_char="
<nul set /p "=8#: %first_digit_char%"
choice /N /C:0123456789z /D z /T 3 /M "#:" 1>nul 2>&1
if %errorlevel% EQU 255 call:cerror 440
if %errorlevel% EQU 0 call:cerror 441
if %errorlevel% EQU 11 (
	set /a menu_choice=%first_digit%
) else (
	set /a second_digit=%errorlevel% - 1
	set /a menu_choice=%first_digit% * 10 + !second_digit!
)
for /l %%i in (0,1,50) do (
	if %second_digit% neq 1000 (
		if "x!str2choice:~%%i,1!"=="x!str2choice:~%second_digit%,1!" (
			set second_digit_char=!str2choice:~%%i,1!
			goto:@break462
		)
	)
)
:@break462
<nul set /p "=8#: %first_digit_char%%second_digit_char%"
timeout /T 1 /NOBREAK >nul
if %menu_choice% gtr %menu_count% (
	<nul set /p =8[2K
	goto:@choice_gtr_menu_count
)
REM <nul set /p =8[2E
echo.
echo.
if %menu_choice% equ 0 goto:menu_0
if %find_strategy_menu_count% neq 1000 if %menu_choice% equ %find_strategy_menu_count% goto:find_strategy
if %blockcheck_menu_count% neq 1000 if %menu_choice% equ %blockcheck_menu_count% goto:blockcheck
if %terminate_count% neq 1000 if %menu_choice% geq %terminate_count% goto:terminate
if %srv_menu_count% neq 1000 if %menu_choice% geq %srv_menu_count% goto:menu_srv
if %strategy_menu_count% neq 1000 if %menu_choice% geq %strategy_menu_count% goto:strategy_choice
if %parameter_menu_count% neq 1000 if %menu_choice% geq %parameter_menu_count% (
	set /a foo=%menu_choice% - %parameter_menu_count% + 1
	goto:menu_!foo!
)
goto:menu
:strategy_choice
if "x!strategy_count_name%menu_choice%!"=="x" goto:menu
set "strategy_name=!strategy_count_name%menu_choice%!"
set "strategy_apath=!strategy_name_spath%menu_choice%!"
:strategy_list
if "x%strategy_name%"=="x" (
	echo.strategy_name=none
	echo.[5GНажмите любую клавишу для возврата в меню.
	pause >nul
	goto:menu
)
:terminate
if not defined strategy_run (
	call:check_kill
	goto:@terminate_done
)
if "x%arg_1%"=="xstart" goto:@terminate_all
if "x%arg_1%"=="xstop" goto:@terminate_all
if %menu_choice% neq 1000 if %menu_choice% EQU %terminate_count% goto:@terminate_all
if %menu_choice% neq 1000 if %menu_choice% GTR %terminate_count% goto:@terminate_one
:@terminate_all
call:cecho x3 "Завершаем работу стратегии" "'%strategy_run%'"
for /l %%i in (1,1,%profile_count%) do (
	if "x!n%%i!"=="x%strategy_run%" (
		powershell -NoP -sta -NonI -Command "Stop-Process -Id !pid%%i! -Force" 1>nul 2>&1
	)
)
call:check_kill
set "strategy_run="
if "x%arg_1%"=="xstart" goto:@terminate_done
if "x%arg_1%"=="xstop" goto:@terminate_done
if %menu_choice% neq 1000 if %menu_choice% EQU %terminate_count% (
	call:cecho 2 "Готово"
	echo.
	for /l %%x in (5,-1,1) do (
		echo.[F
		<nul set /p =[5G[37mВозврат в меню через [32m%%x[37m с.[0m
		timeout /T 1 /NOBREAK >nul
	)
	goto:menu
)
if %menu_choice% neq 1000 if %menu_choice% EQU %blockcheck_menu_count% goto:@terminate_done
if %menu_choice% neq 1000 if %menu_choice% LSS %terminate_count% goto:@terminate_done
:@terminate_one
set /a cpofile=%menu_choice%-%terminate_count%
call:cecho x3x "Завершаем работу профиля стратегии" "'%strategy_run%'" "[!pr%cpofile%!]"
powershell -NoP -sta -NonI -Command "Stop-Process -Id !pid%cpofile%! -Force" 1>nul 2>&1
call:cecho 2 "Готово"
echo.
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p =[5G[37mВозврат в меню через [32m%%x[37m с.[0m
	timeout /T 1 /NOBREAK >nul
)
goto:menu
:@terminate_done
sc qc windivert 1>nul 2>&1
if %errorlevel% EQU 0 (
	sc stop windivert 1>nul 2>&1
	sc delete windivert 1>nul 2>&1
)
if "x%arg_1%"=="xstop" exit
if %menu_choice% neq 1000 if %menu_choice% EQU %blockcheck_menu_count% goto:blockcheck

if not defined winwsdir (
	for /f "delims=" %%I in ('2^>nul dir /b /s /a:d %home%\bin\%arch%') do set "winwsdir=%%~I"
)
if not exist %winwsdir%\cygwin1.dll (
	echo.
	echo.[5G[37mДля работы скрипта скачать новую версию драйверов и извлечь в директорию '[33m%homenc%\bin\[37m' [0m
	echo.
	echo.[5GСкачать:
	echo.[5Ghttps://github.com/bol-van/zapret/releases
	echo.
	echo.[5GНажмите любую клавишу для возврата в меню.
	pause >nul
	goto:menu
)
if not exist %winwsdir%\winws.exe (
	echo.
	echo.[5G[31mНе найден[0m файл [33m'%homenc%\!winwsdir:~%homestrsize%!\winws.exe'[0m.
	goto:@txtmess
) 
if not exist %winwsdir%\WinDivert.dll (
	echo.
	echo.[5G[31mНе найден[0m файл [33m'%homenc%\!winwsdir:~%homestrsize%!\WinDivert.dll'[0m.
	goto:@txtmess
)
if not exist %winwsdir%\WinDivert%archd%.sys (
	echo.
	echo.[5G[31mНе найден[0m файл [33m'%homenc%\!winwsdir:~%homestrsize%!\WinDivert%archd%.sys'[0m.
	goto:@txtmess
)
goto:@skiptxtmess
:@txtmess
echo.
echo.[5GВероятно Ваш антивирус счёл его опасным и поместил в карантин. 
echo.
echo.[5G[31mПРЕДУПРЕЖДЕНИЕ[0m : ВОЗМОЖНА ЭВРИСТИЧЕСКАЯ РЕАКЦИЯ АНТИВИРУСОВ НА [33mUPX[0m И [33mWINDIVERT[0m. 
echo.[5G[33mWINDIVERT[0m - хакерский инструмент, потенциально нежелательное ПО, потенциально часть вируса, но сам по себе - не вирус. 
echo.[5G[33mUPX[0m - не троян, а компрессор исполняемых файлов. 
echo.
echo.[5G[32mВирусов и майнеров здесь нет.[0m
echo.
echo.[5GДобавьте директорию в '[33m%homenc%[0m' исключения антивируса.
echo.
echo.[5GНажмите любую клавишу для возврата в меню.
pause >nul
goto:menu
:@skiptxtmess
set "fakedir=%winwsdir:~0,-24%\files\fake"
if exist %strategy_apath%\about set /p about_strategy=<%strategy_apath%\about
if not exist %strategy_apath%\log md %strategy_apath%\log >nul
del /F /Q %strategy_apath%\log\* >nul
rem set "zapret_hosts_user_exclude=--hostlist-exclude=%winwsdir:~0,-24%\ipset\zapret-hosts-user-exclude.txt.default"
set "zapret_hosts_user_exclude="
rem set "zapret_hosts_user_exclude=%zapret_hosts_user_exclude% --ipset-exclude=%winwsdir:~0,-24%\ipset\zapret-hosts-user-exclude.txt.default"
if not exist %home%\lists\exclude md %home%\lists\exclude >nul
if not exist %home%\lists\exclude\exclude-hosts.txt echo.#>%home%\lists\exclude\exclude-hosts.txt
for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\exclude\*.txt %home%\lists\exclude\*.lst %home%\lists\exclude\*.gz') do (
	set "zapret_hosts_user_exclude=!zapret_hosts_user_exclude! --hostlist-exclude=%home%\lists\exclude\%%X"
)
set "daemon_bakup=%daemon%"
set "custom_strategy_bakup=%custom_strategy%"
set "IPsetStatus_bakup=%IPsetStatus%"
if not defined arg_3 goto:@arg_3_default
if "x%arg_3:~0,1%"=="x0" (
	set "daemon=off"
) else (
	if "x%arg_3:~0,1%"=="x1" (
		set "daemon=on"
	) else goto:@error_arg3
)
if "x%arg_3:~1,1%"=="x0" (
	set "custom_strategy=off"
) else (
	if "x%arg_3:~1,1%"=="x1" (
		set "custom_strategy=on"
	) else goto:@error_arg3
)
if "x%arg_3:~2,1%"=="x0" (
	set "IPsetStatus=off"
) else (
	if "x%arg_3:~2,1%"=="x1" (
		set "IPsetStatus=on"
	) else goto:@error_arg3
)
:@arg_3_default
call:cecho x3 "Парсинг параметров, см." "%homenc%\strategy\%strategy_name%\log\"
set /a pcount=0
set /a scount=0
call:parse_str "%strategy_apath%" "%homenc%\strategy\%strategy_name%"
if "x%custom_strategy%"=="xon" (
	if not exist %strategy_apath%\custom md %strategy_apath%\custom >nul
	call:parse_str "%strategy_apath%\custom" "%homenc%\strategy\%strategy_name%\custom"
)
if %pcount% equ 0 goto:@nulpcount
call:cecho x3 "Создано профилей:" "'%scount%'"
for /f "delims=" %%I in ('%winwsdir%\winws.exe --version') do set "foo=%%I"
set foo=%foo:(=[%
set foo=%foo:)=]%
call:cecho x3x "Windivert" "'%foo%'" "initialized"
set /a scount=0
if %pcount% neq 0 call:cecho x3 "Запуск" "'%strategy_name%'"
set "name_strategy_file_parse_ok_tmp="
for /l %%i in (1,1,%pcount%) do (
	set "wsdebug="
	set "wsdaemon="
	set "wscomment="
	set "wsarg=!winws_arg%%i!"
	set /a scount=%%i
	if "x%debug%"=="xon" set wsdebug=--debug=1
	if "x%daemon%"=="xon" set wsdaemon=--daemon
	set "sabout=x"
	if exist %strategy_apath%\log\"!name_strategy_file_parse_ok%%i!"-about.log set /p sabout=<%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-about.log"
	set wscomment=--comment [%strategy_name%][%custom_strategy%][%IPsetStatus%][!sabout!][%daemon%]
	%winwsdir%\winws.exe --dry-run !wsdebug! !wsdaemon! !wscomment! !wsarg! 2>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-dry-run-status-err.log" 1>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-dry-run-status.log"
	if !errorlevel! neq 0 (
		call:cecho 1x3 "Ошибка." "Подробности смотри в" "'%homenc%\strategy\%strategy_name%\log\!name_strategy_file_parse_ok%%i!-dry-run-status-err.log"
		set /a ecode=1
		goto:strategy_list_end
	)
	%winwsdir%\winws.exe --wf-save="%strategy_apath%\log\!name_strategy_file_parse_ok%%i!-save.raw" !wsarg! 2>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-wf-save-status-err.log" 1>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-wf-save-status.log"
	if "x%daemon%"=="xoff" (
		echo.start "[!sabout!] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] %winwsdir%\winws.exe !wsdebug! !wscomment! !wsarg! >>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-cmd.bat.example"
		start "[!sabout!] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] %winwsdir%\winws.exe !wsdebug! !wscomment! !wsarg!
	)
	if "x%daemon%"=="xon" (
		echo.%winwsdir%\winws.exe !wsdebug! !wsdaemon! !wscomment! !wsarg! >>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-cmd.bat.example"
		%winwsdir%\winws.exe !wsdebug! !wsdaemon! !wscomment! !wsarg! 2>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-status-err.log" 1>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-status.log"
		if !errorlevel! neq 0 (
			call:cecho 1x3 "Ошибка." "Подробности смотри в" "'%homenc%\strategy\%strategy_name%\log\!name_strategy_file_parse_ok%%i!-run-status-err.log"
			set /a ecode=1
			goto:strategy_list_end
		)
	)
	call:cecho x6x2 "!name_strategy_for_cecho%%i! :" "[!sabout!]" "-" "ok"
)
:@nulpcount
if %pcount% neq 0 ( 
	call:cecho 2 "Готово" 
	set /a ecode=0
) else (
	call:cecho 1 "Отсутствуют параметры стратегии" 
	set /a ecode=1
)
:strategy_list_end
if "x%arg_1%"=="xstart" (
	set "daemon=%daemon_bakup%"
	set "custom_strategy=%custom_strategy_bakup%"
	set "IPsetStatus=%IPsetStatus_bakup%"
	exit %ecode%
)
if %pcount% equ 0 goto:strategy_list_exit
set /a foo=0
if "x%daemon%"=="xon" set /a foo+=100
if "x%custom_strategy%"=="xon" set /a foo+=10
if "x%IPsetStatus%"=="xon" set /a foo+=1
set agent_start_strategy=%strategy_name%
set /a agent_start_params=%foo%
call:sconfig
:strategy_list_exit
echo.
echo.[%c3%GНажмите любую клавишу для возврата в меню.
pause >nul
goto:menu
:@error_arg3
set /a ecode=1
echo.[5G[31mНеверный аргумент #3: [37m'[33m%arg_3%[37m'[0m]
goto:strategy_list_end
:strategy_trigger
if %strategy_trigger% equ 0 ( set /a strategy_trigger=1 ) else ( set /a strategy_trigger=0 )
goto:menu
:srv_menu_trigger
if %srv_trigger% equ 0 ( set /a srv_trigger=1 ) else ( set /a srv_trigger=0 )
goto:menu
:terminate_trigger
if %term_trigger% equ 0 ( set /a term_trigger=1 ) else ( set /a term_trigger=0 )
goto:menu
:param_trigger
if %param_trigger% equ 0 ( set /a param_trigger=1 ) else ( set /a param_trigger=0 )
goto:menu
:menu_0
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p =[5G[37mВыход через [32m%%x[37m с.[0m
	timeout /T 1 /NOBREAK >nul
)
exit /b %ecode%

:menu_1
set "debug=%debug%"
if "x%daemon%"=="xon" ( 
	set "daemon=off" 
	set "debug=on" 
) else ( 
	set "daemon=on"
	set "debug=off"
)
call:sconfig
goto:menu

:menu_2
set /a foo=0
set "foob="
set "fooe="
if "x%custom_strategy%"=="xon" (
	set "custom_strategy=off"
) else (
	set "custom_strategy=on"
)
call:sconfig
goto:menu

:menu_3
if "x%IPsetStatus%"=="xon" (
	set "IPsetStatus=off"
) else ( 
	set "IPsetStatus=on"
)
call:sconfig
goto:menu

:cerror
echo.
echo.[5G[31mОшибка.[0m Line #%~1
echo.[5GНажмите любую клавишу для выхода.
pause >nul
goto:menu_0

:blockcheck
echo.
call:blockcheck_create_cfg
if not exist %home%\bin\zapret-win-bundle-master\cygwin\bin\bash.exe (
	echo.[5G[31mОшибка. [37mФайл не найден: '[33m%homenc%\bin\zapret-win-bundle-master\cygwin\bin\bash[37m'[0m
	goto:@err_blockcheck
)
if not exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh (
	echo.[5G[31mОшибка. [37mФайл не найден: '[33m%homenc%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh[37m'[0m
:@err_blockcheck
	echo.
	echo.[5G[37mЕсли хотите использовать '[33mblockcheck[0m' то нужно его скачать и извлечь в директорию '[33m%homenc%\bin\[37m': [0m
	echo.
	echo.[5Ghttps://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip
	echo.
	echo.[5GНажмите любую клавишу для возврата в меню.
	pause >nul
	goto:menu
)
call:check_kill
echo.[5GПауза.
echo.[5G[37mОтредактируйте/Добавьте в '[33m%homenc%\blockcheck.config.txt[37m' параметры для сканирования.[0m
echo.
echo.[5GЕсли отредактировали, то нажмите любую клавишу для продолжения.
pause >nul
if exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\config del /f /q %home%\bin\zapret-win-bundle-master\blockcheck\zapret\config 1>nul 2>&1
rem CRLF to LF
rem ----------------- http://stackoverflow.com/a/6379861/1012053
(set LF=^
%=EMPTY=%
)
for /F "delims=" %%a in (%home%\blockcheck.config.txt) do (
	<nul set /p =%%a!LF!>>%home%\bin\zapret-win-bundle-master\blockcheck\zapret\config
)
rem ----------------- http://stackoverflow.com/a/6379861/1012053

start %home%\bin\zapret-win-bundle-master\cygwin\bin\bash -i "%home%\bin\zapret-win-bundle-master\blockcheck\zapret\blog.sh"
echo.
echo.[5G[37mОтчет работы сохраняется в файл '[33m%homenc%\bin\zapret-win-bundle-master\blockcheck\blockcheck.log[37m'[0m
(
echo.@echo off
echo.:loop
echo.cls
echo.more /e /p /s %home%\bin\zapret-win-bundle-master\blockcheck\blockcheck.log
echo.echo.
echo.pause
echo.goto:loop
)>%home%\blockcheck.log.cmd
echo.[5G[37mПосмотреть отчет можно с помощью '[33m%homenc%\blockcheck.log.cmd[37m'[0m
echo.
echo.[5GНажмите любую клавишу для возврата в меню.
pause >nul
goto:menu

:menu_srv
if not exist %home%\script\run_agent.cmd (
	echo.[5G[31mОтсутствует файл[0m '[33m%homenc%\script\run_agent.cmd[0m'
	echo.[5GНажмите любую клавишу для возврата в меню.
	pause >nul
	goto:menu
)
set /a caenable=1000
set /a cadisable=1000
set /a castart=1000
set /a castop=1000
set /a cadel=1000
if %agent_work% equ 1 (
	if not "x%agent_mode%"=="xstart" set /a castart=0
	if not "x%agent_mode%"=="xstop" set /a castop=0
	set /a cadisable=1
	set /a cadel=2
)
if %agent_work% equ 0 (
	set /a caenable=0
	set /a cadel=1
)
schtasks /Query /TN dpiagent 1>nul 2>&1
if %errorlevel% EQU 0 (
	set /a foo=%menu_choice% - %srv_menu_count%
	if !foo! equ !castart! (
		set "agent_mode=start"
		echo.[5G[37mСигнал '[32mstart[0m' отправлен
		call:sconfig
	) else if !foo! equ !castop! (
		set "agent_mode=stop"
		echo.[5G[37mСигнал '[31mstop[0m' отправлен
		call:sconfig
	) else if !foo! equ !caenable! (
		schtasks /Run /TN dpiagent 1>nul 2>&1
		if !errorlevel! EQU 0 (
			echo.[5G[32mЗадача запущена.[0m
		) else echo.[5G[31mОшибка запуска задачи[0m
	) else if !foo! equ !cadisable! (
		schtasks /End /TN dpiagent 1>nul 2>&1
		if !errorlevel! EQU 0 (
			echo.[5G[32mЗадача остановлена.[0m
		) else echo.[5G[31mОшибка остановки задачи[0m
	) else if !foo! equ !cadel! (
		schtasks /End /TN dpiagent 1>nul 2>&1
		schtasks /Delete /TN dpiagent /F 1>nul 2>&1
		if !errorlevel! EQU 0 (
			if "x%show_popup%"=="xon" (
				powershell -Command "[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$objNotifyIcon=New-Object System.Windows.Forms.NotifyIcon;$objNotifyIcon.BalloonTipText='Задача удалена.';$objNotifyIcon.Icon=[system.drawing.systemicons]::Information;$objNotifyIcon.BalloonTipTitle='Bypassing Censorship';$objNotifyIcon.BalloonTipIcon='None';$objNotifyIcon.Visible=$True;$objNotifyIcon.ShowBalloonTip(5000);"
			) else (
				echo.[5G[32mЗадача удалена.[0m
			)
		) else (
			echo.[5G[31mОшибка удаления задачи[0m
		)
	)
) else (
	set "agent_mode=start"
	call:sconfig
	if not exist %home%\agent.log echo.#>%home%\agent.log
	schtasks /Create /F /TN dpiagent /NP /RU "SYSTEM" /SC ONSTART /TR "%home%\script\run_agent.cmd %home%" 1>nul 2>&1
	if !errorlevel! EQU 0 (
		if "x%show_popup%"=="xon" (
			powershell -Command "[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$objNotifyIcon=New-Object System.Windows.Forms.NotifyIcon;$objNotifyIcon.BalloonTipText='Задача создана.';$objNotifyIcon.Icon=[system.drawing.systemicons]::Information;$objNotifyIcon.BalloonTipTitle='Bypassing Censorship';$objNotifyIcon.BalloonTipIcon='None';$objNotifyIcon.Visible=$True;$objNotifyIcon.ShowBalloonTip(5000);"
			schtasks /Run /TN dpiagent 1>nul 2>&1
		) else (
			echo.
			echo.[5G[32mЗадача создана.[0m
			schtasks /Run /TN dpiagent 1>nul 2>&1
			if !errorlevel! EQU 0 (
				echo.[5G[32mЗадача запущена.[0m
			) else echo.[5G[31mОшибка запуска задачи[0m
		)
	) else (
		echo.[5G[31mОшибка создания задачи[0m
	)
)
:@menu_srv_end
echo.
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p =[5G[37mВозврат в меню через [32m%%x[37m с.[0m
	timeout /T 1 /NOBREAK >nul
)
goto:menu

:cecho
set "curtime=%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%"
set "curtime=%curtime: =0%"
set bitmask=%~1
for /L %%a in (0,1,8) do (
	set /a bmloc = %%a + 2
	if not "x!bitmask:~%%a,1!"=="x" set "bm!bmloc!=3!bitmask:~%%a,1!"
	if "x!bitmask:~%%a,1!"=="xx" set "bm!bmloc!=0"
)
<nul set /p =[%curtime%][%c3%G
if not "x%~2"=="x" <nul set /p = [%bm2%m%~2
if not "x%~3"=="x" <nul set /p = [%bm3%m %~3
if not "x%~4"=="x" <nul set /p = [%bm4%m %~4
if not "x%~5"=="x" <nul set /p = [%bm5%m %~5
if not "x%~6"=="x" <nul set /p = [%bm6%m %~6
if not "x%~7"=="x" <nul set /p = [%bm7%m %~7
if not "x%~8"=="x" <nul set /p = [%bm8%m %~8
if not "x%~9"=="x" <nul set /p = [%bm9%m %~9
echo.[0m
exit /b

:sconfig
(
echo.# Generate from script. Do not edit this config
echo.
echo.show_popup=%show_popup%
echo.
echo.check_update=%check_update%
echo.new_version_available=%new_version_available%
echo.
echo.daemon=%daemon%
echo.custom_strategy=%custom_strategy%
echo.IPsetStatus=%IPsetStatus%
echo.
echo.# params for agent
echo.
echo.ip_router=%ip_router%
echo.agent_mode=%agent_mode%
echo.agent_start_strategy=%agent_start_strategy%
echo.agent_start_params=%agent_start_params%
)>%home%\run.config
exit /b

:check_update
rem https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28
REM curl -L \
  REM -H "Accept: application/vnd.github+json" \
  REM https://api.github.com/repos/OWNER/REPO/releases
set /a updated=20250802
if not defined check_update set check_update=on
if not "x%check_update%"=="xon" exit /b 0
set foo=0
set "_curl=curl"
%_curl% -V 1>nul 2>&1
if %errorlevel% equ 0 set foo=1
if %foo% equ 0 (
	set "_curl="
	if exist %home%\curl.exe (
		set "_curl=%home%\curl.exe"
	) else if exist %home%\bin\curl.exe (
		set "_curl=%home%\bin\curl.exe"
	)
	if not "x!_curl!"=="x" set foo=1
)
if %foo% equ 0 exit /b 1
for /f "tokens=2 delims=:" %%a in ('2^>nul %_curl% --max-time 2 -sH "Accept: application/vnd.github+json" https://api.github.com/repos/alexvruden/my/releases/latest ^|findstr "updated_at"') do (
	set new_updated=%%a
	goto:@break_new_updated
)
:@break_new_updated
if defined new_updated (
	set new_updated=!new_updated:"=!
	set new_updated=!new_updated:,=!
	set new_updated=!new_updated: =!
	set new_updated=!new_updated:~0,10!
	set new_updated=!new_updated:-=!
	if %updated% lss !new_updated! (
		set "new_version_available=true" 
	) else ( 
		set "new_version_available=false" 
	)
)
call:sconfig
exit /b 0

:parse_str
set "parse_str_strategy_apath=%~1"
set "str_file_path_for_cecho=%~2"
for /f "delims=" %%I in ('2^>nul dir /b %parse_str_strategy_apath%\*.strategy') do (
	set "skip_profile=off"
	set "skip_WinDivert=off"
	set "profile_param= "
	set "tmp_profile_param= "
	set "sabout="
	set /a parse_mayok=0
	set "psabout="
	set "sWinDivert="
	for %%a in ("%parse_str_strategy_apath%\%%~I") do set "foo=%%~sa"
	for /F "skip=1 eol=# tokens=1* delims==" %%M in (!foo!) do (
		set "fletter=%%~M"
		set "fletter=!fletter: =!"
		set /a parse_desync = 0
		if "x!fletter:~0,1!"=="x$" (
			set "foo=%%~M"
			if not "x!foo:~1!"=="x" set "psabout=!foo:~1!"
		) else (
			if "x!fletter!"=="xHOSTLIST" (
				if not exist %home%\lists\hostlist\hostlist-auto.txt echo.#>%home%\lists\hostlist\hostlist-auto.txt
				for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\hostlist\*.txt %home%\lists\hostlist\*.lst %home%\lists\hostlist\*.gz') do (
					set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%X"
				)
				set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\hostlist-auto.txt"
				set /a parse_mayok=1
				
			) else if "x!fletter!"=="xHOSTLIST_NOAUTO" (
				if not exist %home%\lists\hostlist\hostlist-auto.txt echo.#>%home%\lists\hostlist\hostlist-auto.txt
				for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\hostlist\*.txt %home%\lists\hostlist\*.lst %home%\lists\hostlist\*.gz') do (
					set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%X"
				)
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--hostlist-auto" (
				if "x%%~N"=="x" (
					if not exist %home%\lists\hostlist\hostlist-auto.txt echo.#>%home%\lists\hostlist\hostlist-auto.txt
					set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\hostlist-auto.txt"
				) else (
					if not exist %home%\lists\hostlist\%%~N echo.#>%home%\lists\hostlist\%%~N
					set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\%%~N"
				)
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--hostlist" (
				if "x%%~N"=="x" (
					set /a foo = 0
					for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\hostlist\*.txt %home%\lists\hostlist\*.lst %home%\lists\hostlist\*.gz') do (
						set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%X"
						set /a foo = 1
					)
					if !foo! equ 0 (
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'%homenc%\lists\hostlist\*'"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
					)				
				) else (
					if exist %home%\lists\hostlist\%%~N (
						set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%~N"
					) else (
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'%homenc%\lists\hostlist\%%~N'"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%~N" "отброшен"	
					)
				)
				set /a parse_mayok=1
			) else if "x!fletter!"=="xIPSET" (
					if "x%IPsetStatus%"=="xon" (
						set /a foo = 0
						for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\ipset\*.txt %home%\lists\ipset\*.lst %home%\lists\ipset\*.gz') do (
							set "profile_param=!profile_param! --ipset=%home%\lists\ipset\%%~X"
							set /a foo = 1
						)
						if !foo! equ 0 (
							call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'%homenc%\lists\ipset\*'"
							call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "IPSET" "отброшен"	
						)				
					) else (
						set "skip_profile=on"
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinWS фильтр" "'Использовать список IP: нет'"
					)
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--ipset" (
				if "x%%~N"=="x" (
					if "x%IPsetStatus%"=="xon" (
						set /a foo = 0
						for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\ipset\*.txt %home%\lists\ipset\*.lst %home%\lists\ipset\*.gz') do (
							set "profile_param=!profile_param! --ipset=%home%\lists\ipset\%%~X"
							set /a foo = 1
						)
						if !foo! equ 0 (
							call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'%homenc%\lists\ipset\*'"
							call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						)				
					) else (
						set "skip_profile=on"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinWS фильтр --ipset" "'Использовать список IP: нет'"
					)
				) else (
					if "x%IPsetStatus%"=="xon" (
						if exist %home%\lists\ipset\%%~N (
							set "profile_param=!profile_param! --ipset=%home%\lists\ipset\%%~N"
						) else (
							call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'%homenc%\lists\ipset\%%~N'"
							call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%~N" "отброшен"	
						)
					) else (
						set "skip_profile=on"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" x"Исключен" "WinWS фильтр --ipset" "'Использовать список IP: нет'"
					)
				)
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--wf-raw" (
				set "LN=%%N"
				if "x!LN:~0,1!"=="x@" (
					if exist %parse_str_strategy_apath%\!LN:~1! (
						set sWinDivert=--wf-raw=@%parse_str_strategy_apath%\!LN:~1!
					) else (
						set "skip_WinDivert=on"
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'%homenc%\strategy\%strategy_name%\!LN:~1!'"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
					)
				) else (
						set "skip_WinDivert=on"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						call:cecho x1x "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinDivert фильтр --wf-raw"
				)
				if "x!sabout!"=="x" (
					if "x!psabout!"=="x" ( set "sabout=!sWinDivert:~5!" ) else ( set "sabout=!psabout!" )
				) else (
					if "x!psabout!"=="x" ( set "sabout=!sabout! !sWinDivert:~5!" ) else ( set "sabout=!sabout! !psabout!" )
				)
				set "LN="
				set "psabout="
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--wf-tcp" (
				if "x%%~N"=="x" (
					set "skip_WinDivert=on"
					call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
					call:cecho x1x "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinDivert фильтр --wf-tcp"
				) else set sWinDivert=--wf-tcp=%%~N
				if "x!sabout!"=="x" (
					if "x!psabout!"=="x" ( set "sabout=!sWinDivert:~5!" ) else ( set "sabout=!psabout!" )
				) else (
					if "x!psabout!"=="x" ( set "sabout=!sabout! !sWinDivert:~5!" ) else ( set "sabout=!sabout! !psabout!" )
				)
				set "psabout="
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--wf-udp" (
				if "x%%~N"=="x" (
					set "skip_WinDivert=on"
					call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
					call:cecho x1x "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinDivert фильтр --wf-udp"
				) else set sWinDivert=--wf-udp=%%~N
				if "x!sabout!"=="x" (
					if "x!psabout!"=="x" ( set "sabout=!sWinDivert:~5!" ) else ( set "sabout=!psabout!" )
				) else (
					if "x!psabout!"=="x" ( set "sabout=!sabout! !sWinDivert:~5!" ) else ( set "sabout=!sabout! !psabout!" )
				)
				set "psabout="
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--filter-udp" (
				if "x%%~N"=="x" (
					set "skip_profile=on"
					call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
					call:cecho x1x "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinWS фильтр --filter-udp"
				) else set "profile_param=!profile_param! --filter-udp=%%~N"
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--filter-tcp" (
				if "x%%~N"=="x" (
					set "skip_profile=on"
					call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
					call:cecho x1x "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinWS фильтр --filter-udp"
				) else set "profile_param=!profile_param! --filter-tcp=%%~N"
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--dpi-desync-split-seqovl-pattern" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-split-seqovl-pattern" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fakedsplit-pattern" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-tls" (
				set "foo=%%~N"
				set "foo=!foo: =!"
				if "x!foo!"=="x" (
					set "profile_param=!profile_param! !fletter!=^!"
				) else set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-unknown" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-syndata" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-wireguard" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-dht" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-discord" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-stun" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-udplen-pattern" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-quic" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-unknown-udp" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--new" (
				if "x!skip_profile!"=="xoff" (
					set /a scount+=1
					if "x!tmp_profile_param!"=="x" ( 
						set "tmp_profile_param=!profile_param! %zapret_hosts_user_exclude%" 
					) else ( 
						set "tmp_profile_param=!tmp_profile_param! !profile_param! %zapret_hosts_user_exclude%" 
					)
					set "profile_param=--new"
					if "x!sabout!"=="x" ( 
						if not "x!psabout!"=="x" set "sabout=!psabout!" 
					) else ( 
						if not "x!psabout!"=="x" set "sabout=!sabout! !psabout!" 
					)
				) else (
					if "x%IPsetStatus%"=="xoff" call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinWS фильтр" "'Использовать список IP: нет'"
					set "profile_param= "
					set "skip_profile=off"
				)
				set "psabout=" 
				set /a parse_mayok=1
			) else if "x%%~N"=="x" (
				set "profile_param=!profile_param! %%~M"
				set /a parse_mayok=1
			) else (
				set "profile_param=!profile_param! %%~M=%%~N"
				set /a parse_mayok=1
			)
			if !parse_desync! equ 1 (
				set "foo=%%~N"
				set "foo=!foo: =!"
				if "x!foo:~0,2!"=="x0x" (
					set "profile_param=!profile_param! !fletter!=%%~N"
				) else (
					if exist %fakedir%\%%~N ( 
						set "profile_param=!profile_param! !fletter!=%fakedir%\%%~N"
					) else (
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'%homenc%\!fakedir:~%homestrsize%!\%%~N'"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%~N" "отброшен"	
					)
				)
				set /a parse_mayok=1
			)
		)
	)
	if !parse_mayok! equ 1 (
		if "x!skip_WinDivert!"=="xoff" (
			if "x!skip_profile!"=="xoff" (
				set /a scount+=1
				if "x!tmp_profile_param!"=="x" ( 
					set "tmp_profile_param=!profile_param! %zapret_hosts_user_exclude%" 
				) else (
					set "tmp_profile_param=!tmp_profile_param! !profile_param! %zapret_hosts_user_exclude%"
				)
				if "x!sabout!"=="x" ( 
					if not "x!psabout!"=="x" set "sabout=!psabout!" 
				) else ( 
					if not "x!psabout!"=="x" set "sabout=!sabout! !psabout!" 
				)
				set "psabout="
			) else (
				set "skip_profile=off"
			)
			if not "x!tmp_profile_param!"=="x " (
				set /a pcount+=1
				set "name_strategy_file_parse_ok!pcount!=%%~nI"
				set "name_strategy_for_cecho!pcount!=%str_file_path_for_cecho%\%%~I"
				set "winws_arg!pcount!=!sWinDivert! !tmp_profile_param!"
				if "x!sabout!"=="x" ( 
					set "sabout=no about" 
				)
				echo.!sabout!>>%strategy_apath%\log\"%%~nI-about.log"
			)
		)
	)
)
exit /b

:progress_in_percent_begin
if defined pinp goto:@progress_in_percent_begin_exit
set /a progress_in_percent_begin_max=%~1
set /a temp_percent_count=0
set /a pinp = 0
set /a percent_step = %progress_in_percent_begin_max% / 100
set /a pinp_count=1
if %percent_step% neq 0 (
	if %progress_in_percent_begin_max% geq 1000 (
		set "decimal=%progress_in_percent_begin_max:~2,2%"
	) else (
		set "decimal=%progress_in_percent_begin_max:~1,2%"
	)
	if !decimal! equ 0 set /a decimal=1
	set /a correction = 100 / !decimal!
	set /a foo=0
	for /L %%c in (0,1,99) do (
		set /a percent_step%%c=%percent_step%
		if !foo! equ !correction! (
			set /a percent_step%%c+=1
			set /a foo=0
		) else set /a foo+=1
	)
	goto:@progress_in_percent_begin_exit
)
set /a percent_step = %progress_in_percent_begin_max% / 10
set /a pinp_count=10
if %percent_step% neq 0 (
	set "decimal=%progress_in_percent_begin_max:~1,1%"
	if !decimal! equ 0 set /a decimal=1
	set /a correction = 100 / !decimal!
	set /a foo=0
	for /L %%c in (0,1,99) do (
		set /a percent_step%%c=%percent_step%
		if !foo! equ !correction! (
			set /a percent_step%%c+=1
			set /a foo=0
		) else set /a foo+=1
	)
	goto:@progress_in_percent_begin_exit
)
set /a percent_step=%progress_in_percent_begin_max%
set /a pinp_count=100 / %percent_step%
set /a foo=0
for /L %%c in (0,1,99) do set /a percent_step%%c=%percent_step%
:@progress_in_percent_begin_exit
exit /b

:progress_in_percent_count
set /a temp_percent_count+=1
if %pinp% lss 100 (
	if %temp_percent_count% equ !percent_step%pinp%! (
		set /a temp_percent_count=0
		set /a pinp+=%pinp_count%
	)
)
set /a %~1=%pinp%
exit /b

:check_run
for /L %%I in (1,1,10) do (
	powershell -NoP -sta -NonI -Command "Get-Process -Name 'winws'" 1>nul 2>nul
	if !errorlevel! equ 0 exit /b 0
)
exit /b 1

:check_kill
for /L %%I in (1,1,10) do (
	powershell -NoP -sta -NonI -Command "Get-Process -Name 'winws' | Stop-Process -Force" 1>nul 2>nul
	powershell -NoP -sta -NonI -Command "Get-Process -Name 'winws'" 1>nul 2>nul
	if !errorlevel! neq 0 (
		sc qc windivert 1>nul 2>nul
		if !errorlevel! equ 0 (
			sc stop windivert 1>nul 2>nul
			sc delete windivert 1>nul 2>nul
		)
		exit /b 0
	)
)
exit /b 1

:find_strategy
cls
set /a pos=10

if %pos% lss 4 set /a pos=4
set /a _pos=%pos%-4

if not defined winwsdir (
	echo.[%_pos%G[[33mi[0m][%pos%G[37mДля работы скрипта скачать новую версию драйверов и извлечь в директорию '[33m%homenc%\bin\[37m' [0m
	echo.
	echo.[%pos%G Скачать:
	echo.[%pos%G https://github.com/bol-van/zapret/releases
	echo.
	goto:@find_strategy_end
)
if not exist %winwsdir%\WinDivert.dll (
	echo.[%_pos%G[[31mx[0m][%pos%G[31mНе найден[0m файл [33m'%homenc%\!winwsdir:~%homestrsize%!\WinDivert.dll'[0m.
	goto:@find_strategy_txtmess
)
if not exist %winwsdir%\WinDivert%archd%.sys (
	echo.[%_pos%G[[31mx[0m][%pos%G[31mНе найден[0m файл [33m'%homenc%\!winwsdir:~%homestrsize%!\WinDivert%archd%.sys'[0m.
	goto:@find_strategy_txtmess
)
if defined count_strategy (
	call:check_kill
	echo.
	echo.
	echo.[%_pos%G[[33mi[0m][%pos%GПредыдущий поиск был завершён на позиции '[33m%count_strategy%[0m', продолжим поиск.
	set /a line_begin=%line_begin_mem%+%count_strategy%
	goto:@return_find
)
set /a find_strategy_found=0
set /a find_strategy_kill_error=0
set /a find_strategy_run_error=0
set "curl_ret_code=-"
set "curl_cmd_scan="
set /a ap2_old=0
if not exist %home%\strategy\strategy.lst (
	echo.[%_pos%G[[31mx[0m][%pos%G[31mОшибка.[0m Файл не найден: '[33m%homenc%\strategy\strategy.lst[0m'
	goto:@find_strategy_end
)
echo.[%pos%GУпрощенная версия '[33mblockcheck[0m' на основе списка стратегий[0m
echo.
echo.[%_pos%G[[33mi[0m][%pos%GЗавершим все 'winws' процессы[0m
call:check_kill
if %errorlevel% equ 0 (
	echo.[%_pos%G[[32m+[0m][%pos%GГотово[0m
)
if not exist %home%\blockcheck.config.txt (
	echo.[%_pos%G[[33mi[0m][%pos%GСоздание файла параметров '[33m%homenc%\blockcheck.config.txt[0m'
	call:blockcheck_create_cfg
) else echo.[%_pos%G[[33mi[0m][%pos%GЧитаем параметры '[33m%homenc%\blockcheck.config.txt[0m'
for /F "skip=1 eol=# tokens=1,2 delims==" %%a in (%home%\blockcheck.config.txt) do (
	set foo=%%a
	set foo=!foo: =!
	if not "x!foo!"=="x" (
		set /a aoo=0
		for %%i in (CURL CURL_MAX_TIME ENABLE_HTTP TTPS_TLS12 ENABLE_HTTPS_TLS13 ENABLE_HTTP3 REPEATS HTTP_PORT HTTPS_PORT QUIC_PORT DOMAINS) do (
			if "x%%i"=="x!foo!" set /a aoo=1
		)
		if !aoo! equ 1 (
			set goo=%%b
			if not "x!foo!"=="xDOMAINS" (
				set goo=!goo: =!
			)
			set !foo!=!goo!
		)
	)
)
echo.[%_pos%G[[33mi[0m][%pos%GПроверим параметры
if not defined DOMAINS set "DOMAINS=ntc.party"
set DOMAINSFULL=%DOMAINS%
set DOMAINSFULL=%DOMAINSFULL:"=%
set /a foo=0
for %%i in (%DOMAINSFULL%) do (
	set /a foo+=1
	if !foo! equ 1 set DOMAINS=%%i
)
if %foo% gtr 1 (
	echo.[%_pos%G[[31mx[0m][%pos%G[31mDOMAINS="%DOMAINSFULL%"[0m
	echo.[%_pos%G[[33mi[0m][%pos%GТолько один домен проверим
)
set DOMAINS=%DOMAINS: =%
set /a CURL_MAX_TIMEw=0
if defined CURL_MAX_TIME set /a CURL_MAX_TIMEw=%CURL_MAX_TIME%
if %CURL_MAX_TIMEw% equ 0 set "CURL_MAX_TIME=2"
if not defined CURL_MAX_TIME set "CURL_MAX_TIME=2"
if defined CURL_MAX_TIME echo.[%pos%G[36mCURL_MAX_TIME=%CURL_MAX_TIME%[0m
set "type_find="
if defined ENABLE_HTTP if "x%ENABLE_HTTP%"=="x1" (
	set "type_find=[HTTP]"
)
if defined ENABLE_HTTP3 if "x%ENABLE_HTTP3%"=="x1" (
	set "type_find=[HTTP3]"
)
if defined ENABLE_HTTPS_TLS12 if "x%ENABLE_HTTPS_TLS12%"=="x1" (
	set "type_find=[HTTPS]"
)
if defined ENABLE_HTTPS_TLS13 if "x%ENABLE_HTTPS_TLS13%"=="x1" (
	set "type_find=[HTTPS]"
)
if not defined type_find set "type_find=[HTTPS]"
set /a foo=0
if defined ENABLE_HTTP if "x%ENABLE_HTTP%"=="x1" set /a foo+=1
if defined ENABLE_HTTPS_TLS12 if "x%ENABLE_HTTPS_TLS12%"=="x1" set /a foo+=1
if defined ENABLE_HTTP3 if "x%ENABLE_HTTP3%"=="x1" set /a foo+=1
if %foo% geq 2 (
	echo.[%_pos%G[[31mx[0m][%pos%GСканируем что-то одно из HTTP, HTTPS, HTTP3[0m
	echo.[%_pos%G[[33mi[0m][%pos%GБудет выбрано сканирование HTTPS
	set "type_find=[HTTPS]"
)
if "x%type_find%"=="x[HTTP]" (
	if not defined HTTP_PORT set "HTTP_PORT=80"
	if defined HTTP_PORT echo.[%pos%G[36mHTTP_PORT=!HTTP_PORT![0m
)

if "x%type_find%"=="x[HTTP3]" (
	if not defined QUIC_PORT set "QUIC_PORT=443"
	if defined QUIC_PORT echo.[%pos%G[36mQUIC_PORT=!QUIC_PORT![0m
)
if "x%type_find%"=="x[HTTPS]" (
	if not defined HTTPS_PORT set "HTTPS_PORT=443"
	if defined HTTPS_PORT echo.[%pos%G[36mHTTPS_PORT=!HTTPS_PORT![0m
	if not defined ENABLE_HTTPS_TLS13 (
		set ENABLE_HTTPS_TLS13=0
	) else set ENABLE_HTTPS_TLS13=%ENABLE_HTTPS_TLS13%
	if not defined ENABLE_HTTPS_TLS12 (
		if "x!ENABLE_HTTPS_TLS13!"=="x0" set ENABLE_HTTPS_TLS12=1
	) else set ENABLE_HTTPS_TLS12=%ENABLE_HTTPS_TLS12%
	if "x!ENABLE_HTTPS_TLS13!"=="x1" (
		set "TLSver=--tlsv1.3"
		set "TLSmax="
	) else (
		set ENABLE_HTTPS_TLS12=1
		set "TLSver=--tlsv1.2"
		set "TLSmax=--tls-max 1.2"
	)
	if defined ENABLE_HTTPS_TLS12 echo.[%pos%G[36mENABLE_HTTPS_TLS12=!ENABLE_HTTPS_TLS12![0m
	if defined ENABLE_HTTPS_TLS13 echo.[%pos%G[36mENABLE_HTTPS_TLS13=!ENABLE_HTTPS_TLS13![0m
)
set /a REPEATSw=0
if defined REPEATS set /a REPEATSw=%REPEATS%
if %REPEATSw% equ 0 set "REPEATS=4"
if defined REPEATS echo.[%pos%G[36mREPEATS=%REPEATS%[0m
set "curl_version="
if defined CURL (
	if exist %home%\%CURL% (
		for /f "delims=" %%a in ('2^>nul %home%\%CURL% -V') do (
			set curl_version=%%a
			goto:@break_curl_1
		)
	)
)
:@break_curl_1
if "x!curl_version:~0,4!"=="xcurl" ( set "CURLw=%home%\%CURL%" ) else ( set "CURLw=curl" )
set "curl_version="
for /f "delims=" %%a in ('2^>nul %CURLw% -V') do (
	set curl_version=%%a
	goto:@break_curl_2
)
:@break_curl_2
if not "x!curl_version:~0,4!"=="xcurl" (
	echo.[%_pos%G[[31mx[0m][%pos%G[31mНе найден[0m 'cURL'
	echo.[%_pos%G[[33mi[0m][%pos%GДля поиска стратегий нужно скачать архив 'cURL' и извлечь файл '[33mcurl.exe[0m'в директорию '[33m%homenc%\bin\[37m' [0m
	echo.[%pos%GВ файле '[33m%homenc%\blockcheck.config.txt[0m' указать переменную '[36mCURL=bin\curl.exe[0m'
	echo.
	echo.[%pos%G Скачать :
	echo.[%pos%G https://curl.se/windows/
	echo.
	goto:@find_strategy_end
)
if defined CURL echo.[%pos%G[36mCURL=%CURL%[0m
set "CURL=%CURLw%"
set curl_version=%curl_version:(=%
set curl_version=%curl_version:)=%
for /f "tokens=2 delims= " %%a in ("%curl_version%") do set "foo=%%a"
echo.[%_pos%G[[32m+[0m][%pos%GНайден 'cURL' v.%foo%
set "foo="
set /a line_begin=1
set /a line_count=1
for /F "skip=%line_begin%" %%a in (%home%\strategy\strategy.lst) do (
	set /a line_count+=1
	set foo=%%a
	set foo=!foo: =!
	if !line_begin! neq 1 (
		if "x!foo:~0,1!"=="x[" goto:@break1622
	)
	if "x!foo!"=="x%type_find%" set /a line_begin=!line_count!
)
:@break1622
set /a total_strategy=0
for /F "skip=%line_begin%" %%a in (%home%\strategy\strategy.lst) do (
	set foo=%%a
	set foo=!foo: =!
	set comment_char=!foo:~0,1!
	if "x!comment_char!"=="x[" goto:@break1628
	REM if not "x!comment_char!"=="x#" set /a total_strategy+=1
	set /a total_strategy+=1
)
:@break1628
if %total_strategy% equ 0 (
	echo.[%_pos%G[[31mx[0m][%pos%GНет стратегий %type_find% в файле '[33m%homenc%\strategy\strategy.lst[0m'
	goto:@find_strategy_end
)
call:progress_in_percent_begin %total_strategy%
set /a ap2=0
echo.[%_pos%G[[33mi[0m][%pos%GПоиск IP для [33m%DOMAINS%[0m
set "_resolve="
for /f "delims=" %%a in ('2^>nul %CURL% --max-time 3 https://dns.google/resolve?name^=%DOMAINS%') do (
	set _resolve=%%a
)

if not defined _resolve (
	echo.[%_pos%G[[31mx[0m][%pos%G[31mGОшибка поиска IP[0m
	goto:@find_strategy_end
)
for /f "tokens=4 delims={}" %%k in ("%_resolve%") do (
	for /f "tokens=5 delims=:" %%a in ("%%~k") do set ip_dom=%%a
)
if not defined ip_dom (
	echo.[%_pos%G[[31mx[0m][%pos%G[31mОшибка обработки строки: [33m%_resolve%[0m
	goto:@find_strategy_end
)

set ip_dom=%ip_dom:"=%
set ip_dom=%ip_dom: =%
for /f "tokens=1 delims=:" %%i in ("%ip_dom%") do set "ip_dom=%%i"
echo.[%_pos%G[[32m+[0m][%pos%GНайден IP: [33m%ip_dom%[0m

set foo=0
set "curl_dns="
for /f %%a in ('2^>nul nslookup iana.org ^| find "192.0.43.8"') do set foo=1
if %foo% equ 1 (
    echo.[%_pos%G[[33mi[0m][%pos%GПроверка DNS пройдена
) else (
	echo.[%_pos%G[[31mx[0m][%pos%GОшибка DNS.
	echo.[%pos%GРекомендуется установить известные DNS-серверы и настроить DoH.
	rem echo.[%pos%GСкрипт будет использовать зашифрованный DNS CloudFlare.
	rem set curl_dns=--dns-servers "1.1.1.1:853"
)
if "x%type_find%"=="x[HTTPS]" (
	set curl_cmd_scan=%curl_dns% --connect-to %DOMAINS%::[%ip_dom%]:%HTTPS_PORT% -ISs -A Mozilla --max-time %CURL_MAX_TIME% %TLSver% %TLSmax% https://%DOMAINS%
	set _PORT=%HTTPS_PORT%
	set _HTTP=HTTPS
)
if "x%type_find%"=="x[HTTP3]" (
	set curl_cmd_scan=%curl_dns% --connect-to %DOMAINS%::[%ip_dom%]:%QUIC_PORT% -ISs -A Mozilla --max-time %CURL_MAX_TIME% --http3-only https://%DOMAINS%
	set _PORT=%QUIC_PORT%
	set _HTTP=QUIC
)
if "x%type_find%"=="x[HTTP]" (
	set curl_cmd_scan=%curl_dns% --connect-to %DOMAINS%::[%ip_dom%]:%HTTP_PORT% -SsD %home%\bin\blk-hdr.txt -A Mozilla --max-time %CURL_MAX_TIME% http://%DOMAINS%
	set _PORT=%HTTP_PORT%
	set _HTTP=HTTP
)
set "find_strategy_position_end="
for /f "delims=" %%I in ('2^>nul dir /b %home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.*') do set find_strategy_position_end=%%~xI
if not defined find_strategy_position_end (
	set /a find_strategy_position_end=0
) else (
	set find_strategy_position_end=!find_strategy_position_end:.=!
	set /a find_strategy_position_end=!find_strategy_position_end!
)
if %find_strategy_position_end% neq 0 (
	echo.[%_pos%G[[33mi[0m][%pos%GОбнаружен файл предыдущего поиска '[33m%homenc%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_end%[0m'
	echo.[%_pos%G[[33mi[0m][%pos%GПоиск был завершен на позиции '[33m%find_strategy_position_end%[0m', продолжим поиск.
)
if exist %home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_end% (
	for /F "skip=1" %%a in (%home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_end%) do set /a find_strategy_found+=1
)
if %find_strategy_position_end% geq %total_strategy% (
	echo.[%_pos%G[[31mx[0m][%pos%GНечего искать[0m
	goto:@find_strategy_end
)
set ext_old=%find_strategy_position_end%

rem ---------------------------------------------------------
set /a count_strategy=%find_strategy_position_end%
set /a foo=0
for /L %%c in (0,1,99) do (
	set /a foo+=!percent_step%%c!
	if %count_strategy% lss !foo! (
		set /a pinp = %%c
		goto:@break1724
	)
)
:@break1724
rem ---------------------------------------------------------
if exist %home%\strategy\error_%DOMAINS%-%_PORT%-%_HTTP%.log del /f /q %home%\strategy\error_%DOMAINS%-%_PORT%-%_HTTP%.log 1>nul 2>&1
set /a line_begin=%line_begin%+%count_strategy%
set /a line_count=%line_begin%
set /a line_begin_mem=%line_begin%

:@return_find
echo.
echo.[%pos%G[32mПоиск стратегии для [33m'%DOMAINS%'[0m [%ip_dom%][31m:%HTTPS_PORT%[0m
REM echo.
set "foo=| 0рогресс | 1екущий | 2сего | 3айдено | 4шибки запуска WinWS | 5шибки завершения WinWS | 6    Код ответа cURL      | 7EPEATS |"
set /a pos_table=%pos%-4
set /a pos_count=0
for /l %%x in (0,1,160) do (
	if "x!foo:~%%x,1!"=="x!pos_count!" (
		set /a pos!pos_count!=%pos_table%+%%x
		set /a pos_count+=1
	)
)
set "foo=0 Прогресс 1 Текущий 2 Всего 3 Найдено 4 Ошибки запуска WinWS 5 Ошибки завершения WinWS 6      Код ответа cURL      7 REPEATS 8"
set /a pos_count=0
for /l %%x in (0,1,160) do (
	if "x!foo:~%%x,1!"=="x!pos_count!" (
		set /a ipos!pos_count!=%pos_table%+%%x
		set /a pos_count+=1
	)
)
echo.
<nul set /p =(0
for /l %%x in (%ipos0%,1,%ipos8%) do (
	if %%x equ %ipos0% (
		<nul set /p =[%%xGl
	) else if %%x equ %ipos1% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos2% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos3% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos4% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos5% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos6% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos7% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos8% (
		<nul set /p =[%%xGk
	) else (
		<nul set /p =[%%xGq
	)
)
<nul set /p =(B
echo.
<nul set /p =[2K(0[%ipos0%Gx[%ipos1%Gx[%ipos2%Gx[%ipos3%Gx[%ipos4%Gx[%ipos5%Gx[%ipos6%Gx[%ipos7%Gx[%ipos8%Gx(B
<nul set /p =[%pos0%GПрогресс[%pos1%GТекущий[%pos2%GВсего[%pos3%GНайдено[%pos4%GОшибки запуска WinWS[%pos5%GОшибки завершения WinWS[%pos6%GКод ответа Curl[%pos7%GREPEATS[E
<nul set /p =(0
for /l %%x in (%ipos0%,1,%ipos8%) do (
	if %%x equ %ipos0% (
		<nul set /p =[%%xGt
	) else if %%x equ %ipos1% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos2% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos3% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos4% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos5% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos6% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos7% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos8% (
		<nul set /p =[%%xGu
	) else (
		<nul set /p =[%%xGq
	)
)
<nul set /p =(B
echo.[?25l
<nul set /p =7
<nul set /p =8[2K(0[%ipos0%Gx[%ipos1%Gx[%ipos2%Gx[%ipos3%Gx[%ipos4%Gx[%ipos5%Gx[%ipos6%Gx[%ipos7%Gx[%ipos8%Gx(B
echo.
<nul set /p =(0
for /l %%x in (%ipos0%,1,%ipos8%) do (
	if %%x equ %ipos0% (
		<nul set /p =[%%xGm
	) else if %%x equ %ipos1% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos2% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos3% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos4% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos5% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos6% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos7% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos8% (
		<nul set /p =[%%xGj
	) else (
		<nul set /p =[%%xGq
	)
)
<nul set /p =(B
echo.
echo.
echo.[%_pos%G[[33mi[0m][%pos%GПри изменении прогресса поиска мы сохраним результаты в файл '[33m%homenc%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.*[0m'
echo.[%_pos%G[[33mi[0m][%pos%GПоиск можно будет прервать, потом повторный поиск будет начат с прерванной позиции для этих настроек [[36m%DOMAINS%-%_PORT%-%_HTTP%[0m]
echo.[%_pos%G[[33mi[0m][%pos%GНайденные стратегии для этих настроек поиска сохраняются в файл.
echo.[%_pos%G[[33mi[0m][%pos%GЕсли хотите начать поиск с начала закройте скрипт, удалите файл найденных стратегий.
echo.[%_pos%G[[33mi[0m][%pos%GЕсли хотите сделать паузу и вернуться в меню, дождитесь '[36mREPEATS: [32mпауза[0m' и нажимайте клавишу '[36mq[0m'
echo.[%_pos%G[[33mi[0m][%pos%GВы можете вернуться обратно, поиск продолжится.
echo.[%_pos%G[[33mi[0m][%pos%GЕсли вы выключите скрипт, то поиск будет начат с прерванной позиции, сохраненной в файле.
echo.[%_pos%G[[33mi[0m][%pos%G[31mВнимание.[0m Если вы закроете окно скрипта, то процесс 'winws' может быть не завершен и поэтому может не работать интернет.
echo.[%_pos%G[[33mi[0m][%pos%GКорректный выход с помощью кнопки '[36mq[0m' (поставить на паузу и выйти в главное меню), потом можно закрывать окно.
					
set /a ipos7dec=%ipos7%-1
set /a pos6cut=%ipos7dec%-%pos6%
rem add 9 ANSI color symbols
set /a pos6cut+=9
for /F "skip=%line_begin% tokens=*" %%a in (%home%\strategy\strategy.lst) do (
	set read_line=%%a
	set foo=!read_line: =!
	set comment_char=!read_line: =!
	set comment_char=!comment_char:~0,1!
	if "x!comment_char!"=="x[" goto:@find_strategy_break
	set "foo="
	for /L %%c in (%pos6%,1,%ipos7dec%) do set "foo=!foo! "
	<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G!foo![%pos7%G     [?25l[8m
	%CURL% --max-time 1 one.one.one.one 1>nul 2>&1
	if !errorlevel! neq 0 goto:@find_strategy_no_ping
	call:progress_in_percent_count ap2
	set /a line_count+=1
	set /a count_strategy+=1
	set /a read_linecount=0
	for /L %%c in (500,-1,0) do (
		if "x!read_line:~%%c,2!"=="x--" (
			set "read_line!read_linecount!=!read_line:~%%c!"
			set "read_line=!read_line:~0,%%c!"
			set /a read_linecount+=1
		)
	)
	set /a read_linecount-=1
	set /a generate_count=!read_linecount!
	set "winws_arg_str_="
	set exist_fake_tls_std=0
	for /L %%c in (!read_linecount!,-1,0) do (
		set /a parse_desync = 0
		if defined read_line%%c (
			for /F "tokens=1,2 delims==" %%d in ("!read_line%%c!") do (
				if "x%%d"=="x--dpi-desync-fake-tls" (
					set "foo=%%e"
					set "foo=!foo: =!"
					if "x!foo!"=="x" (
						rem found '!'
						set exist_fake_tls_std=1
						set "winws_arg_str_=!winws_arg_str_! --dpi-desync-fake-tls=^! "
						set "generate_str%%c=--dpi-desync-fake-tls=^!"
					) else if "x!foo:~0,2!"=="x0x" (
						rem found HEX
						set "winws_arg_str_=!winws_arg_str_! !read_line%%c!"
					) else (
						rem found filename?
						set count_f=0
						for /L %%f in (500,-1,0) do (
							if !count_f! equ 0 if "x!foo:~%%f,1!"=="x/" (
								set count_f=%%f
								set foo=!foo:~%%f!
								set foo=!foo:~1!
							)
						)
						set "winws_arg_str_=!winws_arg_str_! %%d=%fakedir%\!foo! "
					)
				) else if "x%%d"=="x--dpi-desync-fake-unknown" (
					set /a parse_desync = 1
				) else if "x%%d"=="x--dpi-desync-fake-syndata" (
					set /a parse_desync = 1
				) else if "x%%d"=="x--dpi-desync-fake-wireguard" (
					set /a parse_desync = 1
				) else if "x%%d"=="x--dpi-desync-fake-dht" (
					set /a parse_desync = 1
				) else if "x%%d"=="x--dpi-desync-fake-discord" (
					set /a parse_desync = 1
				) else if "x%%d"=="x--dpi-desync-fake-stun" (
					set /a parse_desync = 1
				) else if "x%%d"=="x--dpi-desync-udplen-pattern" (
					set /a parse_desync = 1
				) else if "x%%d"=="x--dpi-desync-fake-quic" (
					set /a parse_desync = 1
				) else if "x%%d"=="x--dpi-desync-fake-unknown-udp" (
					set /a parse_desync = 1
				) else if "x%%d"=="x--wf-tcp" (
					set "winws_arg_str_=!winws_arg_str_! --wf-tcp=%_PORT%"
					set "generate_str%%c=--wf-tcp=%_PORT%"
				) else if "x%%d"=="x--wf-udp" (
					set "winws_arg_str_=!winws_arg_str_! --wf-udp=%_PORT%"
					set "generate_str%%c=--wf-udp=%_PORT%"
				) else (
					set "winws_arg_str_=!winws_arg_str_! !read_line%%c!"
					set "generate_str%%c=!read_line%%c!"
				)
				if !parse_desync! equ 1 (
					set "foo=%%e"
					set "foo=!foo: =!"
					if "x!foo:~0,2!"=="x0x" (
						set "winws_arg_str_=!winws_arg_str_! !read_line%%c!"
						set "generate_str%%c=!read_line%%c!"
					) else (
						rem found filename?
						set count_f=0
						for /L %%f in (500,-1,0) do (
							if !count_f! equ 0 if "x!foo:~%%f,1!"=="x/" (
								set count_f=%%f
								set foo=!foo:~%%f!
								set foo=!foo:~1!
							)
						)
						set "winws_arg_str_=!winws_arg_str_! %%d=%fakedir%\!foo! "
						set "generate_str%%c=%%d=%fakedir%\!foo!"
					)
				)
			)
		)
	)
	%winwsdir%\winws.exe --daemon !winws_arg_str_! 1>nul 2>&1
	set winws_ret_code=!errorlevel!
	if !winws_ret_code! neq 0 (
		echo.!line_count!: %winwsdir%\winws.exe --dry-run !winws_arg_str_! >>%home%\strategy\error_%DOMAINS%-%_PORT%-%_HTTP%.log
	)
	call:check_run
	if !errorlevel! equ 0 (
		for /l %%c in (1,1,%REPEATS%) do (
			set curl_ret_code=0
			%CURL% %curl_cmd_scan% 1>nul 2>&1
			set curl_ret_code_str=!errorlevel!
			set /a curl_ret_code+=!curl_ret_code_str!
			if %%c equ %REPEATS% (
				if !curl_ret_code! equ 0 (
					set /a find_strategy_found+=1
					echo.!line_count!: !winws_arg_str_! >>%home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.!ext_old!
					move /Y %home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.!ext_old! %home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.!count_strategy! 1>nul 2>&1
					set ext_old=!count_strategy!
					call:create_strategy !line_count!
				)
			)
			if !curl_ret_code_str! equ 0 (
				set "curl_ret_code_str=0: [32mOK[0m                       "
			) else if !curl_ret_code_str! equ 2 (
				if %%c equ %REPEATS% goto:@find_strategy_curl_2
				set "curl_ret_code_str=2: [31mFAILED_INIT[0m              "
			) else if !curl_ret_code_str! equ 6 (
				if %%c equ %REPEATS% goto:@find_strategy_curl_6
				set "curl_ret_code_str=6: [31mCOULDNT_RESOLVE_HOST[0m     "
			) else if !curl_ret_code_str! equ 28 (
				set "curl_ret_code_str=28: [33mOPERATION_TIMEDOUT[0m      "
			) else if !curl_ret_code_str! equ 35 (
				set "curl_ret_code_str=35: [33mSSL_CONNECT_ERROR[0m       "
			) else (
				set "curl_ret_code_str=!curl_ret_code_str!: [33mUNKNOWN_ERROR[0m           "
			)
			set curl_ret_code_str=!curl_ret_code_str:~0,%pos6cut%!
			<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G!curl_ret_code_str![%pos7%G%%c[?25l[8m
		)
		call:check_kill 
		if !errorlevel! neq 0 set /a find_strategy_kill_error+=1
	) else (
		set /a find_strategy_run_error+=1
		<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G-[%pos7%G-[?25l[8m
	)
	
	if not "x!ap2_old!"=="x!ap2!" (
		if exist %home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.!ext_old! (
			move /Y %home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.!ext_old! %home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.!count_strategy! 1>nul 2>&1
		) else echo.#>%home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.!count_strategy!
		set ext_old=!count_strategy!
		set "ap2_old=!ap2!"
	)
	set "foo="
	for /L %%c in (%pos6%,1,%ipos7dec%) do set "foo=!foo! "
	<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G!foo![%pos7%G[32mпауза[0m[?25l[8m
	choice /N /C:qйp /D p /T 1  1>nul 2>&1
	if !errorlevel! neq 3 goto:@find_strategy_end_choice
)
:@find_strategy_break
set "foo="
for /L %%c in (%pos6%,1,%ipos7dec%) do set "foo=!foo! "
<nul set /p =8[%pos0%G%ap2%%%[%pos1%G%count_strategy%[%pos2%G%total_strategy%[%pos3%G%find_strategy_found%[%pos4%G%find_strategy_run_error%[%pos5%G%find_strategy_kill_error%[%pos6%G%foo%[%pos7%G     [?25l[8m
if exist %home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.%ext_old% (
	move /Y %home%\strategy\run_%DOMAINS%-%_PORT%-%_HTTP%.%ext_old% %home%\strategy\done_%DOMAINS%-%_PORT%-%_HTTP%.log 1>nul 2>&1
)
echo.[10E[0m
echo.
echo.[%pos%GГотово
echo.
if %find_strategy_found% neq 0 (
	echo.[%pos%GНайдено стратегий: [32m%find_strategy_found%[0m
	echo.[%pos%GОписание стратегий в файле '[33m%homenc%\strategy\done_%DOMAINS%-%_PORT%-%_HTTP%.log[0m'
)
echo.
goto:@find_strategy_end

:@find_strategy_curl_2
echo.[12E[0m
call:check_kill 
echo.[%_pos%G[[31mx[0m][%pos%G[31mInternal libcurl Error[0m
echo.
goto:@find_strategy_end

:@find_strategy_curl_6
echo.[12E[0m
call:check_kill 
echo.[%_pos%G[[31mx[0m][%pos%G[31mОшибка [0mcURL "[31mCould not resolve host[0m". Не удалось найти IP-адрес для указанного доменного имени.[0m
echo.[%pos%GDNS-сервер, который использует ваше устройство, может испытывать проблемы с разрешением этого домена.
echo.[%pos%GЭто может быть временная проблема, либо проблема на стороне провайдера.
echo.[%pos%GВ некоторых случаях, проблема может быть в вашем интернет-соединении или настройках сети, которые не позволяют cURL получить доступ к DNS-серверам.
echo.[%pos%GБрандмауэр или антивирусное ПО на вашем компьютере могут блокировать запросы к DNS-серверам.
echo.
echo.[%pos%GКак исправить ошибку:
echo.
echo.[%pos%G1. Попробуйте использовать другой DNS-сервер, например, (1.1.1.1 и 1.0.0.1).
echo.[%pos%G2. Временно отключите брандмауэр и антивирус, чтобы проверить, не блокируют ли они запросы.
echo.
goto:@find_strategy_end

:@find_strategy_txtmess
echo.
echo.[%pos%GВероятно Ваш антивирус счёл его опасным и поместил в карантин. 
echo.
echo.[%pos%G[31mПРЕДУПРЕЖДЕНИЕ[0m : ВОЗМОЖНА ЭВРИСТИЧЕСКАЯ РЕАКЦИЯ АНТИВИРУСОВ НА [33mUPX[0m И [33mWINDIVERT[0m. 
echo.[%pos%G[33mWINDIVERT[0m - хакерский инструмент, потенциально нежелательное ПО, потенциально часть вируса, но сам по себе - не вирус. 
echo.[%pos%G[33mUPX[0m - не троян, а компрессор исполняемых файлов. 
echo.
echo.[%pos%G[32mВирусов и майнеров здесь нет.[0m
echo.
echo.[%pos%GДобавьте директорию в '[33m%homenc%[0m' исключения антивируса.
goto:@find_strategy_end
:@find_strategy_end_choice
echo.[12E
call:check_kill 
echo.[0m
echo.[?25h
goto:menu
:@find_strategy_no_ping
echo.[12E
echo.[0m
echo.
echo.[%pos%G[31mНет интернета.[0m Поиск ставим на паузу. Восстановите связь и можно продолжить поиск.
goto:@find_strategy_end
:@find_strategy_end
echo.
echo.[?25h
echo.[%pos%GНажмите любую клавишу для возврата в меню.
pause >nul
goto:menu

:create_strategy
set "_dir=%~1"
set /a _dir+=100000
set "_dir=0%_dir:~1%"
if not exist %home%\strategy\blockcheck_%_dir% ( 
	md %home%\strategy\blockcheck_%_dir%\custom >nul
	md %home%\strategy\blockcheck_%_dir%\skip >nul
)
set /a _irand=(20000*%random%/32678)+10000
set "generate_to=%home%\strategy\blockcheck_%_dir%" 
if exist %home%\strategy\blockcheck_%_dir%\%_PORT%-%_HTTP%.strategy set "generate_to=%home%\strategy\blockcheck_%_dir%\skip"
if not exist %home%\strategy\blockcheck_%_dir%\about echo.Создана скриптом из списка [line: %~1]>%home%\strategy\blockcheck_%_dir%\about
set "_ext=strategy"
if exist %generate_to%\%_PORT%-%_HTTP%.strategy set "_ext=strategy.%_irand%"
echo.#Create from list line: %~1 >%generate_to%\%_PORT%-%_HTTP%.%_ext%
for /l %%i in (%generate_count%,-1,0) do (
	if defined generate_str%%i echo.!generate_str%%i! >>%home%\strategy\blockcheck_%_dir%\%_PORT%-%_HTTP%.%_ext%
)
exit /b

:help
cls
echo.
echo.[5G[37mHelp[0m
echo.
echo.[5GНажмите любую клавишу для возврата в меню.
pause >nul
goto:menu

:blockcheck_create_cfg
chcp 65001 >nul
rem https://github.com/bol-van/zapret?tab=readme-ov-file#%D0%BF%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%BA%D0%B0-%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D0%B0
if not exist %home%\blockcheck.config.txt (
	(
	echo.## 
	echo.# CURL - Р·Р°РјРµРЅР° РїСЂРѕРіСЂР°РјРјС‹ curl 
	echo.
	echo.# CURL=bin\curl.exe
	echo.
	echo.# CURL_MAX_TIME - РІСЂРµРјСЏ С‚Р°Р№РјР°СѓС‚Р° curl РІ СЃРµРєСѓРЅРґР°С…
	echo.
	echo.# CURL_MAX_TIME=2
	echo.
	echo.# CURL_MAX_TIME_QUIC - РІСЂРµРјСЏ С‚Р°Р№РјР°СѓС‚Р° curl РґР»СЏ quic. РµСЃР»Рё РЅРµ Р·Р°РґР°РЅРѕ, РёСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ Р·РЅР°С‡РµРЅРёРµ CURL_MAX_TIME
	echo.# CURL_MAX_TIME_DOH - РІСЂРµРјСЏ С‚Р°Р№РјР°СѓС‚Р° curl РґР»СЏ DoH СЃРµСЂРІРµСЂРѕРІ
	echo.# CURL_CMD=1 - РїРѕРєР°Р·С‹РІР°С‚СЊ РєРѕРјР°РЅРґС‹ curl
	echo.# CURL_OPT - РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹ curl. `-k` - РёРіРЅРѕСЂ СЃРµСЂС‚РёС„РёРєР°С‚РѕРІ. `-v` - РїРѕРґСЂРѕР±РЅС‹Р№ РІС‹РІРѕРґ РїСЂРѕС‚РѕРєРѕР»Р°
	echo.
	echo.# CURL_OPT=-v
	echo.
	echo.# IPVS=4^|6^|46 - С‚РµСЃС‚РёСЂСѓРµРјС‹Рµ РІРµСЂСЃРёРё ip РїСЂРѕС‚РѕРєРѕР»Р°
	echo.
	echo.IPVS=4
	echo.
	echo.# ENABLE_HTTP=0^|1 - РІРєР»СЋС‡РёС‚СЊ С‚РµСЃС‚ plain http
	echo.
	echo.# ENABLE_HTTP=0
	echo.
	echo.# ENABLE_HTTPS_TLS12=0^|1 - РІРєР»СЋС‡РёС‚СЊ С‚РµСЃС‚ https TLS 1.2
	echo.
	echo.ENABLE_HTTPS_TLS12=1
	echo.
	echo.# ENABLE_HTTPS_TLS13=0^|1 - РІРєР»СЋС‡РёС‚СЊ С‚РµСЃС‚ https TLS 1.3
	echo.
	echo.ENABLE_HTTPS_TLS13=0
	echo.
	echo.# ENABLE_HTTP3=0^|1 - РІРєР»СЋС‡РёС‚СЊ С‚РµСЃС‚ QUIC
	echo.
	echo.# ENABLE_HTTP3=0
	echo.
	echo.# REPEATS - РєРѕР»РёС‡РµСЃС‚РІРѕ РїРѕРїС‹С‚РѕРє С‚РµСЃС‚РёСЂРѕРІР°РЅРёСЏ
	echo.
	echo.REPEATS=4
	echo.
	echo.# PARALLEL=0^|1 - РІРєР»СЋС‡РёС‚СЊ РїР°СЂР°Р»Р»РµР»СЊРЅС‹Рµ РїРѕРїС‹С‚РєРё. РјРѕР¶РµС‚ РѕР±РёРґРµС‚СЊ СЃР°Р№С‚ РёР·-Р·Р° РґРѕР»Р±РµР¶РєРё Рё РїСЂРёРІРµСЃС‚Рё Рє РЅРµРІРµСЂРЅРѕРјСѓ СЂРµР·СѓР»СЊС‚Р°С‚Сѓ
	echo.
	echo.PARALLEL=0
	echo.
	echo.# SCANLEVEL=quick^|standard^|force - СѓСЂРѕРІРµРЅСЊ СЃРєР°РЅРёСЂРѕРІР°РЅРёСЏ
	echo.
	echo.SCANLEVEL=standard
	echo.
	echo.# BATCH=1 - РїР°РєРµС‚РЅС‹Р№ СЂРµР¶РёРј Р±РµР· РІРѕРїСЂРѕСЃРѕРІ Рё РѕР¶РёРґР°РЅРёСЏ РІРІРѕРґР° РІ РєРѕРЅСЃРѕР»Рё
	echo.
	echo.BATCH=1
	echo.
	echo.# HTTP_PORT, HTTPS_PORT, QUIC_PORT - РЅРѕРјРµСЂР° РїРѕСЂС‚РѕРІ РґР»СЏ СЃРѕРѕС‚РІРµС‚СЃС‚РІСѓСЋС‰РёС… РїСЂРѕС‚РѕРєРѕР»РѕРІ
	echo.
	echo.# HTTP_PORT=80
	echo.
	echo.HTTPS_PORT=443
	echo.
	echo.# QUIC_PORT=443
	echo.
	echo.# SKIP_DNSCHECK=1 - РѕС‚РєР°Р· РѕС‚ РїСЂРѕРІРµСЂРєРё DNS
	echo.
	echo.SKIP_DNSCHECK=0
	echo.
	echo.# SKIP_IPBLOCK=1 - РѕС‚РєР°Р· РѕС‚ С‚РµСЃС‚РѕРІ Р±Р»РѕРєРёСЂРѕРІРєРё РїРѕ РїРѕСЂС‚Сѓ РёР»Рё IP
	echo.# SKIP_TPWS=1 - РѕС‚РєР°Р· РѕС‚ С‚РµСЃС‚РѕРІ tpws
	echo.
	echo.SKIP_TPWS=0
	echo.
	echo.# SKIP_PKTWS=1 - РѕС‚РєР°Р· РѕС‚ С‚РµСЃС‚РѕРІ nfqws/dvtws/winws
	echo.# PKTWS_EXTRA, TPWS_EXTRA - РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹ nfqws/dvtws/winws Рё tpws, СѓРєР°Р·С‹РІР°РµРјС‹Рµ РїРѕСЃР»Рµ РѕСЃРЅРѕРІРЅРѕР№ СЃС‚СЂР°С‚РµРіРёРё
	echo.
	echo.# PKTWS_EXTRA='user strategy for test'
	echo.# PKTWS_EXTRA='--wf-tcp=80 --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig'
	echo.
	echo.# PKTWS_EXTRA_1 .. PKTWS_EXTRA_9, TPWS_EXTRA_1 .. TPWS_EXTRA_9 - РѕС‚РґРµР»СЊРЅРѕ РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹, СЃРѕРґРµСЂР¶Р°С‰РёРµ РїСЂРѕР±РµР»С‹
	echo.# PKTWS_EXTRA_PRE - РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹ РґР»СЏ nfqws/dvtws/winws, СѓРєР°Р·С‹РІР°РµРјС‹Рµ РїРµСЂРµРґ РѕСЃРЅРѕРІРЅРѕР№ СЃС‚СЂР°С‚РµРіРёРµР№
	echo.# PKTWS_EXTRA_PRE_1 .. PKTWS_EXTRA_PRE_9 - РѕС‚РґРµР»СЊРЅРѕ РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹, СЃРѕРґРµСЂР¶Р°С‰РёРµ РїСЂРѕР±РµР»С‹
	echo.# SECURE_DNS=0^|1 - РїСЂРёРЅСѓРґРёС‚РµР»СЊРЅРѕ РІС‹РєР»СЋС‡РёС‚СЊ РёР»Рё РІРєР»СЋС‡РёС‚СЊ DoH
	echo.
	echo.SECURE_DNS=1
	echo.
	echo.# DOH_SERVERS - СЃРїРёСЃРѕРє URL DoH С‡РµСЂРµР· РїСЂРѕР±РµР» РґР»СЏ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРѕРіРѕ РІС‹Р±РѕСЂР° СЂР°Р±РѕС‚Р°СЋС‰РµРіРѕ СЃРµСЂРІРµСЂР°
	echo.# DOH_SERVER - РєРѕРЅРєСЂРµС‚РЅС‹Р№ DoH URL, РѕС‚РєР°Р· РѕС‚ РїРѕРёСЃРєР°
	echo.# UNBLOCKED_DOM - РЅРµР·Р°Р±Р»РѕРєРёСЂРѕРІР°РЅРЅС‹Р№ РґРѕРјРµРЅ, РєРѕС‚РѕСЂС‹Р№ РёСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ РґР»СЏ С‚РµСЃС‚РѕРІ IP block
	echo.
	echo.# DOMAINS - СЃРїРёСЃРѕРє С‚РµСЃС‚РёСЂСѓРµРјС‹С… РґРѕРјРµРЅРѕРІ С‡РµСЂРµР· РїСЂРѕР±РµР»
	echo.
	echo.DOMAINS="ntc.party rutracker.net"
	)>%home%\blockcheck.config.txt
)
chcp 1251 >nul
exit /b