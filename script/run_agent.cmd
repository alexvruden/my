@echo off
setlocal EnableDelayedExpansion
chcp 1251 >nul

rem ----------settings-------------------
set /a debug = 1
rem 192.168.1.1 - router
set "host_i=192.168.1.1"
set "host_e=one.one.one.one"
set /a loop_period = 5
set /a start_after_num_err_ping = 10
rem -------------------------------------

set "home=%~1"
set "cmd_run_short="
if "x%home%"=="x" exit
if not exist %home%\run.cmd exit
if %debug% equ 1 echo.неизвестное состояние...
echo.неизвестное состояние...>%home%\bin\agent_status
set /a s0=0
set /a s1=0
set /a ping_change=0
set /a ping_status_i=0
set /a ping_status_e=0
set /a ping_ok=0
set /a ping_err=0
set /a ping_err_count=0
set /a start_ok=0
set /a start_err=0
set /a ping_count=0
set "update_status="
set /a manual=0

:@loop
set /p mode=<%home%\bin\agent_mode
if exist %home%\bin\agent_update_status (
	set /p update_status=<%home%\bin\agent_update_status
)
if "x%update_status%"=="xupdate" (
	set /a ping_ok=0
	set /a ping_err=0
	set /a start_ok=0
	set /a start_err=0
	set /a ping_err_count=0
	set /a manual=0
)
set mode=%mode: =%
set /p cmd_run=<%home%\bin\agent_start_cmd
for /l %%a in (1,1,1000) do (
	if "x!home:~%%a,1!"=="x" (
		set cmd_run_short=!cmd_run:~%%a!
		goto:@break
	)
)
:@break
if "x%mode%"=="xstop" goto:@stop
if "x%mode%"=="xstart" goto:@start

:@ping
timeout /T %loop_period% /NOBREAK >nul
rem set /a ping_count=%loop_period% * %start_after_num_err_ping%
ping /n 1 %host_i% >nul
set /a ping_status_i=%errorlevel%
set /a ping_change=%ping_change%+1
if %ping_status_i% equ 0 (
	if %debug% equ 1 ( echo.ping %host_i% - ok )
	if %ping_change% geq %start_after_num_err_ping% (
		set /a ping_change=0
		ping /n 1 %host_e% >nul
		set /a ping_status_e=!errorlevel!
		if !ping_status_e! equ 0 (
			if %debug% equ 1 ( echo.ping %host_e% - ok )
		) else (
			rem проблема с роутером?
			if %debug% equ 1 ( 
				echo.ping %host_e% - loss [проблема с роутером?]
			)
		)
	)
) else if %debug% equ 1 ( echo.ping %host_i% - loss )
set /a foo=%ping_status_i%+%ping_status_e%
if %foo% neq 0 (
	set /a ping_ok=0
	set /a ping_err=!ping_err!+1
	if "x%mode%"=="xstart" (
		if !ping_err! equ 1 (
			set /a foo=%loop_period% * %start_after_num_err_ping%
			if %debug% equ 1 echo.нет интернета, рестарт через !foo! сек.
			if %s1% equ 1 echo.нет интернета, рестарт через !foo! сек.>%home%\bin\agent_status
		)
		set /a ping_err_count=!ping_err_count!+1
		if !ping_err_count! equ %start_after_num_err_ping% (
			if %debug% equ 1 echo.рестарт
			set /a s1=0
		)
	) else (
		if !ping_err! equ 1 (
			if %debug% equ 1 echo.остановлен, нет интернета
			echo.остановлен, нет интернета>%home%\bin\agent_status
		)
	)
) else (
	set /a ping_err=0
	set /a ping_ok=!ping_ok!+1
	if "x%mode%"=="xstart" set /a s1=1
	if !s0! equ 1 (
		if !ping_ok! equ 1 (
			if %debug% equ 1 echo.остановлен, есть интернет
			echo.остановлен, есть интернет>%home%\bin\agent_status
		)
	)
	if !s1! equ 1 (
		if !ping_ok! equ 1 (
			if %manual% equ 0 (
				if %debug% equ 1 echo.работает '..%cmd_run_short%', есть интернет
				echo.работает '..%cmd_run_short%', есть интернет>%home%\bin\agent_status
			)
		)
	)
)
if "x%update_status%"=="xupdate" (
	echo.ok>%home%\bin\agent_update_status
)
goto:@loop

:@start
if %s1% equ 0 (
	set /a ping_err_count=0
	start "s1" %cmd_run%
	set /a s0=0
)
for /l %%i in (1,1,10) do (
	timeout /T 1 /NOBREAK >nul
	tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
	if !errorlevel! neq 0 (
		set /a start_ok=0
		set /a start_err=!start_err!+1
		if !start_err! equ 1 (
			if %debug% equ 1 echo.ошибка запуска или работает пользователь
			echo.ошибка запуска или работает пользователь>%home%\bin\agent_status
			set /a manual=1
			set /a ping_ok=0
			set /a ping_err=0
		)
	) else (
		set /a start_err=0
		set /a start_ok=!start_ok!+1
		if %s1% equ 0 (
			if !start_ok! equ 1 (
				if %debug% equ 1 echo.работает '..%cmd_run_short%', проверка интернета...
				echo.работает '..%cmd_run_short%', проверка интернета...>%home%\bin\agent_status
				set /a ping_ok=0
				set /a ping_err=0
			)
			set /a s1=1
		)
		goto:@start_break
	)
)

:@start_break
goto:@ping

:@stop
if %s0% equ 0 (
	start "s0" %home%\run.cmd stop
	set /a s1=0
	set /a ping_ok=0
	set /a ping_err=0
	set /a start_ok=0
	set /a start_err=0
	set /a ping_err_count=0
	set /a manual=0
	for /l %%i in (1,1,10) do (
		timeout /T 1 /NOBREAK >nul
		tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
		if !errorlevel! neq 0 ( 
			set /a s0 = 1
			if %debug% equ 1 echo.остановлен
		) else (
			set /a s0 = 1
			if %debug% equ 1 echo.остановлен, работает пользователь
		)
		goto:@stop_break
	)
)
:@stop_break
goto:@ping
