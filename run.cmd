@echo off
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
for %%i in ("%home%") do set "home=%%~si"
for /L %%i in (1000,-1,1) do (
	if not "x!home:~%%i,1!"=="x" (
		set /a homestrsize=%%i + 2
		goto:@break_homestrsize
	)
)
:@break_homestrsize
if not exist %home%\script\run_agent.cmd (
	echo.Запуск из архива без распаковки? 
	echo.Выход.
	echo.
	pause
	exit
)
set "fakedir="
set /a profile_count=0
set "arg_1=%~1"
set "arg_2=%~2"
set "arg_3=%~3"

net session >nul 2>&1
if %errorLevel% neq 0 ( 
	echo.Для некоторых действий сценария необходимы высокие привилегии, запустите скрипт с правами 'Администратора'.
	echo.Выход.
	echo.
	pause
	exit
)
mode con: cols=%mode_con_cols% lines=%mode_con_lines%
powershell -command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$B.width=%mode_con_cols%;$B.height=9999;$W.buffersize=$B;}" 1>nul 2>&1
set "arch="
for /f "skip=2 delims=" %%i in ('2^>nul powershell -Command "Get-CimInstance Win32_operatingsystem ^| select OSArchitecture"') do set "arch=%%i"
if "x%arch:~0,2%"=="x32" ( set "arch=windows-x86" ) else ( set "arch=windows-x86_64" )
set "foo="
set "winwsdir="
for /f "delims=" %%I in ('2^>nul dir /b /s /a:d %home%\bin\%arch%') do set "winwsdir=%%~I"
if defined winwsdir (
	if not exist %winwsdir%\winws.exe (
		set "winwsdir="
	) else (
		for /f "delims=" %%I in ('%winwsdir%\winws.exe --version') do set "foo=%%I"
	)
)
echo.]0;Bypassing Censorship %foo%
echo.[39;49m

:menu
cls
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
echo.[32mAuto Refresh screen every 60 sec.[0m
set /a srv_menu_count=1000
set /a strategy_menu_count=1000
set /a parameter_menu_count=1000
set /a agent_work=1000
set /a terminate_count=1000
set /a blockcheck_menu_count=1000
set /a menu_choice=1000
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
tasklist /FI "IMAGENAME eq 3proxy.exe" | find /I "3proxy.exe" > nul
if %errorlevel% equ 0 (
	echo.[37mSOCKS[31m5 [32mON[0m
	set /a socks5=1
) else echo.
echo.Секундочку...
set /a foo=0
for /f "tokens=1,2 delims=," %%a in ('2^>nul tasklist /FI "IMAGENAME eq winws.exe" /fo csv /nh') do (
	if "x%%~a"=="xwinws.exe" (
		set /a foo=!foo!+1
		set "winws_pid!foo!=%%~b"
	)
)

set "strategy_run="
set /a profile_count=0
set "commandline="
set "daemon_status="
set "debug_status="
if %foo% GTR 0 ( 
	for /l %%m in (1,1,%foo%) do (
		for /f "tokens=* delims=" %%a in ('2^>nul powershell -Command "Get-WmiObject win32_process -Filter 'ProcessId ^= !winws_pid%%m!' ^| select commandline ^| Format-List -Property *"') do (
			set "rtg=%%a"
			set "rtg=!rtg:~14!"
			set "commandline=!commandline!!rtg!"
		)
		set "commandline%%m=!commandline!"
		set "commandline="
	)
	
	for /l %%m in (1,1,%foo%) do (
		for /f "tokens=2-7 delims=[]" %%a in ("!commandline%%m!") do (
			set /a profile_count=!profile_count!+1
			set "n!profile_count!=%%~a"
			set "custom_str=%%~b"
			set "ip!profile_count!=%%~c"
			set "pr!profile_count!=%%~d"
			set "pid!profile_count!=!winws_pid%%m!"
			set "daemon_status=%%~e"
			set "debug_status=%%~f"
		)
	)
	
)
echo.[1F[2K
set /a about_pid_strsize=%c8%-%c4%
set /a check_restart_str=0
if %profile_count% GTR 0 ( 
	for /l %%i in (1,1,%profile_count%) do (
		if %%i EQU 1 (
			for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
			echo.
			if not "x%daemon_status%"=="x%daemon%" set /a check_restart_str=!check_restart_str!+1
			if not "x%debug_status%"=="x%debug%" set /a check_restart_str=!check_restart_str!+1
			if not "x%custom_str%"=="x%custom_strategy%" set /a check_restart_str=!check_restart_str!+1
			if not "x%ip1%"=="x%IPsetStatus%" set /a check_restart_str=!check_restart_str!+1
			if !check_restart_str! neq 0 (
				echo.
				echo.[%c1%G[31mПараметры изменены. [%c4%GДля применения новых параметров перезапустите стратегию[0m
				echo.
			)
			echo.[%c1%GРаботает стратегия:[%c4%G[0m!n%%i!
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
			for /l %%x in (1,1,!foo!) do <nul set /p =[30m-[0m
			for /l %%x in (%c4%,1,%c8%) do <nul set /p =[%%xG-
			echo.
		)
		echo.[%c1%GPID: !pid%%i![%c4%G[36m!pr%%i![0m
	)
	for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
	echo.
	set "strategy_run=!n1!" 
) else (
	for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
	echo.
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

set /a menu_count=0
rem ------------------------------------------------------------------------------------
set /a foo=%c1%-1
echo.[%foo%G[33m[..][%c2%G[33mПара[36mм[33mетры запуска стратегии[0m
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
	set /a menu_count=!menu_count!+1
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
	set /a menu_count=!menu_count!+1
	echo.[%c1%G[37m!menu_count!.[%c2%GПоказывать ход работы в окне[%c5%G[[3!foo!m!offon![0m] [31m!atten![0m
	set /a menu_count=!menu_count!+1
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
	set /a menu_count=!menu_count!+1
	echo.[%c1%G[37m!menu_count!.[%c2%GИспользовать список IP[%c5%G[[3!foo!m!offon![0m]
	echo.
)
REM for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
REM echo.
rem ------------------------------------------------------------------------------------
set /a foo=%c1%-1
set /a about_strategy_strsize=%c8%-%c5%

if %strategy_trigger% equ 0 (
	echo.[%foo%G[33m[..][%c2%G[36mС[33mтратегии[0m
) else ( 
	echo.[%foo%G[33m[..][%c2%G[36mС[33mтратегии[%c5%GОписание[0m
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
				set /a menu_count=!menu_count!+1
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
	echo.
)
if %foo% equ 0 ( 
	echo.[%c2%G[31mСтратегии не найдены. [0m
	echo.[%c2%G[33mДобавьте файлы стратегий в папку '[37m..\strategy\[0m'
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
echo.[%foo%G[33m[..][%c2%G[36mА[33mвтоматизация[0m
if %srv_trigger% neq 0 ( 
	set /a srv_menu_count=%menu_count%+1
	if %task% EQU 0 (
		powershell -Command "Get-WmiObject win32_process -Filter 'name = \"cmd.exe\"' | select commandline" |find "run_agent.cmd" 1>nul 2>&1
		if !errorlevel! EQU 0 (
			if exist %home%\agent.log (
				rem last status
			 	for /f "delims=" %%i in (%home%\agent.log) do set "foo=%%i"			
			) else set "foo=.........неизвестное состояние..."
			echo.[%c2%G[36m[[0m агент : [32mвключен[%c8%G[36m][0m
			echo.[%c2%G[36m[[0m статус: [33m!foo:~9![%c8%G[36m][0m
			set /a agent_work=1
		) else (
			echo.[%c2%G[36m[[0m агент : [31mвыключен[%c8%G[36m][0m
			echo.[%c2%G[33mДля запуска агента выполнить задание [37m'dpiagent'[33m в планировщике заданий[0m
			set /a agent_work=0
		)
		if !agent_work! equ 1 (
			if not "x!agent_mode!"=="xstart" (
				set /a menu_count=!menu_count!+1
				echo.[%c2%G[37m!menu_count!.[%c3%GОтправить агенту сигнал '[32mстарт[37m'[0m
			)
			if not "x!agent_mode!"=="xstop" (
				set /a menu_count=!menu_count!+1
				echo.[%c2%G[37m!menu_count!.[%c3%GОтправить агенту сигнал '[31mстоп[37m'[0m
			)
		)
		set /a menu_count=!menu_count!+1
		echo.[%c2%G[37m!menu_count!.[%c3%G[31mУдалить автоматизацию[0m
	) else (
		echo.[%c2%G[36m[[0m задача в планировщике заданий: [31mотсутствует[%c8%G[36m][0m
		if defined strategy_run (
			set /a menu_count=!menu_count!+1
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
	set /a terminate_count=%menu_count% + 1
	set /a menu_count=!menu_count!+1
	echo.[%c1%G[37m!menu_count!.[%c2%G[33mЗав[36mе[33mршить мульти-стратегию '[0m!strategy_run![33m'[0m
	if %term_trigger% neq 0 ( 
		echo.[%c2%G[33mили отдельные профили ниже:
		for /l %%i in (1,1,%profile_count%) do (
			set /a menu_count=!menu_count!+1
			rem echo.[%c2%G[37m!menu_count!.[36m[%c3%G !pr%%i:~0,%about_kill_strsize%! [0m
			echo.[%c2%G[37m!menu_count!.[36m[%c3%G!pr%%i![0m
		)
		echo.
	)
	REM for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
	REM echo.
)
rem ------------------------------------------------------------------------------------
if exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh (
	for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xG-
	echo.
	set /a menu_count=!menu_count!+1
	set /a blockcheck_menu_count=!menu_count!
	echo.[%c1%G[37m!menu_count!.[%c2%GBlockcheck[0m
)
echo.
echo.[%c1%G0.[%c2%GВыход
echo.
set "strchoice=0123456789rcсafфаetеуmьvм"
REM cс		- 'С'тратегии
REM afфа	- 'А'втоматизация
REM etеу	- Зав'е'ршить стратегию
REM mьvм	- Пара'м'етры

choice /N /C:%strchoice% /D r /T 60 /M "#:"
if %errorlevel% EQU 255 call:cerror 316
if %errorlevel% EQU 0 call:cerror 317
REM if %errorlevel% GEQ 26 goto:...
if %errorlevel% GEQ 22 goto:param_trigger
if %errorlevel% GEQ 18 goto:terminate_trigger
if %errorlevel% GEQ 14 goto:srv_menu_trigger
if %errorlevel% GEQ 12 goto:expand_strategy
if %errorlevel% EQU 11 goto:menu
set /a first_digit=%errorlevel% - 1
echo.[2F
choice /N /C:0123456789z /D z /T 3 /M "#:"
if %errorlevel% EQU 255 call:cerror 329
if %errorlevel% EQU 0 call:cerror 330
if %errorlevel% EQU 11 (
	set /a menu_choice=%first_digit%
) else (
	set /a second_digit=%errorlevel% - 1
	set /a menu_choice=%first_digit% * 10
	set /a menu_choice=!menu_choice! + !second_digit!
)
echo.[1F[2K
echo.
if %menu_choice% equ 0 goto:menu_0
if %menu_choice% EQU %blockcheck_menu_count% goto:blockcheck
if %menu_choice% GTR %menu_count% goto:menu
if %terminate_count% neq 1000 if %menu_choice% GEQ %terminate_count% goto:terminate
if %srv_menu_count% neq 1000 if %menu_choice% GEQ %srv_menu_count% goto:menu_srv
if %strategy_menu_count% neq 1000 if %menu_choice% GEQ %strategy_menu_count% goto:strategy_choice
if %parameter_menu_count% neq 1000 if %menu_choice% GEQ %parameter_menu_count% goto:menu_%menu_choice%
goto:menu

:strategy_choice
if "x!strategy_count_name%menu_choice%!"=="x" goto:menu
set "strategy_name=!strategy_count_name%menu_choice%!"
set "strategy_apath=!strategy_name_spath%menu_choice%!"
:strategy_list
if "x%strategy_name%"=="x" (
	echo.strategy_name=none
	pause
	goto:menu
)

:terminate
if not defined strategy_run goto:terminate_done
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
set "strategy_run="
if "x%arg_1%"=="xstart" goto:terminate_done
if "x%arg_1%"=="xstop" goto:terminate_done
if %menu_choice% neq 1000 if %menu_choice% EQU %terminate_count% (
	call:cecho 2 "Готово"
	echo.
	echo.>%home%\bin\agent_update_status
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
if not exist %winwsdir%\winws.exe (
	echo.
	echo.[5G[37mDownload developers code, unzip and put in '[33m%home%\bin\[37m' from: [0m
	echo.
	echo.[5Ghttps://github.com/bol-van/zapret/releases
	echo.
	pause
	goto:menu
)
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
call:cecho x3 "Парсинг параметров, см." "..\strategy\%strategy_name%\log\"
set /a pcount=0
set /a scount=0
call:@parse_str "%strategy_apath%" "..\strategy\%strategy_name%"
if "x%custom_strategy%"=="xon" (
	if not exist %strategy_apath%\custom md %strategy_apath%\custom >nul
	call:@parse_str "%strategy_apath%\custom" "..\strategy\%strategy_name%\custom"
)

if %pcount% equ 0 goto:@nulpcount
call:cecho x3 "Создано профилей:" "'%scount%'"
for /f "delims=" %%I in ('%winwsdir%\winws.exe --version') do set "foo=%%I"
set foo=%foo:(=[%
set foo=%foo:)=]%
call:cecho x3x "Windivert" "'%foo%'" "initialized"
set /a scount=0
if %pcount% neq 0 call:cecho x3 "Запуск" "'%strategy_name%'"
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
		if !errorlevel! neq 0 goto:strategy_list_arg_error
		%winwsdir%\winws.exe --wf-save="%strategy_apath%\log\!name_strategy_file_parse_ok%%i!-save.raw" !wsarg! 2>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-wf-save-status-err.log" 1>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-wf-save-status.log"
	if "x%daemon%"=="xoff" (
		echo.start "%strategy_name%:[!sabout!] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] Debug:[%debug%]" %winwsdir%\winws.exe !wsdebug! !wscomment! !wsarg! >>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-cmd.bat.example"
		start "%strategy_name%:[!sabout!] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] Debug:[%debug%]" %winwsdir%\winws.exe !wsdebug! !wscomment! !wsarg!
	)
	if "x%daemon%"=="xon" (
		echo.%winwsdir%\winws.exe !wsdebug! !wsdaemon! !wscomment! !wsarg! >>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-cmd.bat.example"
		%winwsdir%\winws.exe !wsdebug! !wsdaemon! !wscomment! !wsarg! 2>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-status-err.log" 1>>%strategy_apath%\log\"!name_strategy_file_parse_ok%%i!-run-status.log"
		if !errorlevel! neq 0 goto:strategy_list_arg_error
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
if "x%daemon%"=="xon" set /a foo=!foo!+1000
if "x%debug%"=="xon" set /a foo=!foo!+100
if "x%custom_strategy%"=="xon" set /a foo=!foo!+10
if "x%IPsetStatus%"=="xon" set /a foo=!foo!+1
set agent_start_strategy="%strategy_name%"
set /a agent_start_params=%foo%
call:sconfig
echo.>%home%\bin\agent_update_status
REM for /l %%x in (5,-1,1) do (
	REM echo.[F
	REM <nul set /p =[5G[37mВозврат в меню через [32m%%x[37m с.[0m
	REM timeout /T 1 /NOBREAK >nul
REM )
:strategy_list_exit
echo.
pause
goto:menu
:error_arg3
set /a ecode=1
echo.[5G[31mНеверный аргумент #3: [37m'[33m%arg_3%[37m'[0m]
goto:strategy_list_end
:strategy_list_arg_error
call:cecho 1x3 "Ошибка." "Подробности смотри в" "'..\strategy\%strategy_name%\log\%scount%-%foo%-err.log'"
set /a ecode=1
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
pause
goto:menu_0

:blockcheck
echo.
if not exist %home%\bin\zapret-win-bundle-master\cygwin\bin\bash.exe (
	echo.[5G[31mОшибка. [37mФайл не найден: '[33m%home%\bin\zapret-win-bundle-master\cygwin\bin\bash[37m'[0m
	goto:err_blockcheck
)
if not exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh (
	echo.[5G[31mОшибка. [37mФайл не найден: '[33m%home%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh[37m'[0m
:err_blockcheck
	echo.
	echo.[5G[37mfor use blockcheck download developers code, unzip and put in '[33m%home%\bin\[37m': [0m
	echo.
	echo.[5Ghttps://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip
	echo.
	pause
	goto:menu
)

if not exist %home%\lists\blockcheck.txt (
	echo.[5G[37mДобавьте в '[33m%home%\lists\blockcheck.txt[37m' домены для сканирования.[0m
	(
		echo.# one domain per line
		echo.#
		echo.#amnezia.org
		echo.#discord.com
		echo.#...
		echo.#
		echo.discord.com
	)>%home%\lists\blockcheck.txt
	pause
	goto:menu
)
if defined strategy_run goto:terminate_all

rem - https://github.com/bol-van/zapret?tab=readme-ov-file#%D0%BF%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%BA%D0%B0-%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D0%B0
REM CURL - замена программы curl
REM CURL_MAX_TIME - время таймаута curl в секундах
REM CURL_MAX_TIME_QUIC - время таймаута curl для quic. если не задано, используется значение CURL_MAX_TIME
REM CURL_MAX_TIME_DOH - время таймаута curl для DoH серверов
REM CURL_CMD=1 - показывать команды curl
REM CURL_OPT - дополнительные параметры curl. `-k` - игнор сертификатов. `-v` - подробный вывод протокола
REM DOMAINS - список тестируемых доменов через пробел
REM IPVS=4|6|46 - тестируемые версии ip протокола
REM ENABLE_HTTP=0|1 - включить тест plain http
REM ENABLE_HTTPS_TLS12=0|1 - включить тест https TLS 1.2
REM ENABLE_HTTPS_TLS13=0|1 - включить тест https TLS 1.3
REM ENABLE_HTTP3=0|1 - включить тест QUIC
REM REPEATS - количество попыток тестирования
REM PARALLEL=0|1 - включить параллельные попытки. может обидеть сайт из-за долбежки и привести к неверному результату
REM SCANLEVEL=quick|standard|force - уровень сканирования
REM BATCH=1 - пакетный режим без вопросов и ожидания ввода в консоли
REM HTTP_PORT, HTTPS_PORT, QUIC_PORT - номера портов для соответствующих протоколов
REM SKIP_DNSCHECK=1 - отказ от проверки DNS
REM SKIP_IPBLOCK=1 - отказ от тестов блокировки по порту или IP
REM SKIP_TPWS=1 - отказ от тестов tpws
REM SKIP_PKTWS=1 - отказ от тестов nfqws/dvtws/winws
REM PKTWS_EXTRA, TPWS_EXTRA - дополнительные параметры nfqws/dvtws/winws и tpws, указываемые после основной стратегии
REM PKTWS_EXTRA_1 .. PKTWS_EXTRA_9, TPWS_EXTRA_1 .. TPWS_EXTRA_9 - отдельно дополнительные параметры, содержащие пробелы
REM PKTWS_EXTRA_PRE - дополнительные параметры для nfqws/dvtws/winws, указываемые перед основной стратегией
REM PKTWS_EXTRA_PRE_1 .. PKTWS_EXTRA_PRE_9 - отдельно дополнительные параметры, содержащие пробелы
REM SECURE_DNS=0|1 - принудительно выключить или включить DoH
REM DOH_SERVERS - список URL DoH через пробел для автоматического выбора работающего сервера
REM DOH_SERVER - конкретный DoH URL, отказ от поиска
REM UNBLOCKED_DOM - незаблокированный домен, который используется для тестов IP block
chcp 65001 >nul
set "foo="
for /F "eol=# skip=1 delims=" %%a in (%home%\lists\blockcheck.txt) do (
	set "ta=%%~a"
	set "ta=!ta: =!"
	if "x!foo!"=="x" ( set "foo=!ta!" ) else ( set "foo=!foo! !ta!" )
)

(
	echo SKIP_TPWS=0
	echo SKIP_DNSCHECK=0
	echo SECURE_DNS=1
	echo IPVS=4
	echo ENABLE_HTTP=0
	echo HTTPS_PORT=443
	echo ENABLE_HTTPS_TLS12=1
	echo ENABLE_HTTPS_TLS13=0
	echo ENABLE_HTTP3=0
	echo REPEATS=4
	echo PARALLEL=0
	rem echo SCANLEVEL=standard
	echo SCANLEVEL=quick
	echo BATCH=1
	rem echo PKTWS_EXTRA='user strategy for test'
	rem echo PKTWS_EXTRA='--wf-tcp=80 --dpi-desync=fake,split2 --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig'
	echo DOMAINS="!foo!"
)>%home%\bin\zapret-win-bundle-master\blockcheck\zapret\config_win
chcp 1251 >nul
if exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\config del /F /Q %home%\bin\zapret-win-bundle-master\blockcheck\zapret\config

rem CRLF to LF
rem ----------------- http://stackoverflow.com/a/6379861/1012053
(set LF=^
%=EMPTY=%
)
for /F "delims=" %%a in (%home%\bin\zapret-win-bundle-master\blockcheck\zapret\config_win) do (
	<nul set /p =%%a!LF!>>%home%\bin\zapret-win-bundle-master\blockcheck\zapret\config
)
rem ----------------- http://stackoverflow.com/a/6379861/1012053

start %home%\bin\zapret-win-bundle-master\cygwin\bin\bash -i "%home%\bin\zapret-win-bundle-master\blockcheck\zapret\blog.sh"
echo.[5G[37mСканирование доменов из листа '[33m%home%\lists\blockcheck.txt[37m' запущено.[0m
echo.[5G[37mОтчет работы сохраняется в файл '[33m%home%\zapret-win-bundle-master\blockcheck\blockcheck.log[37m'[0m
echo.
REM for /l %%x in (5,-1,1) do (
	REM echo.[F
	REM <nul set /p =[5G[37mВозврат в меню через [32m%%x[37m с.[0m
	REM timeout /T 1 /NOBREAK >nul
REM )
pause
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
	if not "x!bitmask:~%%a,1!"=="x" set "bm%%a=3!bitmask:~%%a,1!"
	if "x!bitmask:~%%a,1!"=="xx" set "bm%%a=0"
)
if not "x%~9"=="x" (
	echo.[%curtime%][%c3%G[%bm0%m%~2 [%bm1%m%~3 [%bm2%m%~4 [%bm3%m%~5 [%bm4%m%~6 [%bm5%m%~7 [%bm6%m%~8 [%bm7%m%~9[0m
) else if not "x%~8"=="x" (
	echo.[%curtime%][%c3%G[%bm0%m%~2 [%bm1%m%~3 [%bm2%m%~4 [%bm3%m%~5 [%bm4%m%~6 [%bm5%m%~7 [%bm6%m%~8[0m
) else if not "x%~7"=="x" (
	echo.[%curtime%][%c3%G[%bm0%m%~2 [%bm1%m%~3 [%bm2%m%~4 [%bm3%m%~5 [%bm4%m%~6 [%bm5%m%~7[0m
) else if not "x%~6"=="x" (
	echo.[%curtime%][%c3%G[%bm0%m%~2 [%bm1%m%~3 [%bm2%m%~4 [%bm3%m%~5 [%bm4%m%~6[0m
) else if not "x%~5"=="x" (
	echo.[%curtime%][%c3%G[%bm0%m%~2 [%bm1%m%~3 [%bm2%m%~4 [%bm3%m%~5[0m
) else if not "x%~4"=="x" (
	echo.[%curtime%][%c3%G[%bm0%m%~2 [%bm1%m%~3 [%bm2%m%~4[0m
) else if not "x%~3"=="x" (
	echo.[%curtime%][%c3%G[%bm0%m%~2 [%bm1%m%~3[0m
) else if not "x%~2"=="x" (
	echo.[%curtime%][%c3%G[%bm0%m%~2[0m
) 
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
	for /F "skip=1 tokens=1* delims==" %%M in (!foo!) do (
		set "fletter=%%~M"
		set "fletter=!fletter: =!"
		set /a parse_desync = 0
		if "x!fletter:~0,1!"=="x#" (
			if "x!fletter:~0,2!"=="x##" (
				set "foo=%%~M"
				if not "x!foo:~2!"=="x" set "psabout=!foo:~2!"
			)
		) else (
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
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'..\lists\hostlist\*'"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
					)				
				) else (
					if exist %home%\lists\hostlist\%%~N (
						set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%~N"
					) else (
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'..\lists\hostlist\%%~N'"
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
							call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'..\lists\ipset\*'"
							call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "IPSET" "отброшен"	
						)				
					) else (
						set "skip_profile=on"
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinWS фильтр с параметром" "'IPset=off'"
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
							call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'..\lists\ipset\*'"
							call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						)				
					) else (
						set "skip_profile=on"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinWS фильтр --ipset с параметром" "'IPset=off'"
					)
				) else (
					if "x%IPsetStatus%"=="xon" (
						if exist %home%\lists\ipset\%%~N (
							set "profile_param=!profile_param! --ipset=%home%\lists\ipset\%%~N"
						) else (
							call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'..\lists\ipset\%%~N'"
							call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%~N" "отброшен"	
						)
					) else (
						set "skip_profile=on"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" x"Исключен" "WinWS фильтр --ipset с параметром" "'IPset=off'"
					)
				)
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--wf-raw" (
				set "LN=%%N"
				if "x!LN:~0,1!"=="x@" (
					if "x%custom_strategy%"=="xon" (
						if exist %parse_str_strategy_apath%\!LN:~1! (
							if "x!sWinDivert!"=="x" ( set "sWinDivert=--wf-raw=@%parse_str_strategy_apath%\!LN:~1!" ) else ( set "sWinDivert=!sWinDivert! --wf-raw=@%parse_str_strategy_apath%\!LN:~1!" )
						) else (
							set "skip_WinDivert=on"
							if "x%custom_strategy%"=="xon" (
								call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'..\strategy\%strategy_name%\custom\!LN:~0!'"
							) else call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'..\strategy\%strategy_name%\!LN:~0!'"
							call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						)
					)
				) else (
						set "skip_WinDivert=on"
						call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
						call:cecho x1x "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinDivert фильтр --wf-raw"
				)
				set "LN="
				set /a parse_mayok=1
			) else if "x!fletter!"=="x--wf-tcp" (
				if "x%%~N"=="x" (
					set "skip_WinDivert=on"
					call:cecho xx31 "%str_file_path_for_cecho%\%%~I :" "Параметр" "!fletter!=%%N" "отброшен"	
					call:cecho x1x "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinDivert фильтр --wf-tcp"
				) else if "x!sWinDivert!"=="x" ( set "sWinDivert=--wf-tcp=%%~N" ) else ( set "sWinDivert=!sWinDivert! --wf-tcp=%%~N" )
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
				) else if "x!sWinDivert!"=="x" ( set "sWinDivert=--wf-udp=%%~N" ) else ( set "sWinDivert=!sWinDivert! --wf-udp=%%~N" )
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
					set /a scount=!scount! + 1
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
					if "x%IPsetStatus%"=="xoff" call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Исключен" "WinWS фильтр с параметром" "'IPset=off'"
					set "psabout=" 
					set "profile_param= "
					set "skip_profile=off"
				)
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
						call:cecho x1x3 "%str_file_path_for_cecho%\%%~I :" "Ошибка." "Файл не найден:" "'..\!fakedir:~%homestrsize%!\%%~N'"
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
				set /a scount=!scount! + 1
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
				set /a pcount=!pcount!+1
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

:help
cls
echo.
echo.[5G[37mHelp[0m
echo.
pause
goto:menu
