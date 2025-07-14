@echo off
chcp 1251 >nul
set "home=%~1"
echo.start>%home%\bin\agent_mode
set /a s0=0
set /a s1=0

:@loop
set /p mode=<%home%\bin\agent_mode
set mode=%mode: =%
set /p cmd_run=<%home%\bin\agent_start_cmd
if "x%mode%"=="xstop" goto:@stop
if "x%mode%"=="xstart" goto:@start
:@loop_
timeout /T 30 /NOBREAK >nul
goto:@loop

:@start
if %s1% equ 0 start "start" %cmd_run%
set /a s1=1
set /a s0=0
echo.started '%cmd_run%' >%home%\bin\agent_status
goto:@loop_

:@stop
if %s0% equ 0 start "stop" %home%\run.cmd stop
set /a s1=0
set /a s0=1
echo.stoped>%home%\bin\agent_status
goto:@loop_
