@echo off
setlocal EnableDelayedExpansion
chcp 1251 >nul
set /a debug=0
set "ping_host=one.one.one.one"
set "home=%~1"
set "cmd_run_short="
if "x%home%"=="x" exit
if not exist %home%\run.cmd exit
if %debug% equ 1 echo.неизвестное состояние...
echo.неизвестное состояние...>%home%\bin\agent_status
set /a s0=0
set /a s1=0
set /a ping_ok=0
set /a ping_err=0
set /a ping_err_count=0
set /a start_ok=0
set /a start_err=0

set /a loop_period=30
rem restart every 60 sec = loop_period * start_after_num_err_ping
set /a start_after_num_err_ping=2

:@loop
set /p mode=<%home%\bin\agent_mode
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
ping /n 1 %ping_host% >nul
if %errorlevel% neq 0 (
	set /a ping_ok=0
	set /a ping_err=!ping_err!+1
	if "x%mode%"=="xstart" (
		if !ping_err! equ 1 (
			set /a foo=%loop_period%*%start_after_num_err_ping%
			if %debug% equ 1 echo.нет интернета, рестарт через !foo! сек.
			if %s1% equ 1 echo.нет интернета, рестарт...>%home%\bin\agent_status
		)
		set /a ping_err_count=!ping_err_count!+1
		if !ping_err_count! equ %start_after_num_err_ping% set /a s1=0
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
			if %debug% equ 1 echo.работает '..%cmd_run_short%', есть интернет
			echo.работает '..%cmd_run_short%', есть интернет>%home%\bin\agent_status
		)
	)
)
goto:@loop

:@start
if %s1% equ 0 (
	set /a ping_err_count=0
	start "s1" %cmd_run%
)
set /a s0=0
timeout /T 5 /NOBREAK >nul
tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if %errorlevel% neq 0 (
	set /a start_ok=0
	set /a start_err=!start_err!+1
	if !start_err! equ 1 (
		if %debug% equ 1 echo.процесс winws.exe не найден
		echo.процесс winws.exe не найден>%home%\bin\agent_status
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
)
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
)
timeout /T 5 /NOBREAK >nul
tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if %errorlevel% neq 0 ( set /a s0=1 )
goto:@ping
