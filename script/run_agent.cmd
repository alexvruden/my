@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
rem ----------settings-------------------
set /a show_message_stdout = 0

set "host_e=one.one.one.one"
set /a loop_period = 5
set /a stop_after_num_err_ping = 10
rem -------------------------------------

set "home=%~1"
if "x%home%"=="x" exit
if not exist %home%\run.cmd exit
if exist %home%\script\agent.log del /f /q %home%\script\agent.log
for /F "skip=1 eol=# tokens=1,2 delims==" %%a in (%home%\run.config) do set %%~a=%%~b
if not defined language goto:@L23
if not exist %home%\lang\%language% goto:@L23
for /f "eol=# tokens=1* delims==" %%a in (%home%\lang\%language%) do (
	if %%~a geq 1000 set lmess%%~a=%%~b
)
goto:@L30
:@L23
for /f "skip=2 tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Control Panel\International" /v "LocaleName"') do set "OSLanguage=%%b"
set OSLanguage=%OSLanguage:-=_%
if not exist %home%\lang\%OSLanguage% set "OSLanguage=ru_RU"
for /f "eol=# tokens=1* delims==" %%a in (%home%\lang\%OSLanguage%) do (
	if %%~a geq 1000 set lmess%%~a=%%~b
)
:@L30
call:@message log "%lmess1000%"
set /a start_trigger=0, stop_trigger=0, ping_change=0, ping_status_i=0, ping_status_e=0, ping_ok=0, ping_err=0, ping_err_count=0, start_ok=0, start_err=0, ping_count=0, mesme=0, stop_no_inet=0
:@loop
if not exist %home%\run.cmd exit
if not exist %home%\run.config exit
for /F "skip=1 eol=# tokens=1,2 delims==" %%a in (%home%\run.config) do set %%~a=%%~b
if not defined ip_router (
	set "ip_router=127.0.0.1"
	call:@message log "%lmess1001%"
)
set agent_mode=%agent_mode: =%
set /a mesme+=1
set /a foo = %loop_period% * 300 / 60
if %mesme% gtr 300 (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	echo.!curtime! %lmess1002% %foo% %lmess1003%>>%home%\script\agent.log
	echo.!curtime! !lastmesm!>>%home%\script\agent.log
	set /a mesme = 0
)
if "x%agent_mode%"=="xstop" goto:@stop
if "x%agent_mode%"=="xstart" goto:@start
:@ping
timeout /T %loop_period% /NOBREAK >nul
ping /n 1 %ip_router% | find "TTL=" 1>nul 2>&1
set /a ping_status_i=%errorlevel%
set /a ping_change+=1
if %ping_status_i% equ 0 (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	if %show_message_stdout% equ 1 echo.!curtime! ping %ip_router% - ok
	set /a foo=%stop_after_num_err_ping%
	if %ping_ok% equ 0 if %ping_err% equ 0 set /a foo=1
	if %ping_change% geq !foo! (
		set /a ping_change=0
		ping /n 4 %host_e% | find "TTL=" 1>nul 2>&1
		set /a ping_status_e=!errorlevel!
		if !ping_status_e! equ 0 (
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %show_message_stdout% equ 1 echo.!curtime! ping %host_e% - ok
		) else if %show_message_stdout% equ 1 echo.!curtime! ping %host_e% - loss
	)
) else if %show_message_stdout% equ 1 echo.ping %ip_router% - loss
set /a foo=%ping_status_i%+%ping_status_e%
if %foo% neq 0 (
	set /a ping_ok=0, ping_err+=1
	if "x%agent_mode%"=="xstart" (
		if !ping_err! equ 1 (
			set /a foo=%loop_period% * %stop_after_num_err_ping%
			if %start_trigger% equ 1 call:@message log "%lmess1004% !foo! %lmess1005%"
		)
		set /a ping_err_count+=1
		if !ping_err_count! equ %stop_after_num_err_ping% (
			call:@message log "%lmess1006%"
			if %stop_no_inet% equ 0 start "x" %home%\run.cmd stop
			call:@message log "%lmess1007%"
			set /a stop_no_inet=1
		)
	) else if !ping_err! equ 1 call:@message log "%lmess1008%"
) else (
	set /a ping_err=0, ping_ok+=1
	if !stop_trigger! equ 1 (
		if !ping_ok! equ 1 call:@message log "%lmess1009%"
	) else (
		if !stop_no_inet! equ 1 (
			if !ping_ok! equ 1 (
				if "x%agent_mode%"=="xstart" (
					call:@message log "%lmess1010%"
					set /a stop_no_inet=0, start_trigger=0
				)
			)
		)
	)
	if !start_trigger! equ 1 if !ping_ok! equ 1 call:@message log "%lmess1011%"
)
goto:@loop
:@start
if %start_trigger% neq 0 goto:@ping
call:@message log "%lmess1012% 'start'"
set /a ping_err_count=0
if defined agent_start_strategy (
	call:@message log "%lmess1013% '%agent_start_strategy%'"
	start "x" %home%\run.cmd start "%agent_start_strategy%" %agent_start_params%
) else (
	call:@message log "%lmess1014%"
	set /a stop_trigger=0, start_trigger=1
	goto:@ping
)
set /a stop_trigger=0, start_trigger=1
timeout /T 20 /NOBREAK >nul
tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if %errorlevel% neq 0 (
	call:@message log "%lmess1015% '%agent_start_strategy%'"
	set /a ping_ok=0, ping_err=0, start_ok=0, start_err=1
) else (
	call:@message log "%lmess1016%"
	set /a start_ok=1, start_err=0, ping_ok=0, ping_err=0
)
goto:@ping
:@stop
if %stop_trigger% neq 0 goto:@ping
call:@message log "%lmess1012% 'stop'"
start "x" %home%\run.cmd stop
set /a start_trigger=0, stop_trigger = 1, ping_ok=0, ping_err=0, start_ok=0, start_err=0, ping_err_count=0
timeout /T 10 /NOBREAK >nul
tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if %errorlevel% neq 0 (call:@message log "%lmess1017%") else (call:@message log "%lmess1018%")
goto:@ping
:@message
set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
set "curtime=!curtime: =0!"
set "lastmesm=%~2"
if %show_message_stdout% equ 1 echo.!curtime! !lastmesm!
if "x%~1"=="xlog" echo.!curtime! !lastmesm!>>%home%\script\agent.log
exit /b