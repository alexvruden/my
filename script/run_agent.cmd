@echo off
setlocal EnableDelayedExpansion
chcp 1251 >nul
set "home=%~1"
set "cmd_run_short="
if "x%home%"=="x" exit
if not exist %home%\run.cmd exit
echo.unknown>%home%\bin\agent_status
set /a s0=0
set /a s1=0

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
timeout /T 30 /NOBREAK >nul
ping /n 1 one.one.one.one >nul
if %errorlevel% neq 0 (
	if "x%mode%"=="xstart" (
		echo.no internet, restart>%home%\bin\agent_status
		start "stop" %home%\run.cmd stop
		timeout /T 10 /NOBREAK >nul
		start "start" %cmd_run%
	) else echo.stoped and no internet>%home%\bin\agent_status
) else (
	if %s0% equ 1 echo.stoped>%home%\bin\agent_status
	if %s1% equ 1 echo.started '..%cmd_run_short%'>%home%\bin\agent_status
)
goto:@loop

:@start
if %s1% equ 0 start "s1" %cmd_run%
set /a s1=1
set /a s0=0
goto:@ping

:@stop
if %s0% equ 0 start "s0" %home%\run.cmd stop
set /a s1=0
set /a s0=1
goto:@ping
