@echo off
echo.[c
echo.[?1049l
echo.[!п
REM echo.[?3h
chcp 1251 > nul
setlocal EnableDelayedExpansion
set /a mode_con_cols = 160
set /a mode_con_lines= 40

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

echo.]0;Bypassing Censorship %foo%\
echo.[39;49m
echo.[7l
echo.[?12l
echo.[?25l
REM echo.[1;200r
REM echo.[?3h

:menu
cls
echo.[100M
for /f "skip=4 tokens=2 delims=:" %%a in ('mode') do (
	set "mode_con_cols=%%a"
	goto:@formodebreak
)
:@formodebreak
set "mode_con_cols=%mode_con_cols: =%"
set /a c1=5
set /a c2=9
set /a c3=13
set /a c4=30
set /a c5=55
set /a c6=80
set /a c7=100
set /a c8=%mode_con_cols% - 5
echo.[5G[2mОбновление меню скрипта каждые 60 сек.[0m
set /a srv_menu_count=1000
set /a strategy_menu_count=1000
set /a parameter_menu_count=1000
set /a agent_work=1000
set /a terminate_count=1000
set /a blockcheck_menu_count=1000
set /a find_strategy_menu_count=1000

if defined count_strategy echo.[5GПоиск стратегий на [32mпаузе[0m, вы можете вернуться

set /a menu_choice=1000
if not exist %winwsdir%\winws.exe (
	echo.[5G[31mДля работы скрипта скачать новую версию драйверов и извлечь в директорию '[33m%homenc%\bin\[31m' [0m
)
if not exist %home%\run.config (
	(
	echo.# config
	echo.daemon=on
	echo.debug=off
	echo.custom_strategy=off
	echo.IPsetStatus=off
	echo.agent_mode=start
	echo.agent_start_strategy="none"
	echo.agent_start_params=1000
	)>%home%\run.config
)
for /F "skip=1 eol=# tokens=1,2 delims==" %%a in (%home%\run.config) do set %%~a=%%~b
set "winws_pid="
set /a socks5=0
<nul set /p =[5GСекундочку
set /a foo=0
for /f "tokens=1,2 delims=," %%a in ('2^>nul tasklist /FI "IMAGENAME eq winws.exe" /fo csv /nh') do (
	if "x%%~a"=="xwinws.exe" (
		set /a foo+=1
		set "winws_pid!foo!=%%~b"
		<nul set /p =.
	)
)

set "strategy_run="
set /a profile_count=0
set "commandline="
set "daemon_status="
set "debug_status="
if %foo% GTR 0 ( 
	for /l %%m in (1,1,%foo%) do (
		for /f "tokens=* delims=" %%a in ('2^>nul powershell -Command "Get-WmiObject win32_process -Filter 'ProcessId ^= !winws_pid%%m!' | select commandline | Format-List -Property *"') do (
			set "rtg=%%a"
			set "rtg=!rtg:~14!"
			set "commandline=!commandline!!rtg!"
			<nul set /p =.
		)
		set "commandline%%m=!commandline!"
		set "commandline="
	)
	
	for /l %%m in (1,1,%foo%) do (
		for /f "tokens=2-7 delims=[]" %%a in ("!commandline%%m!") do (
			set /a profile_count+=1
			set "n!profile_count!=%%~a"
			set "custom_str=%%~b"
			set "ip!profile_count!=%%~c"
			set "pr!profile_count!=%%~d"
			set "pid!profile_count!=!winws_pid%%m!"
			set "daemon_status=%%~e"
			set "debug_status=%%~f"
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
			for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
			echo.
			if not "x%daemon_status%"=="x%daemon%" set /a check_restart_str+=1
			if not "x%debug_status%"=="x%debug%" set /a check_restart_str+=1
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
			if "x!debug_status!"=="xon" ( set "offon=да" ) else ( set "offon=нет" )
			echo.[%c4%G[33mПоказывать ход работы в окне[0m: !offon!
			if "x!custom_str!"=="xon" ( set "offon=да" ) else ( set "offon=нет" )
			echo.[%c4%G[33mЗапуск 'custom' стратегий[0m: !offon!
			if "x!ip%%i!"=="xon" ( set "offon=да" ) else ( set "offon=нет" )
			echo.[%c4%G[33mИспользовать список IP[0m: !offon!
			set /a foo=%c4%
			set /a foo=!foo! - 1
			for /l %%x in (1,1,!foo!) do <nul set /p =[%%xG[8m-[0m
			for /l %%x in (%c4%,1,%c8%) do <nul set /p =[%%xG-
			echo.
		)
		set "about_profile=!pr%%i!"
		echo.[%c1%GPID: !pid%%i![%c4%G[36m!about_profile:~0,%about_profile_strsize%![0m
	)
	for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
	echo.
	set "strategy_run=!n1!" 
REM ) else (
	REM for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
	REM echo.
)
rem --------------------------------------
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
echo.[%c1%G[37m!menu_count!.[%c2%GПоиск стратегий[0m
rem ------------------------------------------------------------------------------------
if exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh (
	REM for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
	REM echo.
	set /a menu_count+=1
	set /a blockcheck_menu_count=!menu_count!
	echo.[%c1%G[37m!menu_count!.[%c2%GBlockcheck[0m
)
rem ------------------------------------------------------------------------------------
set /a foo=%c1%-1
set "a1="
if %param_trigger% equ 0 set "a1=[..]"
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
	set "atten="
	set /a foo=7
	if "x%debug%"=="xon" ( 
		set /a foo=2
		set "offon=да " 
	) else ( 
		set /a foo=1
		set "offon=нет" 
	)
	REM if "x%debug%"=="x@filename" (
		REM set /a foo=7
		REM set "atten=very slow"
	REM )
	set /a menu_count+=1
	echo.[%c1%G[37m!menu_count!.[%c2%GПоказывать ход работы в окне[%c5%G[[3!foo!m!offon![0m] [31m!atten![0m
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
REM for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
REM echo.
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
		rem echo.[1F[2K
		echo.[%c2%G[31mСтратегии не найдены. [0m
		echo.[%c2%GДобавьте файлы стратегий в папку '[33m%homenc%\strategy\[0m'
	) 
	echo.
)
REM else (
	REM for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
	REM echo.
REM )
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
			echo.[%c3%G[33mДля запуска агента выполнить задание [37m'dpiagent'[33m в планировщике заданий[0m
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
REM for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
REM echo.
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
		REM echo.
	)
	REM for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
	REM echo.
)

echo.
echo.[%c1%G0.[%c2%GВыход
echo.
:@choice_gtr_menu_count
set "str1choice=0123456789rcсafфаetеуmьvм"
REM cс		- 'С'тратегии
REM afфа	- 'А'втоматизация
REM etеу	- Зав'е'ршить стратегию
REM mьvм	- Пара'м'етры
set /a first_digit=1000
choice /N /C:%str1choice% /D r /T 60 /M "#:"
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
if %_errorlevel% GEQ 22 goto:param_trigger
if %_errorlevel% GEQ 18 goto:terminate_trigger
if %_errorlevel% GEQ 14 goto:srv_menu_trigger
if %_errorlevel% GEQ 12 goto:expand_strategy
if %_errorlevel% EQU 11 goto:menu
echo.[2F
set "str2choice=0123456789z"
set /a second_digit=1000
set "second_digit_char="
choice /N /C:0123456789z /D z /T 3 /M "#:"
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
echo.[1F[5M#: %first_digit_char%%second_digit_char%
timeout /T 1 /NOBREAK >nul
if %menu_choice% gtr %menu_count% (
	echo.[2F[5M
	goto:@choice_gtr_menu_count
)
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
	call:@check_kill
	goto:terminate_done
)
if "x%arg_1%"=="xstart" goto:terminate_all
if "x%arg_1%"=="xstop" goto:terminate_all
if %menu_choice% neq 1000 if %menu_choice% EQU %terminate_count% goto:terminate_all
if %menu_choice% neq 1000 if %menu_choice% GTR %terminate_count% goto:terminate_one
:terminate_all
call:cecho x3 "Завершаем работу стратегии" "'%strategy_run%'"
for /l %%i in (1,1,%profile_count%) do (
	if "x!n%%i!"=="x%strategy_run%" (
		powershell -NoP -sta -NonI -Command "Stop-Process -Id !pid%%i! -Force" 1>nul 2>&1
	)
)
call:@check_kill
set "strategy_run="
if "x%arg_1%"=="xstart" goto:terminate_done
if "x%arg_1%"=="xstop" goto:terminate_done
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
if %menu_choice% neq 1000 if %menu_choice% EQU %blockcheck_menu_count% goto:terminate_done
if %menu_choice% neq 1000 if %menu_choice% LSS %terminate_count% goto:terminate_done

:terminate_one
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
:terminate_done
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
for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\exclude\*.txt') do (
	set "zapret_hosts_user_exclude=!zapret_hosts_user_exclude! --hostlist-exclude=%home%\lists\exclude\%%X"
)
set "daemon_bakup=%daemon%"
set "debug_bakup=%debug%"
set "custom_strategy_bakup=%custom_strategy%"
set "IPsetStatus_bakup=%IPsetStatus%"
if not defined arg_3 goto:arg_3_default
if "x%arg_3:~0,1%"=="x0" (
	set "daemon=off"
) else (
	if "x%arg_3:~0,1%"=="x1" (
		set "daemon=on"
	) else goto:error_arg3
)
if "x%arg_3:~1,1%"=="x0" (
	set "debug=off"
) else (
	if "x%arg_3:~1,1%"=="x1" (
		set "debug=on"
	) else goto:error_arg3
)
if "x%arg_3:~2,1%"=="x0" (
	set "custom_strategy=off"
) else (
	if "x%arg_3:~2,1%"=="x1" (
		set "custom_strategy=on"
	) else goto:error_arg3
)
if "x%arg_3:~3,1%"=="x0" (
	set "IPsetStatus=off"
) else (
	if "x%arg_3:~3,1%"=="x1" (
		set "IPsetStatus=on"
	) else goto:error_arg3
)
:arg_3_default
call:cecho x3 "Парсинг параметров, см." "%homenc%\strategy\%strategy_name%\log\"
set /a pcount=0
set /a scount=0
call:@parse_str "%strategy_apath%" "%homenc%\strategy\%strategy_name%"
if "x%custom_strategy%"=="xon" (
	if not exist %strategy_apath%\custom md %strategy_apath%\custom >nul
	call:@parse_str "%strategy_apath%\custom" "%homenc%\strategy\%strategy_name%\custom"
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
	set wscomment=--comment [%strategy_name%][%custom_strategy%][%IPsetStatus%][!sabout!][%daemon%][%debug%]
	%winwsdir%\winws.exe --dry-run !wsdebug! !wsdaemon! !wscomment! !wsarg! 2>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-dry-run-status-err.log" 1>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-dry-run-status.log"
	if !errorlevel! neq 0 (
		call:cecho 1x3 "Ошибка." "Подробности смотри в" "'%homenc%\strategy\%strategy_name%\log\!name_strategy_file_parse_ok%%i!-dry-run-status-err.log"
		set /a ecode=1
		goto:strategy_list_end
	)
	%winwsdir%\winws.exe --wf-save="%strategy_apath%\log\!name_strategy_file_parse_ok%%i!-save.raw" !wsarg! 2>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-wf-save-status-err.log" 1>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-wf-save-status.log"
	if "x%daemon%"=="xoff" (
		rem echo.start "%strategy_name%:[!sabout!] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] Debug:[%debug%]" %winwsdir%\winws.exe !wsdebug! !wscomment! !wsarg! >>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-cmd.bat.example"
		rem start "%strategy_name%:[!sabout!] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] Debug:[%debug%]" %winwsdir%\winws.exe !wsdebug! !wscomment! !wsarg!
		echo.start "[!sabout!] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] Debug:[%debug%]" %winwsdir%\winws.exe !wsdebug! !wscomment! !wsarg! >>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-cmd.bat.example"
		start "[!sabout!] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] Debug:[%debug%]" %winwsdir%\winws.exe !wsdebug! !wscomment! !wsarg!
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
	set "debug=%debug_bakup%"
	set "custom_strategy=%custom_strategy_bakup%"
	set "IPsetStatus=%IPsetStatus_bakup%"
	exit %ecode%
)
if %pcount% equ 0 goto:strategy_list_exit
set /a foo=0
if "x%daemon%"=="xon" set /a foo+=1000
if "x%debug%"=="xon" set /a foo+=100
if "x%custom_strategy%"=="xon" set /a foo+=10
if "x%IPsetStatus%"=="xon" set /a foo+=1
set agent_start_strategy="%strategy_name%"
set /a agent_start_params=%foo%
call:sconfig
REM for /l %%x in (5,-1,1) do (
	REM echo.[F
	REM <nul set /p =[5G[37mВозврат в меню через [32m%%x[37m с.[0m
	REM timeout /T 1 /NOBREAK >nul
REM )
:strategy_list_exit
echo.
echo.[%c3%GНажмите любую клавишу для возврата в меню.
pause >nul
goto:menu
:error_arg3
set /a ecode=1
echo.[5G[31mНеверный аргумент #3: [37m'[33m%arg_3%[37m'[0m]
goto:strategy_list_end

:expand_strategy
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
) else ( 
	set "daemon=on"
	set "debug=off"
)
call:sconfig
goto:menu

:menu_2
rem debug=@filename - very slow :(

if "x%debug%"=="xon" (
	set "debug=off"
) else if "x%debug%"=="xoff" (
	if "x%daemon%"=="xon" ( 
		set "daemon=off" 
		set "debug=on" 
	) else ( 
		set "debug=on" 
	)
) 
call:sconfig
goto:menu

:menu_3
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

:menu_4
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
	goto:err_blockcheck
)
if not exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh (
	echo.[5G[31mОшибка. [37mФайл не найден: '[33m%homenc%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh[37m'[0m
:err_blockcheck
	echo.
	echo.[5G[37mЕсли хотите использовать '[33mblockcheck[0m' то нужно его скачать и извлечь в директорию '[33m%homenc%\bin\[37m': [0m
	echo.
	echo.[5Ghttps://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip
	echo.
	echo.[5GНажмите любую клавишу для возврата в меню.
	pause >nul
	goto:menu
)

call:@check_kill

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
REM for /l %%x in (5,-1,1) do (
	REM echo.[F
	REM <nul set /p =[5G[37mВозврат в меню через [32m%%x[37m с.[0m
	REM timeout /T 1 /NOBREAK >nul
REM )
echo.[5GНажмите любую клавишу для возврата в меню.
pause >nul
goto:menu

:menu_srv
if %agent_work% equ 1 (
	if "x%agent_mode%"=="xstart" ( set /a castart=100 ) else ( set /a castart=0 )
	if "x%agent_mode%"=="xstop" ( set /a castop=100 ) else ( set /a castop=0 )
	set /a cadel=1
)
if %agent_work% equ 0 (
	set /a castart=101
	set /a castop=102
	set /a cadel=0
)
schtasks /Query /TN dpiagent 1>nul 2>&1
if %errorlevel% EQU 0 (
	set /a foo=%menu_choice% - %srv_menu_count%
	if !foo! equ !castart! (
		set "agent_mode=start"
		echo.[5G[37mСигнал '[32mstart[0m' отправлен
	) else if !foo! equ !castop! (
		set "agent_mode=stop"
		echo.[5G[37mСигнал '[31mstop[0m' отправлен
	) else if !foo! equ !cadel! (
		schtasks /End /TN dpiagent 1>nul 2>&1
		schtasks /Delete /TN dpiagent /F 1>nul 2>&1
		if !errorlevel! EQU 0 (
			echo.
			echo.[5G[32mЗадание удалено[0m
		) else (
			echo.
			echo.[5G[31mОшибка[0m
		)
	)
	call:sconfig
) else (
	set "agent_mode=start"
	call:sconfig
	if not exist %home%\agent.log echo.#>%home%\agent.log
	schtasks /Create /F /TN dpiagent /NP /RU "SYSTEM" /SC onstart /TR "%home%\script\run_agent.cmd %home%" 1>nul 2>&1
	if !errorlevel! EQU 0 (
		echo.
		echo.[5G[32mГотово[0m
		schtasks /Run /TN dpiagent 1>nul 2>&1
	) else (
		echo.
		echo.[5G[31mОшибка[0m
	)
)
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
echo.# config
echo.daemon=%daemon%
echo.debug=%debug%
echo.custom_strategy=%custom_strategy%
echo.IPsetStatus=%IPsetStatus%
echo.agent_mode=%agent_mode%
echo.agent_start_strategy="%strategy_name%"
echo.agent_start_params=%agent_start_params%
)>%home%\run.config
exit /b

:@parse_str
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
			rem if not "x!fletter:~0,1!"=="x#" (
			rem есть маркеры <HOSTLIST_NOAUTO> и <HOSTLIST> <IPSET>
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
					if "x%custom_strategy%"=="xon" (
						if exist %parse_str_strategy_apath%\!LN:~1! (
							set sWinDivert=--wf-raw=@%parse_str_strategy_apath%\!LN:~1!
						) else (
							set "skip_WinDivert=on"
							if "x%custom_strategy%"=="xon" (
								call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'%homenc%\strategy\%strategy_name%\custom\!LN:~0!'"
							) else call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'%homenc%\strategy\%strategy_name%\!LN:~0!'"
							call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						)
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
				set /a parse_desync = 1
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
if defined pinp goto:@progress_in_percent_exit
set /a temp_percent_count=0
set /a pinp=0
set /a temp_percent = %~1 / 100
set /a pinp_count=1
if %temp_percent% neq 0 goto:@progress_in_percent_end
set /a temp_percent = %~1 / 10
set /a pinp_count=10
if %temp_percent% neq 0 goto:@progress_in_percent_end
set /a temp_percent=%~1
set /a pinp_count=100 / %temp_percent%
:@progress_in_percent_end
set /a temp_percent_step=!temp_percent!
:@progress_in_percent_exit
exit /b

:progress_in_percent_count
set /a temp_percent_count+=1
if %pinp% equ 100 goto:@progress_in_percent_count_exit
if %temp_percent_count% neq %temp_percent_step% goto:@progress_in_percent_count_exit
set /a "temp_percent_count=0"
set /a pinp+=%pinp_count%
:@progress_in_percent_count_exit
set /a %~1=%pinp%
exit /b

:@check_run
for /L %%I in (1,1,5) do (
	powershell -NoP -sta -NonI -Command "Get-Process -Name 'winws'" 1>nul 2>&1
	if !errorlevel! equ 0 exit /b 0
	timeout /T 1 /NOBREAK >nul
	rem for /L %%x in (1,1,10) do ping localhost -n 1 >nul
)
exit /b 1

:@check_kill
for /L %%I in (1,1,5) do (
	REM powershell -Command "Stop-Process -Name 'winws' -Force" 1>nul 2>&1
	powershell -NoP -sta -NonI -Command "Get-Process -Name 'winws' | Stop-Process -Force" 1>nul 2>&1
	timeout /T 1 /NOBREAK >nul
	rem for /L %%x in (1,1,10) do ping localhost -n 1 >nul
	powershell -NoP -sta -NonI -Command "Get-Process -Name 'winws'" 1>nul 2>&1
	if !errorlevel! neq 0 (
		sc qc windivert 1>nul 2>&1
		if !errorlevel! equ 0 (
			sc stop windivert 1>nul 2>&1
			sc delete windivert 1>nul 2>&1
		)
		exit /b 0
	)
	timeout /T 1 /NOBREAK >nul
	rem for /L %%x in (1,1,10) do ping localhost -n 1 >nul
)
exit /b 1

:find_strategy
cls
echo.[100M
set /a find_strategy_debug=0
set /a pos=5

if not defined winwsdir (
	echo.[1G[[33mi[0m][%pos%G[37mДля работы скрипта скачать новую версию драйверов и извлечь в директорию '[33m%homenc%\bin\[37m' [0m
	echo.
	echo.[%pos%G Скачать:
	echo.[%pos%G https://github.com/bol-van/zapret/releases
	echo.
	goto:@find_strategy_end
)
if not exist %winwsdir%\WinDivert.dll (
	echo.[1G[[31mx[0m][%pos%G[31mНе найден[0m файл [33m'%homenc%\!winwsdir:~%homestrsize%!\WinDivert.dll'[0m.
	goto:@find_strategy_txtmess
)
if not exist %winwsdir%\WinDivert%archd%.sys (
	echo.[1G[[31mx[0m][%pos%G[31mНе найден[0m файл [33m'%homenc%\!winwsdir:~%homestrsize%!\WinDivert%archd%.sys'[0m.
	goto:@find_strategy_txtmess
)

if defined count_strategy (
	call:@check_kill
	echo.
	echo.
	echo.[1G[[33mi[0m][%pos%GПредыдущий поиск был прерван на позиции '[33m%count_strategy%[0m', продолжим поиск с неё.
	goto:@return_find
)
set /a find_strategy=0
set /a count_strategy=0
set /a count_strategy_save=0
set /a find_strategy_found=0
set /a find_strategy_kill_error=0
set /a find_strategy_run_error=0
set "curl_ret_code=-"
set "curl_cmd_scan="
set "strategy_file_lst=strategy_https.lst"
echo.
echo.
echo.[1G[[33mi[0m][%pos%GЗавершим все 'winws' процессы[0m
call:@check_kill
if %errorlevel% equ 0 (
	echo.[1G[[32m+[0m][%pos%GГотово[0m
)

if exist %home%\winws_error_code del /f /q %home%\winws_error_code

if not exist %home%\blockcheck.config.txt call:blockcheck_create_cfg
echo.[1G[[33mi[0m][%pos%GЧитаем хотелку '[33m%homenc%\blockcheck.config.txt[0m'
for /F "skip=1 eol=# tokens=1,2 delims==" %%a in (%home%\blockcheck.config.txt) do set "%%a=%%b"
echo.[1G[[33mi[0m][%pos%GИспользуемые переменные из '[33m%homenc%\blockcheck.config.txt[0m'

if not defined DOMAINS (
	set "DOMAINS=ntc.party"
	echo.[%pos%G[33mDOMAINS not defined[0m
)
set DOMAINSFULL=%DOMAINS%
set DOMAINS=%DOMAINS:"=%
set /a foo=0
for /L %%i in (1,1,50) do (
	if "x!DOMAINS:~%%i,1!"=="x " (
		set DOMAINS=!DOMAINS:~0,%%i!
		set /a foo=1
		goto:@break_DOMAINS
	)
)
:@break_DOMAINS
if %foo% equ 1 (
	echo.
	echo.[%pos%G[31mDOMAINS=%DOMAINSFULL%[0m
	echo.
	echo.[1G[[33mi[0m][%pos%GТолько один домен проверим
)
<nul set /p =[%pos%G[36mDOMAINS=%DOMAINS%[0m[E

if not defined CURL_MAX_TIME (
	set CURL_MAX_TIME=2
	echo.[%pos%G[33mCURL_MAX_TIME not defined[0m
) else echo.[%pos%G[36mCURL_MAX_TIME=%CURL_MAX_TIME%[0m
if %CURL_MAX_TIME% equ 0 set CURL_MAX_TIME=2

if not defined IPVS (
	set IPVS=4
	echo.[%pos%G[33mIPVS not defined[0m
)

set IPVS=4
echo.[%pos%G[36mIPVS=%IPVS%[0m
if %IPVS% equ 0 set IPVS=4

if defined ENABLE_HTTP if "x%ENABLE_HTTP%"=="x1" set strategy_file_lst=strategy_http.lst
if defined ENABLE_HTTP3 if "x%ENABLE_HTTP3%"=="x1" set strategy_file_lst=strategy_http3.lst
if defined ENABLE_HTTPS_TLS12 if "x%ENABLE_HTTPS_TLS12%"=="x1" set strategy_file_lst=strategy_https.lst
if defined ENABLE_HTTPS_TLS13 if "x%ENABLE_HTTPS_TLS13%"=="x1" set strategy_file_lst=strategy_https.lst
set /a foo=0
if defined ENABLE_HTTP if "x%ENABLE_HTTP%"=="x1" set /a foo+=1
if defined ENABLE_HTTPS_TLS12 if "x%ENABLE_HTTPS_TLS12%"=="x1" set /a foo+=1
if defined ENABLE_HTTP3 if "x%ENABLE_HTTP3%"=="x1" set /a foo+=1
if %foo% geq 2 (
	echo.[1G[[31mx[0m][%pos%GСканируем что-то одно из HTTP, HTTPS, HTTP3[0m
	echo.[1G[[33mi[0m][%pos%GБудет выбрано сканирование HTTPS
	set "strategy_file_lst=strategy_https.lst"
)
if "x%strategy_file_lst%"=="xstrategy_http.lst" (
	if not defined HTTP_PORT (
		set HTTP_PORT=80
		echo.[%pos%G[33mHTTP_PORT не указан, используем по-умолчанию [36mHTTP_PORT=80[0m
	) else echo.[%pos%G[36mHTTP_PORT=%HTTP_PORT%[0m
	
)
if "x%strategy_file_lst%"=="xstrategy_http3.lst" (
	if not defined QUIC_PORT (
		set QUIC_PORT=443
		echo.[%pos%G[33mQUIC_PORT не указан, используем по-умолчанию [36mQUIC_PORT=443[0m
	) else echo.[%pos%G[36mQUIC_PORT=%QUIC_PORT%[0m
)
if "x%strategy_file_lst%"=="xstrategy_https.lst" (
	if not defined HTTPS_PORT (
		set HTTPS_PORT=443
		echo.[%pos%G[33mHTTPS_PORT не указан, используем по-умолчанию [36mHTTPS_PORT=443[0m
	) else echo.[%pos%G[36mHTTPS_PORT=%HTTPS_PORT%[0m
	
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
	
	echo.[%pos%G[36mENABLE_HTTPS_TLS12=%ENABLE_HTTPS_TLS12%[0m
	echo.[%pos%G[36mENABLE_HTTPS_TLS13=%ENABLE_HTTPS_TLS13%[0m
	
)

if not defined REPEATS (
	set REPEATS=4
	echo.[%pos%G[33mREPEATS не указан, используем по-умолчанию [36mREPEATS=4[0m
) else echo.[%pos%G[36mREPEATS=%REPEATS%[0m
if %REPEATS% equ 0 set REPEATS=4

rem -----------------------

if defined CURL (
	echo.[%pos%G[36mCURL=%CURL%[0m
	if exist %home%\%CURL% (
		for /f "delims=" %%a in ('2^>nul %home%\%CURL% -V') do (
			set foo=%%a
			goto:@break_curl_1
		)
	)
)
:@break_curl_1
if "x!foo:~0,4!"=="xcurl" ( set CURL=%home%\%CURL% ) else ( set CURL=curl )

%CURL% -V >nul
if %errorlevel% neq 0 (
	echo.[1G[[31mx[0m][%pos%G[31mНе найден[0m 'curl'
	goto:@find_strategy_end
)

for /f "delims=" %%a in ('2^>nul %CURL% -V') do (
	set foo=%%a
	goto:@break_curl_2
)
:@break_curl_2

echo.[1G[[32m+[0m][%pos%GНайден 'curl': [33m%foo:~0,12%[0m

if "x%strategy_file_lst%"=="xstrategy_https.lst" (
	set curl_cmd_scan=--connect-to %DOMAINS%::[%ip_dom%]:%HTTPS_PORT% -ISs -A Mozilla --max-time %CURL_MAX_TIME% %TLSver% %TLSmax% https://%DOMAINS%
	set _PORT=%HTTPS_PORT%
	set _HTTP=HTTPS
)
if "x%strategy_file_lst%"=="xstrategy_http3.lst" (
	set curl_cmd_scan=--connect-to %DOMAINS%::[%ip_dom%]:%QUIC_PORT% -ISs -A Mozilla --max-time %CURL_MAX_TIME% --http3-only https://%DOMAINS%
	set _PORT=%QUIC_PORT%
	set _HTTP=QUIC
)
if "x%strategy_file_lst%"=="xstrategy_http.lst" (
	set curl_cmd_scan=--connect-to %DOMAINS%::[%ip_dom%]:%HTTP_PORT% -SsD %home%\bin\blk-hdr.txt -A Mozilla --max-time %CURL_MAX_TIME% http://%DOMAINS%
	set _PORT=%HTTP_PORT%
	set _HTTP=HTTP
)

if not exist %home%\strategy\%strategy_file_lst% (
	echo.[1G[[31mx[0m][%pos%G[31mОшибка.[0m Файл не найден: '[33m%homenc%\strategy\%strategy_file_lst%[0m'
	goto:@find_strategy_end
)

set /a line_count=1
for /F "skip=1 eol=#" %%a in (%home%\strategy\%strategy_file_lst%) do (
	set /a line_count+=1
	set comment_char=%%a
	set comment_char=!comment_char:~0,1!
	if not "x!comment_char!"=="x#" set /a find_strategy+=1
)

if %find_strategy% equ 0 (
	echo.[1G[[31mx[0m][%pos%GНет стратегий в файле '[33m%homenc%\strategy\%strategy_file_lst%[0m'
	goto:@find_strategy_end
)

echo.[1G[[33mi[0m][%pos%GПоиск IP: [33m%DOMAINS%[0m
for /f "delims=" %%a in ('2^>nul powershell -command "Invoke-WebRequest -Uri https://dns.google/resolve?name=%DOMAINS% | Select-Object Content | Format-List -Property *"') do (
	set "rtg=%%a"
	set "rtg=!rtg:~10!"
	set "Object_Content=!Object_Content!!rtg!"
)
if not defined Object_Content (
	echo.[1G[[31mx[0m][%pos%G[31mGОшибка поиска IP: [33m%DOMAINS%[0m
	goto:@find_strategy_end
)
for /f "tokens=4 delims={}" %%k in ("%Object_Content%") do (
	for /f "tokens=5 delims=:" %%a in ("%%~k") do set ip_dom=%%a
)
if not defined ip_dom (
	echo.[1G[[31mx[0m][%pos%G[31mОшибка обработки строки: [33m%Object_Content%[0m
	goto:@find_strategy_end
)

set ip_dom=%ip_dom:"=%
set ip_dom=%ip_dom: =%
echo.[1G[[32m+[0m][%pos%GНайден IP '[33m%DOMAINS%[0m': [[33m%ip_dom%[0m]

set "find_strategy_position_start="
for /f "delims=" %%I in ('2^>nul dir /b %home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.*') do set find_strategy_position_start=%%~xI
if not defined find_strategy_position_start set find_strategy_position_start=1
set find_strategy_position_start=%find_strategy_position_start:.=%
if %find_strategy_position_start% neq 1 (
	echo.[1G[[33mi[0m][%pos%GПредыдущий поиск был прерван на позиции '[33m%find_strategy_position_start%[0m', продолжим поиск.
)

if not exist %home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_start% echo.#>%home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_start%
for /F "skip=1" %%a in (%home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_start%) do set /a find_strategy_found+=1

set /a save_count = 600 / ( %REPEATS% * %CURL_MAX_TIME% )
set ext_old=%find_strategy_position_start%
set /a count_strategy_start=%find_strategy_position_start%

:@return_find
echo.
echo.[%pos%G[32mПоиск стратегии для [33m'%DOMAINS%'[0m [%ip_dom%][31m:%HTTPS_PORT%[0m
REM echo.
set "foo=| 0рогресс | 1екущий | 2сего | 3айдено | 4шибки запуска WinWS | 5шибки завершения процесса WinWS | 6од ответа Curl | 7EPEATS |"
for /l %%x in (0,1,160) do (
	if "x!foo:~%%x,1!"=="x" (
		set a=%%x
		goto:@br1538
	) else if "x!foo:~%%x,1!"=="x0" (
		set /a pos0=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x1" (
		set /a pos1=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x2" (
		set /a pos2=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x3" (
		set /a pos3=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x4" (
		set /a pos4=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x5" (
		set /a pos5=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x6" (
		set /a pos6=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x7" (
		set /a pos7=%pos%+%%x
	)
)
:@br1538
set /a a=%pos%+%a%-1
for /l %%x in (%pos%,1,%a%) do <nul set /p =[%%xG-
echo.
echo.[%pos%G^| Прогресс ^| Текущий ^| Всего ^| Найдено ^| Ошибки запуска WinWS ^| Ошибки завершения процесса WinWS ^| Код ответа Curl ^| REPEATS ^|
for /l %%x in (%pos%,1,%a%) do <nul set /p =[%%xG-
echo.[?25l
set /a line_count=1
call:progress_in_percent_begin %find_strategy%
<nul set /p =7
set "foo=0 Прогресс 1 Текущий 2 Всего 3 Найдено 4 Ошибки запуска WinWS 5 Ошибки завершения процесса WinWS 6 Код ответа Curl 7 REPEATS 8"
for /l %%x in (0,1,160) do (
	if "x!foo:~%%x,1!"=="x0" (
		set /a ipos0=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x1" (
		set /a ipos1=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x2" (
		set /a ipos2=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x3" (
		set /a ipos3=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x4" (
		set /a ipos4=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x5" (
		set /a ipos5=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x6" (
		set /a ipos6=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x7" (
		set /a ipos7=%pos%+%%x
	) else if "x!foo:~%%x,1!"=="x8" (
		set /a ipos8=%pos%+%%x
	)
)
echo.
for /l %%x in (%pos%,1,%a%) do <nul set /p =[%%xG-
echo.
echo.
echo.[1G[[33mi[0m][%pos%GПри прохождении каждой [33m%save_count%[0m-й (один раз в 10 минут) позиции мы запомним её для этих настроек поиска [[33m%DOMAINS%-%_PORT%-%_HTTP%[0m]
echo.[1G[[33mi[0m][%pos%GПоиск можно будет прервать, потом повторный поиск будет начат с прерванной позиции для этих настроек [[33m%DOMAINS%-%_PORT%-%_HTTP%[0m], кратно [33m%save_count%[0m
echo.[1G[[33mi[0m][%pos%GНайденные стратегии для этих настроек поиска сохраняются в файле '[33m%homenc%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.*[0m'
echo.[1G[[33mi[0m][%pos%GЕсли хотите начать поиск с начала закройте скрипт, удалите файл найденных стратегий '[33m%homenc%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.*[0m'
echo.
echo.[1G[[33mi[0m][%pos%GЕсли хотите сделать паузу и вернуться в меню, дождитесь '[36mREPEATS=%REPEATS%[0m' и нажимайте клавишу 'q' несколько раз[0m
echo.[1G[[33mi[0m][%pos%GВы можете вернуться обратно, поиск продолжится.[0m
echo.
echo.[1G[[33mi[0m][%pos%GЕсли вы выключите скрипт, то поиск будет начат с прерванной позиции, сохраненной в файле '[33m%homenc%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.*[0m'

for /F "skip=1 tokens=*" %%a in (%home%\strategy\%strategy_file_lst%) do (
	set /a line_count+=1
	set comment_char=%%a
	set comment_char=!comment_char:~0,1!
	if not "x!comment_char!"=="x#" (
		set /a count_strategy+=1
		if !count_strategy! gtr %count_strategy_start% (
			set /a count_strategy_save+=1
			set "L_str="
			set "R_str="
			for /F "tokens=1,2 delims=!" %%o in ("%%a") do (
				set "L_str=%%o"
				set "R_str=%%p"
			)
			set "L1_str="
			set "L2_str="
			for /F "tokens=1,2 delims=@" %%o in ("!L_str!") do (
				set "L1_str=%%o"
				set "L2_str=%%p"
			)
			if defined L2_str set "L_str=!L1_str!%fakedir%\!L2_str!"
			
			if defined R_str (
				set "R1_str="
				set "R2_str="
				for /F "tokens=1,2 delims=@" %%o in ("!R_str!") do (
					set "R1_str=%%o"
					set "R2_str=%%p"
				)
				if defined R2_str set "R_str=!R1_str!%fakedir%\!R2_str!"
			)
			if defined R_str (
				%winwsdir%\winws.exe --daemon !L_str!^^! !R_str!  1>nul 2>&1
			) else (
				%winwsdir%\winws.exe --daemon !L_str!  1>nul 2>&1
			)
			set winws_ret_code=!errorlevel!
			if %find_strategy_debug% equ 1 (
				if !winws_ret_code! neq 0 (
					if defined R_str (
						echo.Line[!line_count!]: %winwsdir%\winws.exe --dry-run !L_str!^^! !R_str! >>%home%\winws_error_code
					) else (
						echo.Line[!line_count!]: %winwsdir%\winws.exe --dry-run !L_str!>>%home%\winws_error_code
					)
				)
			)
			call:@check_run
			if !errorlevel! equ 0 (
				set _REPEATS=0
				set /a repne_tamper=0
				for /l %%c in (1,1,%REPEATS%) do (
					set /a _REPEATS+=1
					set curl_ret_code=0
					%CURL% %curl_cmd_scan% 1>nul 2>&1
					set curl_ret_code=!errorlevel!
					if !curl_ret_code! equ 0 (
						set /a repne_tamper+=1
						if !repne_tamper! equ 1 (
							set /a find_strategy_found+=1
							if defined R_str (
								echo.!L_str!^^! !R_str! >>%home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.!ext_old!
							) else (
								echo.!L_str! >>%home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.!ext_old!
							)
						)
					)
					if !_REPEATS! equ 1 call:progress_in_percent_count ap2
					<nul set /p =8[2K[%ipos0%G^|[%pos0%G!ap2!%%[%ipos1%G^|[%pos1%G!count_strategy![%ipos2%G^|[%pos2%G%find_strategy%[%ipos3%G^|[%pos3%G!find_strategy_found![%ipos4%G^|[%pos4%G!find_strategy_kill_error![%ipos5%G^|[%pos5%G!find_strategy_run_error![%ipos6%G^|[%pos6%G!curl_ret_code![%ipos7%G^|[%pos7%G!_REPEATS![%ipos8%G^|[8m
				)
				call:@check_kill 
				if !errorlevel! neq 0 set /a find_strategy_kill_error+=1
			) else set /a find_strategy_run_error+=1
			if !count_strategy_save! equ %save_count% (
				move /Y %home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.!ext_old! %home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.!count_strategy! 1>nul 2>&1
				set ext_old=!count_strategy!
				set /a count_strategy_save=0
			)
			choice /N /C:qйp /D p /T 1
			if !errorlevel! EQU 255 goto:@find_strategy_end
			if !errorlevel! EQU 0 goto:@find_strategy_end
			if !errorlevel! EQU 1 goto:@find_strategy_end
			if !errorlevel! EQU 2 goto:@find_strategy_end
		) else (
			set /a count_strategy_save+=1
			if !count_strategy_save! equ %save_count% set /a count_strategy_save=0
			call:progress_in_percent_count ap2
			<nul set /p =8[2K[%ipos0%G^|[%pos0%G!ap2!%%[%ipos1%G^|[%pos1%G!count_strategy![%ipos2%G^|[%pos2%G%find_strategy%[%ipos3%G^|[%pos3%G!find_strategy_found![%ipos4%G^|[%pos4%G!find_strategy_kill_error![%ipos5%G^|[%pos5%G!find_strategy_run_error![%ipos6%G^|[%pos6%G!curl_ret_code![%ipos7%G^|[%pos7%G!_REPEATS![%ipos8%G^|[8m
		)
	)
)
<nul set /p =8[2K[%ipos0%G^|[%pos0%G100%%[%ipos1%G^|[%pos1%G!count_strategy![%ipos2%G^|[%pos2%G%find_strategy%[%ipos3%G^|[%pos3%G!find_strategy_found![%ipos4%G^|[%pos4%G!find_strategy_kill_error![%ipos5%G^|[%pos5%G!find_strategy_run_error![%ipos6%G^|[%pos6%G [%ipos7%G^|[%pos7%G [%ipos8%G^|
move /Y %home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.!ext_old! %home%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.done 1>nul 2>&1
echo.[10E[0m
echo.
echo.[%pos%GГотово
echo.
if !find_strategy_found! neq 0 (
	echo.[%pos%GНайдено стратегий: !find_strategy_found!
	echo.[%pos%GОписание стратегий в файле '%homenc%\strategy\%DOMAINS%-%_PORT%-%_HTTP%.done'
)
echo.
goto:@find_strategy_end1

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
goto:@find_strategy_end1
:@find_strategy_end
echo.[10E
pause >nul
echo.[0m
echo.[?25h
goto:menu
:@find_strategy_end1
echo.
echo.[?25h
echo.[%pos%GНажмите любую клавишу для возврата в меню.
pause >nul
goto:menu

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
	echo.# 
	echo.# CURL_MAX_TIME - РІСЂРµРјСЏ С‚Р°Р№РјР°СѓС‚Р° curl РІ СЃРµРєСѓРЅРґР°С…
	echo.
	echo.# CURL_MAX_TIME=2
	echo.# 
	echo.# CURL_MAX_TIME_QUIC - РІСЂРµРјСЏ С‚Р°Р№РјР°СѓС‚Р° curl РґР»СЏ quic. РµСЃР»Рё РЅРµ Р·Р°РґР°РЅРѕ, РёСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ Р·РЅР°С‡РµРЅРёРµ CURL_MAX_TIME
	echo.# CURL_MAX_TIME_DOH - РІСЂРµРјСЏ С‚Р°Р№РјР°СѓС‚Р° curl РґР»СЏ DoH СЃРµСЂРІРµСЂРѕРІ
	echo.# CURL_CMD=1 - РїРѕРєР°Р·С‹РІР°С‚СЊ РєРѕРјР°РЅРґС‹ curl
	echo.# CURL_OPT - РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹ curl. `-k` - РёРіРЅРѕСЂ СЃРµСЂС‚РёС„РёРєР°С‚РѕРІ. `-v` - РїРѕРґСЂРѕР±РЅС‹Р№ РІС‹РІРѕРґ РїСЂРѕС‚РѕРєРѕР»Р°
	echo.
	echo.#CURL_OPT=-v
	echo.# 
	echo.# IPVS=4^|6^|46 - С‚РµСЃС‚РёСЂСѓРµРјС‹Рµ РІРµСЂСЃРёРё ip РїСЂРѕС‚РѕРєРѕР»Р°
	echo.
	echo IPVS=4
	echo.# 
	echo.# ENABLE_HTTP=0^|1 - РІРєР»СЋС‡РёС‚СЊ С‚РµСЃС‚ plain http
	echo.
	echo ENABLE_HTTP=0
	echo.# 
	echo.# ENABLE_HTTPS_TLS12=0^|1 - РІРєР»СЋС‡РёС‚СЊ С‚РµСЃС‚ https TLS 1.2
	echo.
	echo ENABLE_HTTPS_TLS12=1
	echo.# 
	echo.# ENABLE_HTTPS_TLS13=0^|1 - РІРєР»СЋС‡РёС‚СЊ С‚РµСЃС‚ https TLS 1.3
	echo.
	echo ENABLE_HTTPS_TLS13=0
	echo.# 
	echo.# ENABLE_HTTP3=0^|1 - РІРєР»СЋС‡РёС‚СЊ С‚РµСЃС‚ QUIC
	echo.
	echo ENABLE_HTTP3=0
	echo.# 
	echo.# REPEATS - РєРѕР»РёС‡РµСЃС‚РІРѕ РїРѕРїС‹С‚РѕРє С‚РµСЃС‚РёСЂРѕРІР°РЅРёСЏ
	echo.
	echo REPEATS=4
	echo.# 
	echo.# PARALLEL=0^|1 - РІРєР»СЋС‡РёС‚СЊ РїР°СЂР°Р»Р»РµР»СЊРЅС‹Рµ РїРѕРїС‹С‚РєРё. РјРѕР¶РµС‚ РѕР±РёРґРµС‚СЊ СЃР°Р№С‚ РёР·-Р·Р° РґРѕР»Р±РµР¶РєРё Рё РїСЂРёРІРµСЃС‚Рё Рє РЅРµРІРµСЂРЅРѕРјСѓ СЂРµР·СѓР»СЊС‚Р°С‚Сѓ
	echo.
	echo PARALLEL=0
	echo.# 
	echo.# SCANLEVEL=quick^|standard^|force - СѓСЂРѕРІРµРЅСЊ СЃРєР°РЅРёСЂРѕРІР°РЅРёСЏ
	echo. 
	echo SCANLEVEL=standard
	echo.# 
	echo.# BATCH=1 - РїР°РєРµС‚РЅС‹Р№ СЂРµР¶РёРј Р±РµР· РІРѕРїСЂРѕСЃРѕРІ Рё РѕР¶РёРґР°РЅРёСЏ РІРІРѕРґР° РІ РєРѕРЅСЃРѕР»Рё
	echo.
	echo BATCH=1
	echo.# 
	echo.# HTTP_PORT, HTTPS_PORT, QUIC_PORT - РЅРѕРјРµСЂР° РїРѕСЂС‚РѕРІ РґР»СЏ СЃРѕРѕС‚РІРµС‚СЃС‚РІСѓСЋС‰РёС… РїСЂРѕС‚РѕРєРѕР»РѕРІ
	echo.
	echo HTTPS_PORT=443
	echo.# 
	echo.# SKIP_DNSCHECK=1 - РѕС‚РєР°Р· РѕС‚ РїСЂРѕРІРµСЂРєРё DNS
	echo.
	echo SKIP_DNSCHECK=0
	echo.# 
	echo.# SKIP_IPBLOCK=1 - РѕС‚РєР°Р· РѕС‚ С‚РµСЃС‚РѕРІ Р±Р»РѕРєРёСЂРѕРІРєРё РїРѕ РїРѕСЂС‚Сѓ РёР»Рё IP
	echo.# SKIP_TPWS=1 - РѕС‚РєР°Р· РѕС‚ С‚РµСЃС‚РѕРІ tpws
	echo.
	echo SKIP_TPWS=0
	echo.# 
	echo.# SKIP_PKTWS=1 - РѕС‚РєР°Р· РѕС‚ С‚РµСЃС‚РѕРІ nfqws/dvtws/winws
	echo.# PKTWS_EXTRA, TPWS_EXTRA - РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹ nfqws/dvtws/winws Рё tpws, СѓРєР°Р·С‹РІР°РµРјС‹Рµ РїРѕСЃР»Рµ РѕСЃРЅРѕРІРЅРѕР№ СЃС‚СЂР°С‚РµРіРёРё
	echo.
	echo #PKTWS_EXTRA='user strategy for test'
	echo #PKTWS_EXTRA='--wf-tcp=80 --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig'
	echo.# 
	echo.# PKTWS_EXTRA_1 .. PKTWS_EXTRA_9, TPWS_EXTRA_1 .. TPWS_EXTRA_9 - РѕС‚РґРµР»СЊРЅРѕ РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹, СЃРѕРґРµСЂР¶Р°С‰РёРµ РїСЂРѕР±РµР»С‹
	echo.# PKTWS_EXTRA_PRE - РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹ РґР»СЏ nfqws/dvtws/winws, СѓРєР°Р·С‹РІР°РµРјС‹Рµ РїРµСЂРµРґ РѕСЃРЅРѕРІРЅРѕР№ СЃС‚СЂР°С‚РµРіРёРµР№
	echo.# PKTWS_EXTRA_PRE_1 .. PKTWS_EXTRA_PRE_9 - РѕС‚РґРµР»СЊРЅРѕ РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Рµ РїР°СЂР°РјРµС‚СЂС‹, СЃРѕРґРµСЂР¶Р°С‰РёРµ РїСЂРѕР±РµР»С‹
	echo.# SECURE_DNS=0^|1 - РїСЂРёРЅСѓРґРёС‚РµР»СЊРЅРѕ РІС‹РєР»СЋС‡РёС‚СЊ РёР»Рё РІРєР»СЋС‡РёС‚СЊ DoH
	echo.
	echo SECURE_DNS=1
	echo.# 
	echo.# DOH_SERVERS - СЃРїРёСЃРѕРє URL DoH С‡РµСЂРµР· РїСЂРѕР±РµР» РґР»СЏ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРѕРіРѕ РІС‹Р±РѕСЂР° СЂР°Р±РѕС‚Р°СЋС‰РµРіРѕ СЃРµСЂРІРµСЂР°
	echo.# DOH_SERVER - РєРѕРЅРєСЂРµС‚РЅС‹Р№ DoH URL, РѕС‚РєР°Р· РѕС‚ РїРѕРёСЃРєР°
	echo.# UNBLOCKED_DOM - РЅРµР·Р°Р±Р»РѕРєРёСЂРѕРІР°РЅРЅС‹Р№ РґРѕРјРµРЅ, РєРѕС‚РѕСЂС‹Р№ РёСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ РґР»СЏ С‚РµСЃС‚РѕРІ IP block
	echo.# 
	echo.# DOMAINS - СЃРїРёСЃРѕРє С‚РµСЃС‚РёСЂСѓРµРјС‹С… РґРѕРјРµРЅРѕРІ С‡РµСЂРµР· РїСЂРѕР±РµР»
	echo.
	echo DOMAINS="ntc.party"
	echo.# 
	)>%home%\blockcheck.config.txt
)
chcp 1251 >nul
exit /b