@echo off
setlocal EnableDelayedExpansion
chcp 1251 >nul

rem ----------settings-------------------
set /a show_message_stdout = 0
rem 192.168.1.1 - router
set "host_i=192.168.1.1"
set "host_e=one.one.one.one"
set /a loop_period = 5
set /a start_after_num_err_ping = 10
rem -------------------------------------

set "home=%~1"
if "x%home%"=="x" exit
if not exist %home%\run.cmd exit
set "curtime=%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%"
set "curtime=%curtime: =0%"
set "lastmesm=инициализация."
if %show_message_stdout% equ 1 (
	echo.%curtime% неизвестное состояние...
)
echo.%curtime% %lastmesm%>%home%\agent.log
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
set /a restart_from_agent=0

:@loop
for /F "skip=1 eol=# tokens=1,2 delims==" %%a in (%home%\run.config) do set %%~a=%%~b
if exist %home%\bin\agent_update_status (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	set "lastmesm=получен сигнал 'update'"
	echo.!curtime! !lastmesm!>>%home%\agent.log
	set /a ping_ok=0
	set /a ping_err=0
	set /a start_ok=0
	set /a start_err=0
	set /a ping_err_count=0
	del /F /Q %home%\bin\agent_update_status >nul
)
set agent_mode=%agent_mode: =%
:@break
set /a mesme = %mesme% + 1
set /a foo = %loop_period% * 300 / 60
if %mesme% gtr 300 (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	echo.!curtime! я еще жив, маякну через %foo% мин., наверное ... >>%home%\agent.log
	echo.!curtime! !lastmesm!>>%home%\agent.log
	set /a mesme = 0
)
if "x%agent_mode%"=="xstop" goto:@stop
if "x%agent_mode%"=="xstart" goto:@start

:@ping
timeout /T %loop_period% /NOBREAK >nul
ping /n 1 %host_i% >nul
set /a ping_status_i=%errorlevel%
set /a ping_change=%ping_change%+1
if %ping_status_i% equ 0 (
	if %show_message_stdout% equ 1 ( echo.%curtime% ping %host_i% - ok )
	if %ping_change% geq %start_after_num_err_ping% (
		set /a ping_change=0
		ping /n 4 %host_e% >nul
		set /a ping_status_e=!errorlevel!
		if !ping_status_e! equ 0 (
			if %show_message_stdout% equ 1 ( echo.%curtime% ping %host_e% - ok )
		) else (
			rem проблема с роутером?
			if %show_message_stdout% equ 1 ( 
				echo.%curtime% ping %host_e% - loss [проблема с роутером?]
			)
		)
	)
) else if %show_message_stdout% equ 1 ( echo.%curtime% ping %host_i% - loss )
set /a foo=%ping_status_i%+%ping_status_e%
if %foo% neq 0 (
	set /a ping_ok=0
	set /a ping_err=!ping_err!+1
	if "x%agent_mode%"=="xstart" (
		if !ping_err! equ 1 (
			set /a foo=%loop_period% * %start_after_num_err_ping%
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %show_message_stdout% equ 1 echo.!curtime! нет интернета, рестарт через !foo! сек.
			if %start_trigger% equ 1 (
				set "lastmesm=нет интернета, рестарт через !foo! сек."
				echo.!curtime! !lastmesm!>>%home%\agent.log
			)
		)
		set /a ping_err_count=!ping_err_count!+1
		if !ping_err_count! equ %start_after_num_err_ping% (
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %show_message_stdout% equ 1 echo.!curtime! рестарт
			set "lastmesm=рестарт"
			echo.!curtime! !lastmesm!>>%home%\agent.log
			set /a restart_from_agent=1
		)
	) else (
		if !ping_err! equ 1 (
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %show_message_stdout% equ 1 echo.!curtime! остановлен, нет интернета
			set "lastmesm=остановлен, нет интернета"
			echo.!curtime! !lastmesm!>>%home%\agent.log
		)
	)
) else (
	set /a ping_err=0
	set /a ping_ok=!ping_ok!+1
	if "x%agent_mode%"=="xstart" set /a start_trigger=1
	if !stop_trigger! equ 1 (
		if !ping_ok! equ 1 (
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %show_message_stdout% equ 1 echo.!curtime! остановлен, есть интернет
			set "lastmesm=остановлен, есть интернет"
			echo.!curtime! !lastmesm!>>%home%\agent.log
		)
	)
	if !start_trigger! equ 1 (
		if !start_err! equ 0 (
			if !ping_ok! equ 1 (
				set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
				set "curtime=!curtime: =0!"
				if %show_message_stdout% equ 1 echo.!curtime! работает стратегия '%agent_start_strategy%', есть интернет
				set "lastmesm=работает стратегия '%agent_start_strategy%', есть интернет"
				echo.!curtime! !lastmesm!>>%home%\agent.log
			)
		)
	)
)
goto:@loop

:@start
if %start_trigger% equ 0 (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	if %show_message_stdout% equ 1 echo.!curtime! получен сигнал 'start'
	set "lastmesm=получен сигнал 'start'"
	echo.!curtime! !lastmesm!>>%home%\agent.log
	set /a ping_err_count=0
	if defined agent_start_strategy start "x" %home%\run.cmd start "%agent_start_strategy%" %agent_start_params%
	set /a stop_trigger=0
	timeout /T 10 /NOBREAK >nul
)
if %restart_from_agent% equ 1 (
	set /a ping_err_count=0
	if defined agent_start_strategy start "x" %home%\run.cmd start "%agent_start_strategy%" %agent_start_params%
	set /a stop_trigger=0
	set /a start_trigger=0
	set /a ping_ok=0
	set /a ping_err=0
	set /a start_ok=0
	set /a start_err=0
	set /a ping_err_count=0
	set /a restart_from_agent=0
	timeout /T 10 /NOBREAK >nul
)
tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if %errorlevel% neq 0 (
	set /a start_ok=0
	set /a start_err=!start_err!+1
	if !start_err! equ 1 (
		set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
		set "curtime=!curtime: =0!"
		if %show_message_stdout% equ 1 echo.!curtime! ошибка запуска или работает пользователь
		set "lastmesm=ошибка запуска или работает пользователь"
		echo.!curtime! !lastmesm!>>%home%\agent.log
		set /a ping_ok=0
		set /a ping_err=0
	)
) else (
	set /a start_err=0
	set /a start_ok=!start_ok!+1
	if %start_trigger% equ 0 (
		if !start_ok! equ 1 (
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %show_message_stdout% equ 1 echo.!curtime! работает стратегия '%agent_start_strategy%', проверка интернета...
			set "lastmesm=работает стратегия '%agent_start_strategy%', проверка интернета..."
			echo.!curtime! !lastmesm!>>%home%\agent.log
			set /a ping_ok=0
			set /a ping_err=0
		)
		set /a start_trigger=1
	)
)
goto:@ping

:@stop
if %stop_trigger% equ 0 (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	if %show_message_stdout% equ 1 echo.!curtime! остановлен, работает пользователь
	set "lastmesm=получен сигнал 'stop'"
	echo.!curtime! !lastmesm!>>%home%\agent.log
	start "x" %home%\run.cmd stop
	set /a start_trigger=0
	set /a ping_ok=0
	set /a ping_err=0
	set /a start_ok=0
	set /a start_err=0
	set /a ping_err_count=0
	timeout /T 10 /NOBREAK >nul
	tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
	if !errorlevel! neq 0 ( 
		set /a stop_trigger = 1
		set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
		set "curtime=!curtime: =0!"
		if %show_message_stdout% equ 1 echo.!curtime! остановлен
	) else (
		set /a stop_trigger = 1
		set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
		set "curtime=!curtime: =0!"
		if %show_message_stdout% equ 1 echo.!curtime! остановлен, работает пользователь
	)
)
goto:@ping
