@echo off
chcp 1251 > nul
setlocal EnableDelayedExpansion
echo.]0;DPI v.71.1.1
mode con cols=80 lines=50
set "PortFilterStatus=off"
set "strategy_run="
set "debug=off"
set "daemon=on"
set "home=%~dp0"
set "home=%home:~0,-1%"
set /a profile_count=0
set /a c1=5
set /a c2=8
set /a c3=12
set /a c4=30
set /a c5=50

>nul dism ||( 
	echo.Для некоторых действий сценария необходимы высокие привилегии, запустите скрипт с правами 'Администратора'.
	echo.Выход.
	echo.
	pause
	exit
)
echo.[39;49m
if not exist %home%\bin\port_filter echo.1024-65535>%home%\bin\port_filter
if exist %home%\bin\port_filter.status set /p PortFilterStatus=<%home%\bin\port_filter.status
if "x%PortFilterStatus%"=="xon" (
    set /p PortFilter=<%home%\bin\port_filter
) else (
    set "PortFilter=0"
)
set "PortFilter=%PortFilter: =%"

set "IPsetStatus=on"
if exist %home%\bin\ipset.status (
	set /p IPsetStatus=<%home%\bin\ipset.status
) else (
	echo.on>%home%\bin\ipset.status
)

:menu
cls
echo.
set "winws_pid="
set /a foo=0
for /f "tokens=2 delims=," %%i in ('2^>nul tasklist /FI "IMAGENAME eq winws.exe" /fo csv /nh') do (
	set /a foo=!foo!+1
	set "a=%%i"
	set "winws_pid!foo!=!a:"=!"
)
set "strategy_run="
set /a terminate_count=100
set /a profile_count=0
set "n="
set "p="
set "ip="
set "pr="
set "pid="
set "daemon_status=on"
set "debug_status="


if %foo% GTR 0 ( 
	for /l %%i in (1,1,%foo%) do (
		for /f "skip=1 tokens=2,3,4,5,6,7 delims=[]" %%M in ('2^>nul wmic process where Processid^="!winws_pid%%i!" get commandline') do (
		
			if "x%%~M"=="x" (
				set "foo="
			) else (
				set /a profile_count=!profile_count!+1
				set "n!profile_count!=%%~M"
				set "p!profile_count!=%%~N"
				set "ip!profile_count!=%%~O"
				set "pr!profile_count!=%%~P"
				set "pid!profile_count!=!winws_pid%%i!"
				set "daemon_status=%%~Q"
				set "debug_status=%%~R"
			)
		)
	)
)

if %profile_count% GTR 0 ( 
	for /l %%i in (1,1,%profile_count%) do (
		if %%i EQU 1 (
			for /l %%x in (1,1,79) do <nul set /p "x=-"
			echo.
			echo.Работает мульти-стратегия:[%c4%G'[33m!n%%i![0m'
			echo.[%c4%G[33mДемон[0m: !daemon_status!
			echo.[%c4%G[33mОтладка[0m: !debug_status!
			if "x!p%%i!"=="x0" (
				echo.[%c4%G[33mДиапазон портов для фильтрации[0m: [31moff[0m
			) else echo.[%c4%G[33mДиапазон портов для фильтрации[0m: !p%%i!
			echo.[%c4%G[33mСписок IPset[0m: !ip%%i!
			echo.[%c4%G--------------------------------------------------
		)
		echo.[%c4%GPID: !pid%%i![%c5%G!pr%%i!
	)
	for /l %%x in (1,1,79) do <nul set /p "x=-"
	echo.
	set "strategy_run=!n1!" 
)
echo.
rem --------------------------------------

set /a foo=1
set /a menu_count=0
if "x%daemon%"=="xon" set /a foo=2
echo.[%c1%G[37m1.[0m[%c2%GДемон[%c5%G[[3%foo%m%daemon%[0m]
set /a menu_count=%menu_count%+1
set /a foo=1
if "x%debug%"=="xon" set /a foo=2
if "x%debug%"=="x@filename" set /a foo=7
echo.[%c1%G[37m2.[0m[%c2%GОтладка[%c5%G[[3%foo%m%debug%[0m]
set /a menu_count=%menu_count%+1
if "x%PortFilterStatus%"=="xon" echo.[%c1%G[37m3.[0m[%c2%GДиапазон портов для фильтрации[%c5%G[%PortFilter%]
if "x%PortFilterStatus%"=="xoff" echo.[%c1%G[37m3.[0m[%c2%GДиапазон портов для фильтрации[%c5%G[[31m%PortFilterStatus%[0m]
set /a menu_count=%menu_count%+1
set /a foo=1
if "x%IPsetStatus%"=="xon" set /a foo=2
echo.[%c1%G[37m4.[%c2%GСписок IPset[%c5%G[[3%foo%m%IPsetStatus%[0m]
set /a menu_count=%menu_count%+1
echo.
echo.[8G[33mСтратегии[%c5%GОписание[0m
set "menu_choice="
set "strategy_count_name="
set /a foo=0
for /f "delims=" %%I in ('2^>nul dir /b /a:d %home%\strategy\') do (
	set /p about_strategy=<%home%\strategy\%%I\about
	set /a menu_count=!menu_count!+1
	if "x!strategy_run!"=="x%%~I" ( 
		echo.[%c1%G[32m*[0m[%c2%G[37m!menu_count!.[0m[%c3%G[32m%%I[0m[%c5%G[[3;36m!about_strategy![0m]
	) else ( 	
		echo.[%c2%G[37m!menu_count!.[0m[%c3%G%%I[%c5%G[[3;36m!about_strategy![0m]
	) 
	set "strategy_count_name!menu_count!=%%I"
	set /a foo=1
)
if %foo% equ 0 echo.[%c1%G[31mпусто[0m
if defined strategy_run (
	set /a terminate_count=%menu_count% + 1
	echo.
	set /a menu_count=!menu_count!+1
	echo.[%c1%G[37m!menu_count!.[0m[%c2%G[33mЗавершить мульти-стратегию '!strategy_run!'[0m
	for /l %%i in (1,1,%profile_count%) do (
		set /a menu_count=!menu_count!+1
		echo.[%c2%G[37m!menu_count!.[0m[%c3%G!pr%%i!
	)
)
echo.
echo.[%c1%Gh.[%c2%GПомощь
echo.[%c1%G0.[%c2%GВыход
echo.

choice /N /C:0123456789rh /D r /T 60 /M "#:"
if %errorlevel% EQU 255 call:cerror 154
if %errorlevel% EQU 0 call:cerror 155
if %errorlevel% EQU 11 goto:menu
if %errorlevel% EQU 12 goto:help
set /a first_digit=%errorlevel% - 1
echo.[2F
choice /N /C:0123456789z /D z /T 3 /M "#:"
if %errorlevel% EQU 255 call:cerror 160
if %errorlevel% EQU 0 call:cerror 161
if %errorlevel% EQU 11 (
	set /a menu_choice=%first_digit%
) else (
	set /a second_digit=%errorlevel% - 1
	set /a menu_choice=%first_digit% * 10
	set /a menu_choice=!menu_choice! + !second_digit!
)
echo.[1F[2K
echo.
if %menu_choice% GTR %menu_count% goto menu
if %menu_choice% GEQ %terminate_count% goto:terminate
if %menu_choice% LSS 5 goto menu_%menu_choice%

:strategy_choice
if "x!strategy_count_name%menu_choice%!"=="x" goto menu
set strategy_name=!strategy_count_name%menu_choice%!
:strategy_list
if "x%strategy_name%"=="x" (
	echo.strategy_name=none
	pause
	goto menu
)

:terminate
if not defined strategy_run goto:terminate_done
if %menu_choice% EQU %terminate_count% goto:terminate_all
if %menu_choice% GTR %terminate_count% goto:terminate_one
:terminate_all
call:cecho 7 "Завершаем работу стратегии" 3 "'%strategy_run%'"
for /l %%i in (1,1,%profile_count%) do (
	if "x!n%%i!"=="x%strategy_run%" (
		powershell -NoP -sta -NonI -Command "Stop-Process -Id !pid%%i! -Force" 1>nul 2>&1
	)
)
if %menu_choice% EQU %terminate_count% (
	call:cecho 2 "Готово"
	echo.
	for /l %%x in (5,-1,1) do (
		echo.[F
		<nul set /p "x=[%c3%GВозврат в меню через [31m%%x[0mс."
		timeout /T 1 /NOBREAK >nul
	)
	goto:menu
)
if %menu_choice% LSS %terminate_count% goto:terminate_done

:terminate_one
set /a cpofile=%menu_choice%-%terminate_count%
call:cecho 7 "Завершаем работу профиля стратегии" 3 "'%strategy_run%'" 7 "[!pr%cpofile%!]"
powershell -NoP -sta -NonI -Command "Stop-Process -Id !pid%cpofile%! -Force" 1>nul 2>&1
call:cecho 2 "Готово"
echo.
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p "x=[%c3%GВозврат в меню через [31m%%x[0mс."
	timeout /T 1 /NOBREAK >nul
)
goto:menu
:terminate_done
sc qc windivert 1>nul 2>&1
if %errorlevel% EQU 0 (
	sc stop windivert 1>nul 2>&1
	sc delete windivert 1>nul 2>&1
)
if exist %home%\log\status del /F /Q %home%\log\status >nul
set "winws_arg= "
set /p about_strategy=<%home%\strategy\%strategy_name%\about
if not exist %home%\strategy\%strategy_name%\log md %home%\strategy\%strategy_name%\log >nul
del /F /Q %home%\strategy\%strategy_name%\log\* >nul
call:cecho 7 "Генерация параметров стратегии, см." 3 "%home%\strategy\%strategy_name%\log\"
set /a pcount=0
for /f "delims=" %%I in ('2^>nul dir /b %home%\strategy\%strategy_name%\*.strategy') do (
	set "skip_profile=off"
	set "profile_param=--comment strategy-%%~nI"
	set "tmp_profile_param= "
	for /F "eol=# skip=1 tokens=1* delims==" %%M in (%home%\strategy\%strategy_name%\%%~nxI) do (
		set "fletter=%%~M"
		if "x!fletter:~0,1!"=="x+" (
			if "x!fletter:~0,14!"=="x+hostlist-auto" (
				set "profile_param=--hostlist-auto=%home%\lists\host\hostlist.auto"
			) else (
				if "x!fletter:~0,9!"=="x+hostlist" (
					if "x%%~N"=="x" (
						for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\host\*.txt') do (
							set "profile_param=!profile_param! --hostlist=%home%\lists\host\%%X"
						)
					) else (
						set "profile_param=!profile_param! --hostlist=%home%\lists\host\%%~N"
					)
				)
			)
			
			if "x!fletter:~0,6!"=="x+ipset" (
				if "x%IPsetStatus%"=="xon" (
					for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\ipset\*.txt') do (
						set "profile_param=!profile_param! --ipset=%home%\lists\ipset\%%~X"
					)
				) else set "skip_profile=on"
			)
			
			if "x!fletter:~0,7!"=="x+wf-tcp" (
				if "x%%~N"=="x" (
					if "x%PortFilter%"=="x0" set "skip_profile=on"
					set "profile_param=!profile_param! --wf-tcp=%PortFilter%"
				) else (
					set "profile_param=!profile_param! --wf-tcp=%%~N"
				)
			)
			if "x!fletter:~0,7!"=="x+wf-udp" (
				if "x%%~N"=="x" (
					if "x%PortFilter%"=="x0" set "skip_profile=on"
					set "profile_param=!profile_param! --wf-udp=%PortFilter%"
				) else (
					set "profile_param=!profile_param! --wf-udp=%%~N"
				)
			)
			if "x!fletter:~0,11!"=="x+filter-udp" (
				if "x%%~N"=="x" (
					if "x%PortFilter%"=="x0" set "skip_profile=on"
					set "profile_param=!profile_param! --filter-udp=%PortFilter%"
				) else (
					set "profile_param=!profile_param! --filter-udp=%%~N"
				)
			)
			if "x!fletter:~0,11!"=="x+filter-tcp" (
				if "x%%~N"=="x" (
					if "x%PortFilter%"=="x0" set "skip_profile=on"
					set "profile_param=!profile_param! --filter-tcp=%PortFilter%"
				) else (
					set "profile_param=!profile_param! --filter-tcp=%%~N"
				)
			)
			
			if "x!fletter:~0,11!"=="x+dpi-desync" (
				if exist "%home%\bin\fake\%%~N" ( 
					set "foo=%%~M"
					set "profile_param=!profile_param! --!foo:~1!=%home%\bin\fake\%%~N"
				) else (
					set "winws_arg=%home%\bin\fake\%%~N"
					goto:strategy_list_nofile_error
				)
			)
			
		) else (
			if "x!fletter:~0,5!"=="x--new" (
				if "x!skip_profile!"=="xoff" (
					set "tmp_profile_param=!tmp_profile_param! !profile_param!"
					set "profile_param= "
				) else (
					if "x%PortFilter%"=="x0" call:cecho 1 "Исключен" 7 "фильтр с параметром" 3 "'PortFilter=0'"
					if "x%IPsetStatus%"=="xoff" call:cecho 1 "Исключен" 7 "фильтр с параметром" 3 "'IPset=off' [0.0.0.0/32]"
					set "profile_param= "
					set "skip_profile=off"
				)
			)
			if "x%%~N"=="x" (
				set "profile_param=!profile_param! %%~M"
			) else (
				set "profile_param=!profile_param! %%~M=%%~N"
			)
		)
	)
	if "x!skip_profile!"=="xoff" (
		set "tmp_profile_param=!tmp_profile_param! !profile_param!"
	)
	
	if "x!tmp_profile_param!"=="x " (
		if "x%PortFilter%"=="x0" call:cecho 1 "Исключен" 7 "фильтр с параметром 'PortFilter=0'"
		if "x%IPsetStatus%"=="xoff" call:cecho 1 "Исключен" 7 "фильтр с параметром 'IPset=off' [0.0.0.0/32]"
	) else (
		set /a pcount=!pcount!+1
		set "winws_arg!pcount!=!tmp_profile_param!"
		set "sabout="
		set /p sabout=<%home%\strategy\%strategy_name%\%%~nxI
		if "x!sabout!" neq "x" (
			set "sabout=!sabout:~1!"
		) else set "sabout=no about"
		if "x!sabout:~0,1!"=="x+" set "sabout=!sabout:~1!=%PortFilter%"
		echo.!sabout!>%home%\strategy\%strategy_name%\log\%%~nxI-about.log
	)
)

for /f "delims=" %%I in ('%home%\bin\winws.exe --version') do set "foo=%%I"
REM set foo=%foo:(=[%
REM set foo=%foo:)=]%
call:cecho 7 "Windivert" 3 "'%foo:~0,23%'" 7 "initialized"

for /l %%i in (1,1,%pcount%) do (
	set "sabout=x"
	if exist %home%\strategy\%strategy_name%\log\%%i.strategy-about.log set /p sabout=<%home%\strategy\%strategy_name%\log\%%i.strategy-about.log
	set "foo=!winws_arg%%i!"
	echo.!foo!>>%home%\strategy\%strategy_name%\log\strategy-%%i.log
	set "debug_status=%debug%"
	if "x%debug%"=="xon" (
		set foo=--debug=1 !foo!
	) else if "x%debug%"=="xoff" (
		set foo=!foo!
	) else (
		if not exist %home%\strategy\%strategy_name%\debug md %home%\strategy\%strategy_name%\debug >nul
		del /F /Q %home%\strategy\%strategy_name%\debug\* >nul
		set foo=--debug=@%home%\strategy\%strategy_name%\debug\%%i.strategy-debug.log !foo!
		call:cecho 7 "Запись отладочных сообщений стратегии в файл" 3 "'%home%\strategy\%strategy_name%\debug\%%i.strategy-debug.log'"
	)
	
	if "x%daemon%"=="xon" set foo=--daemon !foo!
	set foo=--comment [%strategy_name%][%PortFilter%][%IPsetStatus%][!sabout!][%daemon%][%debug%] !foo!
	echo.!foo!>%home%\strategy\%strategy_name%\log\dry-run.strategy-%%i.log
	call:cecho 7 "Проверка параметров стратегии" 3 "'%strategy_name%' [!sabout!]"
	%home%\bin\winws.exe --dry-run !foo! 2>&1 1>%home%\log\status
	if %errorlevel% neq 0 goto:strategy_list_arg_error
	call:cecho 7 "Запуск стратегии" 3 "'%strategy_name%' [!sabout!]"
	if "x%daemon%"=="xoff" start "%strategy_name% [%PortFilter%][%IPsetStatus%][debug:%debug%][!sabout!]" %home%\bin\winws.exe !foo! 2>&1 1>%home%\log\status
	if "x%daemon%"=="xon" %home%\bin\winws.exe !foo! 2>&1 1>%home%\log\status
	if %errorlevel% neq 0 goto:strategy_list_arg_error
)

call:cecho 2 "Готово"
set /a ecode=0

:strategy_list_end
echo.
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p "x=[%c3%GВозврат в меню через [31m%%x[0mс."
	timeout /T 1 /NOBREAK >nul
)
goto menu
:strategy_list_parse_error
call:cecho 1 "Ошибка." 7 "Парсинг файла профиля, смотри в" 3 "'%home%\log\%strategy_name%.profiles.log'"
set /a ecode=1
goto:strategy_list_end
:strategy_list_nofile_error
call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%winws_arg%'"
set "winws_arg="
set /a ecode=1
goto:strategy_list_end
:strategy_list_arg_error
call:cecho 1 "Ошибка." 7 "Подробности смотри в" 3 "'%home%\log\status'"
set /a ecode=1
goto:strategy_list_end

:menu_0
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p "x=[%c3%GВыход через [31m%%x[0mс."
	timeout /T 1 /NOBREAK >nul
)
exit /b

:menu_1
if "x%daemon%"=="xon" ( set "daemon=off" ) else ( set "daemon=on" )
goto menu

:menu_2
if "x%debug%"=="xon" (
	set "debug=@filename"
) else if "x%debug%"=="xoff" (
	set "debug=on"
) else if "x%debug%"=="x@filename" set "debug=off"
goto menu

:menu_3
set "foo="
if "x%PortFilterStatus%"=="xon" (
	set "PortFilterStatus=off"
    set "PortFilter=0"
	echo.off>%home%\bin\port_filter.status
) else (
	set "PortFilterStatus=on"
    set /p PortFilter=<%home%\bin\port_filter
	call:cecho 7 "Текущий диапазон портов:" 3 "[!PortFilter!]"
	echo.
    set /p "foo=Ввод диапазона портов [Enter не менять]: "
	echo.on>%home%\bin\port_filter.status
)
if defined foo (
	set "PortFilter=%foo%"
	set "PortFilter=!PortFilter: =!"
    echo.!PortFilter!>%home%\bin\port_filter
)
set "PortFilter=%PortFilter: =%"
if defined strategy_run (
	call:cecho 7 "Диапазон портов для фильтрации установлен:" 3 "[%PortFilter%]"
	goto restart_strategy_after_change_port_range_or_ip
)
goto menu

:menu_4
if "x%IPsetStatus%"=="xon" (
		set "IPsetStatus=off"
		echo.off>%home%\bin\ipset.status
	) else ( 
		set "IPsetStatus=on"
		echo.on>%home%\bin\ipset.status
	)
if defined strategy_run (
	call:cecho 7 "Список IPset установлен:" 3 "[%IPsetStatus%]"
	goto restart_strategy_after_change_port_range_or_ip
)
goto menu

:restart_strategy_after_change_port_range_or_ip

if defined strategy_run (
	call:cecho 7 "Перезапуск стратегии" 3 "'%strategy_run%'" 7 "для применения изменений."
	set "strategy_name=%strategy_run%"
	goto:strategy_list
)
goto menu

:cerror
echo.
echo.[5G[31mОшибка.[0m Line #%~1
goto:menu_0

:cecho
set "curtime=%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%"
set "curtime=%curtime: =0%"
if "x%~8"=="x" (
	if "x%~6"=="x" (
		if "x%~4"=="x" (
			echo.[37m[%curtime%][0m[%c3%G[3%~1m%~2[0m
		) else echo.[37m[%curtime%][0m[%c3%G[3%~1m%~2[0m [3%~3m%~4[0m
	) else echo.[37m[%curtime%][0m[%c3%G[3%~1m%~2[0m [3%~3m%~4[0m [3%~5m%~6[0m
) else echo.[37m[%curtime%][0m[%c3%G[3%~1m%~2[0m [3%~3m%~4[0m [3%~5m%~6[0m [3%~7m%~8[0m
exit /b

:help
cls
echo.[5G[37mHelp[0m
echo.
pause
goto:menu
