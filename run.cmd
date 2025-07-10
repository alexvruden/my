@echo off
chcp 1251 > nul
setlocal EnableDelayedExpansion
echo.]0;Bypassing Censorship
set "PortFilterStatus=off"
set "IPsetStatus=off"
set "strategy_run="
set /a ccall=0
set "debug=off"
set "daemon=on"
set "home=%~dp0"
set "home=%home:~0,-1%"
set "winwsdir="
set "fakedir="
set /a profile_count=0
set /a c1=5
set /a c2=8
set /a c3=12
set /a c4=30
set /a c5=50
set /a blkc=0

>nul dism ||( 
	echo.Для некоторых действий сценария необходимы высокие привилегии, запустите скрипт с правами 'Администратора'.
	echo.Выход.
	echo.
	pause
	exit
)
echo.[39;49m
if not exist %home%\bin\port_filter echo.1024-65535>%home%\bin\port_filter
if not exist %home%\bin\port_filter.status echo.off>%home%\bin\port_filter.status
if not exist %home%\bin\ipset.status echo.off>%home%\bin\ipset.status
if not exist %home%\bin\daemonpar echo.on>%home%\bin\daemonpar
if not exist %home%\bin\debugpar echo.off>%home%\bin\debugpar

:menu
cls
echo.
if exist %home%\bin\port_filter.status set /p PortFilterStatus=<%home%\bin\port_filter.status
if exist %home%\bin\daemonpar set /p daemon=<%home%\bin\daemonpar
if exist %home%\bin\debugpar set /p debug=<%home%\bin\debugpar
if "x%PortFilterStatus%"=="xon" (
    set /p PortFilter=<%home%\bin\port_filter
) else (
    set "PortFilter=0"
)
set "PortFilter=%PortFilter: =%"
set /p IPsetStatus=<%home%\bin\ipset.status
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
			for /l %%x in (1,1,80) do <nul set /p =-
			echo.
			echo.Работает мульти-стратегия:[%c4%G'[33m!n%%i![0m'
			echo.[%c4%G[33mДемон[0m: !daemon_status!
			echo.[%c4%G[33mОтладка[0m: !debug_status!
			if "x!p%%i!"=="x0" (
				echo.[%c4%G[33mДиапазон портов для фильтрации[0m: off
			) else echo.[%c4%G[33mДиапазон портов для фильтрации[0m: !p%%i!
			echo.[%c4%G[33mСписок IPset[0m: !ip%%i!
			set /a foo=%c4%
			set /a foo=!foo! - 1
			for /l %%x in (1,1,!foo!) do <nul set /p =[30m-[0m
			for /l %%x in (%c4%,1,80) do <nul set /p =-
			echo.
		)
		echo.[%c4%GPID: !pid%%i![%c5%G!pr%%i!
	)
	for /l %%x in (1,1,79) do <nul set /p =-
	echo.
	set "strategy_run=!n1!" 
)
echo.
rem --------------------------------------

set /a foo=1
set /a menu_count=0
if "x%daemon%"=="xon" set /a foo=2
echo.[%c1%G[37m1.[%c2%GДемон[%c5%G[[3%foo%m%daemon%[0m]
set /a menu_count=%menu_count%+1
set /a foo=1
if "x%debug%"=="xon" set /a foo=2
if "x%debug%"=="x@filename" set /a foo=7
echo.[%c1%G[37m2.[%c2%GОтладка[%c5%G[[3%foo%m%debug%[0m]
set /a menu_count=%menu_count%+1
if "x%PortFilterStatus%"=="xon" echo.[%c1%G[37m3.[%c2%GДиапазон портов для фильтрации[%c5%G[%PortFilter%]
if "x%PortFilterStatus%"=="xoff" echo.[%c1%G[37m3.[%c2%GДиапазон портов для фильтрации[%c5%G[[31m%PortFilterStatus%[0m]
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
	set /a fexist=0
	for /f "delims=" %%a in ('2^>nul dir /b %home%\strategy\%%I\*.strategy') do set /a fexist=1
	if !fexist! neq 0 (
		if not exist %home%\strategy\%%I\about echo.нет описания>%home%\strategy\%%I\about
		set /p about_strategy=<%home%\strategy\%%I\about
		set /a menu_count=!menu_count!+1
		if "x!strategy_run!"=="x%%~I" ( 
			echo.[%c1%G[32m*[%c2%G[37m!menu_count!.[%c3%G[32m%%I[%c5%G[36m!about_strategy![0m
		) else ( 	
			echo.[%c2%G[37m!menu_count!.[%c3%G%%I[%c5%G[36m!about_strategy![0m
		) 
		set "strategy_count_name!menu_count!=%%I"
		set /a foo=1
	)
)
if %foo% equ 0 echo.[%c1%G[31mпусто[0m
if defined strategy_run (
	set /a terminate_count=%menu_count% + 1
	echo.
	set /a menu_count=!menu_count!+1
	echo.[%c1%G[37m!menu_count!.[%c2%G[33mЗавершить мульти-стратегию '!strategy_run!'[0m
	for /l %%i in (1,1,%profile_count%) do (
		set /a menu_count=!menu_count!+1
		echo.[%c2%G[37m!menu_count!.[%c3%G[36m!pr%%i![0m
	)
)
echo.
if exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh echo.[%c1%Gb.[%c2%GBlockcheck
echo.[%c1%G0.[%c2%GВыход
echo.
set "strchoice=0123456789rhb"
if not exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\blockcheck.sh set "strchoice=0123456789rh"

choice /N /C:%strchoice% /D r /T 60 /M "#:"
if %errorlevel% EQU 255 call:cerror 174
if %errorlevel% EQU 0 call:cerror 175
if %errorlevel% EQU 11 goto:menu
if %errorlevel% EQU 12 goto:help
if %errorlevel% EQU 13 goto:blockcheck
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
		<nul set /p =[5G[37mВозврат в меню через [32m%%x[37m с.[0m
		timeout /T 1 /NOBREAK >nul
	)
	goto:menu
)
if %blkc% equ 1 goto:terminate_done
if %menu_choice% LSS %terminate_count% goto:terminate_done

:terminate_one
set /a cpofile=%menu_choice%-%terminate_count%
call:cecho 7 "Завершаем работу профиля стратегии" 3 "'%strategy_run%'" 7 "[!pr%cpofile%!]"
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
	rem sc stop windivert 1>nul 2>&1
)
if %blkc% equ 1 goto:blockcheck

set "foo="
for /f "delims=" %%I in ('2^>nul dir /b /s /a:d %home%\windows-x86_64') do set "foo=%%~I"
if not exist %foo%\winws.exe (
	echo.
	echo.[5G[37mDownload developers code, unzip and put in '[33m%home%\bin\[37m' from: [0m
	echo.
	echo.[5Ghttps://github.com/bol-van/zapret/releases
	echo.
	pause
	goto:menu
)
set "winwsdir=%foo%"
set "fakedir=%foo:~0,-24%\files\fake"

if exist %home%\bin\status del /F /Q %home%\bin\status >nul
set "winws_arg= "
if exist %home%\strategy\%strategy_name%\about set /p about_strategy=<%home%\strategy\%strategy_name%\about
if not exist %home%\strategy\%strategy_name%\log md %home%\strategy\%strategy_name%\log >nul
del /F /Q %home%\strategy\%strategy_name%\log\* >nul
call:cecho 7 "Парсинг параметров, см." 3 "%home%\strategy\%strategy_name%\log\"
set /a pcount=0
set /a scount=0
for /f "delims=" %%I in ('2^>nul dir /b %home%\strategy\%strategy_name%\*.strategy') do (
	set "skip_profile=off"
	set "skip_WinDivert=off"
	set "profile_param=--comment strategy-%%~nI"
	set "tmp_profile_param= "
	set "sabout="
	set "psabout="
	set "sWinDivert="
	for /F "skip=1 tokens=1* delims==" %%M in (%home%\strategy\%strategy_name%\%%~nxI) do (
		set "fletter=%%~M"
		set "fletter=!fletter: =!"
		
		if "x!fletter:~0,1!"=="x#" (
			if "x!fletter:~0,2!"=="x##" (
				set "foo=%%~M"
				if not "x!foo:~2!"=="x" set "psabout=!foo:~2!"
			)
		) else (
			if "x!fletter!"=="x--hostlist-auto" (
				if "x%%~N"=="x" (
					if not exist %home%\lists\hostlist\hostlist-auto.txt echo.#>%home%\lists\hostlist\hostlist-auto.txt
					set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\hostlist-auto.txt"
				) else (
					if not exist %home%\lists\hostlist\%%~N echo.#>%home%\lists\hostlist\%%~N
					set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\%%~N"
				)
			) else if "x!fletter!"=="x--hostlist" (
				if "x%%~N"=="x" (
					set /a foo = 0
					for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\hostlist\*.txt %home%\lists\hostlist\*.lst %home%\lists\hostlist\*.gz') do (
						set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%X"
						set /a foo = 1
					)
					if !foo! equ 0 (
						call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%home%\lists\hostlist\*'"
						call:cecho 7 "Параметр" 3 "!fletter!=%%N" 1 "отброшен"	
					)				
				) else (
					if exist %home%\lists\hostlist\%%~N (
						set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%~N"
					) else (
						call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%home%\lists\hostlist\%%~N'"
						call:cecho 7 "Параметр" 3 "!fletter!=%%~N" 1 "отброшен"	
					)
				)
			) else if "x!fletter!"=="x--hostlist-exclude" (
				if "x%%~N"=="x" (
					if not exist %home%\lists\hostlist\exclude md %home%\lists\hostlist\exclude >nul
					set /a foo = 0
					for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\hostlist\exclude\*.txt') do (
						set "profile_param=!profile_param! --hostlist-exclude=%home%\lists\hostlist\exclude\%%X"
						set /a foo = 1
					)
					if !foo! equ 0 (
						call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%home%\lists\hostlist\exclude\*'"
						call:cecho 7 "Параметр" 3 "!fletter!=%%N" 1 "отброшен"	
					)				
				) else (
					if exist %home%\lists\hostlist\exclude\%%~N (
						set "profile_param=!profile_param! --hostlist-exclude=%home%\lists\hostlist\exclude\%%~N"
					) else (
						call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%home%\lists\hostlist\exclude\%%~N'"
						call:cecho 7 "Параметр" 3 "!fletter!=%%N" 1 "отброшен"	
					)
				)
			) else if "x!fletter!"=="x--ipset" (
				if "x%%~N"=="x" (
					if "x%IPsetStatus%"=="xon" (
						set /a foo = 0
						for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\ipset\*.txt %home%\lists\ipset\*.lst %home%\lists\ipset\*.gz') do (
							set "profile_param=!profile_param! --ipset=%home%\lists\ipset\%%~X"
							set /a foo = 1
						)
						if !foo! equ 0 (
							call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%home%\lists\ipset\*'"
							call:cecho 7 "Параметр" 3 "!fletter!=%%N" 1 "отброшен"	
						)				
					) else (
						set "skip_profile=on"
						call:cecho 1 "Исключен" 7 "WinWS фильтр с параметром" 3 "'IPset=off'"
					)
				) else (
					if "x%IPsetStatus%"=="xon" (
						if exist %home%\lists\ipset\%%~N (
							set "profile_param=!profile_param! --ipset=%home%\lists\ipset\%%~N"
						) else (
							call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%home%\lists\ipset\%%~N'"
							call:cecho 7 "Параметр" 3 "!fletter!=%%~N" 1 "отброшен"	
						)
					) else (
						set "skip_profile=on"
						call:cecho 1 "Исключен" 7 "WinWS фильтр с параметром" 3 "'IPset=off'"
					)
				)
			) else if "x!fletter!"=="x--ipset-exclude" (
				if "x%%~N"=="x" (
					if "x%IPsetStatus%"=="xon" (
						if not exist %home%\lists\ipset\exclude md %home%\lists\ipset\exclude >nul
						set /a foo = 0
						for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\ipset\exclude\*.txt') do (
							set "profile_param=!profile_param! --ipset-exclude=%home%\lists\ipset\exclude\%%~X"
							set /a foo = 1
						)
						if !foo! equ 0 (
							call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%home%\lists\ipset\exclude\*'"
							call:cecho 7 "Параметр" 3 "!fletter!=%%N" 1 "отброшен"	
						)				
					) else (
						set "skip_profile=on"
						call:cecho 1 "Исключен" 7 "WinWS фильтр с параметром" 3 "'IPset=off'"
					)
				) else (
					if "x%IPsetStatus%"=="xon" (
						if exist %home%\lists\ipset\exclude\%%~N (
							set "profile_param=!profile_param! --ipset-exclude=%home%\lists\ipset\exclude\%%~N"
						) else (
							call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%home%\lists\ipset\exclude\%%~N'"
							call:cecho 7 "Параметр" 3 "!fletter!=%%~N" 1 "отброшен"	
						)
					) else (
						set "skip_profile=on"
						call:cecho 1 "Исключен" 7 "WinWS фильтр с параметром" 3 "'IPset=off'"
					)
				)
			) else if "x!fletter!"=="x--wf-tcp" (
				if "x!sabout!"=="x" (
					set "sabout=!psabout!" 
				) else (
					set "sabout=!sabout! !psabout!" 
				)
				if "x%%~N"=="x" (
					if "x%PortFilter%"=="x0" (
						set "skip_WinDivert=on"
						call:cecho 1 "Исключен" 7 "WinDivert фильтр с параметром" 3 "'PortFilter=0'"
					)
					if "x!sWinDivert!"=="x" ( set "sWinDivert=--wf-tcp=%PortFilter%" ) else ( set "sWinDivert=!sWinDivert! --wf-tcp=%PortFilter%" )
				) else (
					if "x!sWinDivert!"=="x" ( set "sWinDivert=--wf-tcp=%%~N" ) else ( set "sWinDivert=!sWinDivert! --wf-tcp=%%~N" )
				)
			) else if "x!fletter!"=="x--wf-udp" (
				if "x!sabout!"=="x" (
					set "sabout=!psabout!" 
				) else (
					set "sabout=!sabout! !psabout!" 
				)
				if "x%%~N"=="x" (
					if "x%PortFilter%"=="x0" (
						set "skip_WinDivert=on"
						call:cecho 1 "Исключен" 7 "WinDivert фильтр с параметром" 3 "'PortFilter=0'"
					)
					if "x!sWinDivert!"=="x" ( set "sWinDivert=--wf-udp=%PortFilter%" ) else ( set "sWinDivert=!sWinDivert! --wf-udp=%PortFilter%" )
				) else (
					if "x!sWinDivert!"=="x" ( set "sWinDivert=--wf-udp=%%~N" ) else ( set "sWinDivert=!sWinDivert! --wf-udp=%%~N" )
				)
			) else if "x!fletter!"=="x--filter-udp" (
				if "x%%~N"=="x" (
					if "x%PortFilter%"=="x0" (
						set "skip_profile=on"
						call:cecho 1 "Исключен" 7 "WinWS фильтр с параметром" 3 "'PortFilter=0'"
					)
					set "profile_param=!profile_param! --filter-udp=%PortFilter%"
				) else set "profile_param=!profile_param! --filter-udp=%%~N"
			) else if "x!fletter!"=="x--filter-tcp" (
				if "x%%~N"=="x" (
					if "x%PortFilter%"=="x0" (
						set "skip_profile=on"
						call:cecho 1 "Исключен" 7 "WinWS фильтр с параметром" 3 "'PortFilter=0'"
					)
					set "profile_param=!profile_param! --filter-tcp=%PortFilter%"
				) else set "profile_param=!profile_param! --filter-tcp=%%~N"
			) else if "x!fletter!"=="x--dpi-desync-split-seqovl-pattern" (
				set "foo=%%~N"
				set "foo=!foo: =!"
				if "x!foo:~0,2!"=="x0x" (
					set "profile_param=!profile_param! !fletter!=%%~N"
				) else (
					if exist %fakedir%\%%~N ( 
						set "profile_param=!profile_param! !fletter!=%fakedir%\%%~N"
					) else (
						call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%fakedir%\%%~N'"
						call:cecho 7 "Параметр" 3 "!fletter!=%%~N" 1 "отброшен"	
					)
				)
			) else if "x!fletter!"=="x--dpi-desync-fake-quic" (
				set "foo=%%~N"
				set "foo=!foo: =!"
				if "x!foo:~0,2!"=="x0x" (
					set "profile_param=!profile_param! !fletter!=%%~N"
				) else (
					if exist %fakedir%\%%~N ( 
						set "profile_param=!profile_param! !fletter!=%fakedir%\%%~N"
					) else (
						call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%fakedir%\%%~N'"
						call:cecho 7 "Параметр" 3 "!fletter!=%%~N" 1 "отброшен"	
					)
				)
			) else if "x!fletter!"=="x--dpi-desync-fake-unknown-udp" (
				set "foo=%%~N"
				set "foo=!foo: =!"
				if "x!foo:~0,2!"=="x0x" (
					set "profile_param=!profile_param! !fletter!=%%~N"
				) else (
					if exist %fakedir%\%%~N ( 
						set "profile_param=!profile_param! !fletter!=%fakedir%\%%~N"
					) else (
						call:cecho 1 "Ошибка." 7 "Файл не найден:" 3 "'%fakedir%\%%~N'"
						call:cecho 7 "Параметр" 3 "!fletter!=%%~N" 1 "отброшен"	
					)
				)
			) else if "x!fletter!"=="x--new" (
				if "x!skip_profile!"=="xoff" (
					set /a scount=!scount! + 1
					if "x!tmp_profile_param!"=="x" ( set "tmp_profile_param=!profile_param!" ) else ( set "tmp_profile_param=!tmp_profile_param! !profile_param!" )
					set "profile_param=--new"
					if "x!sabout!"=="x" ( 
						if not "x!psabout!"=="x" set "sabout=!psabout!" 
					) else ( 
						if not "x!psabout!"=="x" set "sabout=!sabout! !psabout!" 
					)
				) else (
					if "x%IPsetStatus%"=="xoff" call:cecho 1 "Исключен" 7 "WinWS фильтр с параметром" 3 "'IPset=off'"
					set "psabout=" 
					set "profile_param= "
					set "skip_profile=off"
				)
			) else if "x%%~N"=="x" (
				set "profile_param=!profile_param! %%~M"
			) else set "profile_param=!profile_param! %%~M=%%~N"
		)
	)
	
	if "x!skip_WinDivert!"=="xoff" (
		if "x!skip_profile!"=="xoff" (
			set /a scount=!scount! + 1
			if "x!tmp_profile_param!"=="x" ( 
				set "tmp_profile_param=!profile_param!" 
			) else (
				set "tmp_profile_param=!tmp_profile_param! !profile_param!"
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
			set "winws_arg!pcount!=!sWinDivert! !tmp_profile_param!"
			if "x!psabout!"=="x" ( 
				set "sabout=no about" 
			)
			echo.!sabout!>>%home%\strategy\%strategy_name%\log\!pcount!-about.log
		)
	)
)

for /f "delims=" %%I in ('%winwsdir%\winws.exe --version') do set "foo=%%I"
set foo=%foo:(=[%
set foo=%foo:)=]%
call:cecho 7 "Создано профилей:" 3 "'%scount%'"
call:cecho 7 "Windivert" 3 "'%foo%'" 7 "initialized"

for /l %%i in (1,1,%pcount%) do (
	set "sabout=x"
	if exist %home%\strategy\%strategy_name%\log\%%i-about.log set /p sabout=<%home%\strategy\%strategy_name%\log\%%i-about.log
	set "foo=!winws_arg%%i!"
	echo.!foo!>>%home%\strategy\%strategy_name%\log\%%i-run.log
	set "debug_status=%debug%"
	if "x%debug%"=="xon" (
		set foo=--debug=1 !foo!
	) else if "x%debug%"=="xoff" (
		set foo=!foo!
	) else (
		if not exist %home%\strategy\%strategy_name%\debug md %home%\strategy\%strategy_name%\debug >nul
		del /F /Q %home%\strategy\%strategy_name%\debug\* >nul
		set foo=--debug=@%home%\strategy\%strategy_name%\debug\%%i-debug.log !foo!
		call:cecho 7 "Запись отладочных сообщений стратегии в файл" 3 "'%home%\strategy\%strategy_name%\debug\%%i-debug.log'"
	)
	
	if "x%daemon%"=="xon" set foo=--daemon !foo!
	set foo=--comment [%strategy_name%][%PortFilter%][%IPsetStatus%][!sabout!][%daemon%][%debug%] !foo!
	echo.!foo!>%home%\strategy\%strategy_name%\log\%%i-dry-run.log
	call:cecho 7 "Проверка параметров" 3 "'%strategy_name%' [!sabout!]"
	%winwsdir%\winws.exe --dry-run !foo! 2>&1 1>%home%\bin\status
	if %errorlevel% neq 0 goto:strategy_list_arg_error
	call:cecho 7 "Запуск" 3 "'%strategy_name%' [!sabout!]"
	if "x%daemon%"=="xoff" start "%strategy_name%:[!sabout!] PortFilter:[%PortFilter%] IPset:[%IPsetStatus%] Debug:[%debug%]" %winwsdir%\winws.exe !foo!
	if "x%daemon%"=="xon" %winwsdir%\winws.exe !foo! 1>nul 2>&1
	if %errorlevel% neq 0 goto:strategy_list_arg_error
)
if %pcount% neq 0 ( 
	call:cecho 2 "Готово" 
) else call:cecho 1 "Отсутствуют параметры стратегии" 

set /a ecode=0
:strategy_list_end
echo.
pause
REM for /l %%x in (5,-1,1) do (
	REM echo.[F
	REM <nul set /p =[5G[37mВозврат в меню через [32m%%x[37m с.[0m
	REM timeout /T 1 /NOBREAK >nul
REM )
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
call:cecho 1 "Ошибка." 7 "Подробности смотри в" 3 "'%home%\bin\status'"
set /a ecode=1
goto:strategy_list_end

:menu_0
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p =[5G[37mВыход через [32m%%x[37m с.[0m
	timeout /T 1 /NOBREAK >nul
)
exit /b

:menu_1
if "x%daemon%"=="xon" ( set "daemon=off" ) else ( set "daemon=on" )
echo.%daemon%>%home%\bin\daemonpar
goto menu

:menu_2
if "x%debug%"=="xon" (
	set "debug=@filename"
) else if "x%debug%"=="xoff" (
	set "debug=on"
) else if "x%debug%"=="x@filename" set "debug=off"
echo.%debug%>%home%\bin\debugpar
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
pause
goto:menu_0

:blockcheck
echo.
if not exist %home%\bin\zapret-win-bundle-master\cygwin\bin\bash (
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
	goto menu
)
set /a blkc=1
if defined strategy_run goto:terminate_all
set /a blkc=0

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
	echo SKIP_TPWS=1
	echo SKIP_DNSCHECK=1
	echo SECURE_DNS=0
	echo IPVS=4
	echo ENABLE_HTTP=1
	echo ENABLE_HTTPS_TLS12=1
	echo ENABLE_HTTPS_TLS13=0
	echo ENABLE_HTTP3=0
	echo REPEATS=8
	echo PARALLEL=1
	echo SCANLEVEL=standard
	echo BATCH=1
	echo DOMAINS="!foo!"
)>%home%\bin\zapret-win-bundle-master\blockcheck\zapret\config_win
chcp 1251 >nul
if exist %home%\bin\zapret-win-bundle-master\blockcheck\zapret\config del /F /Q %home%\bin\zapret-win-bundle-master\blockcheck\zapret\config

rem CRLF to LF
rem ----------------- http://stackoverflow.com/a/6379861/1012053
(set LF=^
%=EMPTY=%
)
for /F "delims=" %%a in (d:\dpi\bin\zapret-win-bundle-master\blockcheck\zapret\config_win) do (
	<nul set /p =%%a!LF!>>%home%\bin\zapret-win-bundle-master\blockcheck\zapret\config
)
rem ----------------- http://stackoverflow.com/a/6379861/1012053

start %home%\bin\zapret-win-bundle-master\cygwin\bin\bash -i "%home%\bin\zapret-win-bundle-master\blockcheck\zapret\blog.sh"
echo.[5G[37mСканирование доменов из листа '[33m%home%\lists\blockcheck.txt[37m' запущено.[0m
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
echo.
echo.[5G[37mHelp[0m
echo.
pause
goto:menu
