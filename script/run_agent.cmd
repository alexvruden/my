@echo off
setlocal EnableDelayedExpansion
chcp 1251 >nul

rem ----------settings-------------------
set /a show_message_stdout = 0

set "host_e=one.one.one.one"
set /a loop_period = 5
set /a stop_after_num_err_ping = 10
rem -------------------------------------

set "home=%~1"
if "x%home%"=="x" exit
if not exist %home%\run.cmd exit
if exist %home%\agent.log del /f /q %home%\agent.log
call:@message log "инициализация."
set /a start_trigger=0
set /a stop_trigger=0
set /a ping_change=0
set /a ping_status_i=0
set /a ping_status_e=0
set /a ping_ok=0
set /a ping_err=0
set /a ping_err_count=0
set /a start_ok=0
set /a start_err=0
set /a ping_count=0
set /a mesme=0
set /a stop_no_inet=0

:@loop
if not exist %home%\run.cmd exit
for /F "skip=1 eol=# tokens=1,2 delims==" %%a in (%home%\run.config) do set %%~a=%%~b
if not defined ip_router set "ip_router=127.0.0.1"
set agent_mode=%agent_mode: =%
:@break
set /a mesme+=1
set /a foo = %loop_period% * 300 / 60
if %mesme% gtr 300 (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	echo.!curtime! я еще жив, маякну через %foo% мин., наверное>>%home%\agent.log
	echo.!curtime! !lastmesm!>>%home%\agent.log
	set /a mesme = 0
)
if "x%agent_mode%"=="xstop" goto:@stop
if "x%agent_mode%"=="xstart" goto:@start

:@ping
timeout /T %loop_period% /NOBREAK >nul
ping /n 1 %ip_router% >nul
set /a ping_status_i=%errorlevel%
set /a ping_change+=1
if %ping_status_i% equ 0 (
	if %show_message_stdout% equ 1 echo.ping %ip_router% - ok
	if %ping_change% geq %stop_after_num_err_ping% (
		set /a ping_change=0
		ping /n 4 %host_e% >nul
		set /a ping_status_e=!errorlevel!
		if !ping_status_e! equ 0 (
			if %show_message_stdout% equ 1 echo.ping %host_e% - ok
		) else (
			if %show_message_stdout% equ 1 echo.ping %host_e% - loss [проблема с роутером?]
		)
	)
) else if %show_message_stdout% equ 1 echo.ping %ip_router% - loss
	

set /a foo=%ping_status_i%+%ping_status_e%
if %foo% neq 0 (
	set /a ping_ok=0
	set /a ping_err+=1
	if "x%agent_mode%"=="xstart" (
		if !ping_err! equ 1 (
			set /a foo=%loop_period% * %stop_after_num_err_ping%
			if %start_trigger% equ 1 (
				call:@message log "нет интернета, стоп через !foo! сек."

			)
		)
		set /a ping_err_count+=1
		if !ping_err_count! equ %stop_after_num_err_ping% (
			call:@message log "нет интернета, стоп 'winws.exe'"
			if %stop_no_inet% equ 0 start "x" %home%\run.cmd stop
			call:@message log "ждем появления интернета"
			set /a stop_no_inet=1
		)
	) else (
		if !ping_err! equ 1 (
			call:@message log "остановлен пользователем, нет интернета"
		)
	)
) else (
	set /a ping_err=0
	set /a ping_ok+=1
	if !stop_trigger! equ 1 (
		if !ping_ok! equ 1 (
			call:@message log "остановлен пользователем, есть интернет"
		)
	) else (
		if !stop_no_inet! equ 1 (
			if !ping_ok! equ 1 (
				if "x%agent_mode%"=="xstart" (
					call:@message log "есть интернет, запускаем"
					set /a stop_no_inet=0
					set /a start_trigger=0
				)
			)
		)
	)
	if !start_trigger! equ 1 (
		if !ping_ok! equ 1 (
			call:@message log "активирован, есть интернет"
		)
	)
)
goto:@loop

:@start
if %start_trigger% equ 0 (
	call:@message log "получен сигнал 'start'"
	set /a ping_err_count=0
	if defined agent_start_strategy (
		call:@message log "запуск стратегии '%agent_start_strategy%'"
		start "x" %home%\run.cmd start "%agent_start_strategy%" %agent_start_params%
	) else (
		call:@message log "нет стратегии для запуска"
		set /a stop_trigger=0
		set /a start_trigger=1
		goto:@ping
	)
	set /a stop_trigger=0
	set /a start_trigger=1
	timeout /T 10 /NOBREAK >nul
	tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
	if !errorlevel! neq 0 (
		call:@message log "ошибка запуска стратегии '%agent_start_strategy%'"
		set /a ping_ok=0
		set /a ping_err=0
		set /a start_ok=0
		set /a start_err=1
	) else (
		call:@message log "активирован, проверка интернета"
		set /a start_ok=1
		set /a start_err=0
		set /a ping_ok=0
		set /a ping_err=0
	)
)

goto:@ping

:@stop
if %stop_trigger% equ 0 (
	call:@message log "получен сигнал 'stop'"
	start "x" %home%\run.cmd stop
	set /a start_trigger=0
	set /a stop_trigger = 1
	set /a ping_ok=0
	set /a ping_err=0
	set /a start_ok=0
	set /a start_err=0
	set /a ping_err_count=0
	timeout /T 10 /NOBREAK >nul
	tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
	if !errorlevel! neq 0 ( 
		call:@message log "стратегия успешно остановлен"
	) else (
		call:@message log "ошибка завершения стратегии"
	)
)
goto:@ping

:@message
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	set "lastmesm=%~2"
	if %show_message_stdout% equ 1 echo.!curtime! !lastmesm!
	if "x%~1"=="xlog" echo.!curtime! !lastmesm!>>%home%\agent.log
exit /b