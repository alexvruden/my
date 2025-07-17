@echo off
setlocal EnableDelayedExpansion
chcp 1251 >nul

rem ----------settings-------------------
set /a debug = 0
set "log_debug=nul"
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
set "curtime=%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%"
set "curtime=%curtime: =0%"
set "lastmesm=инициализация."
if %debug% equ 1 (
	echo.%curtime% неизвестное состояние...
	set log_debug=%home%\bin\agent_log_debug
)
echo.%curtime% %lastmesm%>%home%\bin\agent_status
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
set "update_status="
set /a restart_from_agent=0

:@loop
set /p mode=<%home%\bin\agent_mode
if exist %home%\bin\agent_update_status (
	set /p update_status=<%home%\bin\agent_update_status
)
if "x%update_status%"=="xupdate" (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	set "lastmesm=получен сигнал 'update'"
	echo.!curtime! !lastmesm!>>%home%\bin\agent_status
	set /a ping_ok=0
	set /a ping_err=0
	set /a start_ok=0
	set /a start_err=0
	set /a ping_err_count=0
)
set mode=%mode: =%
set /p cmd_run=<%home%\bin\agent_start_cmd
for /l %%a in (1,1,1000) do (
	if "x!home:~%%a,1!"=="x" (
		set "cmd_run_short=!cmd_run:~%%a!"
		goto:@break
	)
)
:@break
set /a mesme = %mesme% + 1
set /a foo = %loop_period% * 300 / 60
if %mesme% gtr 300 (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	echo.!curtime! я еще жив, маякну через %foo% мин., наверное ... >>%home%\bin\agent_status
	echo.!curtime! !lastmesm!>>%home%\bin\agent_status
	set /a mesme = 0
)
if "x%mode%"=="xstop" goto:@stop
if "x%mode%"=="xstart" goto:@start

:@ping
timeout /T %loop_period% /NOBREAK >nul
ping /n 1 %host_i% >nul
set /a ping_status_i=%errorlevel%
set /a ping_change=%ping_change%+1
if %ping_status_i% equ 0 (
	if %debug% equ 1 ( echo.%curtime% ping %host_i% - ok )
	if %ping_change% geq %start_after_num_err_ping% (
		set /a ping_change=0
		ping /n 4 %host_e% >nul
		set /a ping_status_e=!errorlevel!
		if !ping_status_e! equ 0 (
			if %debug% equ 1 ( echo.%curtime% ping %host_e% - ok )
		) else (
			rem проблема с роутером?
			if %debug% equ 1 ( 
				echo.%curtime% ping %host_e% - loss [проблема с роутером?]
			)
		)
	)
) else if %debug% equ 1 ( echo.%curtime% ping %host_i% - loss )
set /a foo=%ping_status_i%+%ping_status_e%
if %foo% neq 0 (
	set /a ping_ok=0
	set /a ping_err=!ping_err!+1
	if "x%mode%"=="xstart" (
		if !ping_err! equ 1 (
			set /a foo=%loop_period% * %start_after_num_err_ping%
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %debug% equ 1 echo.!curtime! нет интернета, рестарт через !foo! сек.
			if %start_trigger% equ 1 (
				set "lastmesm=нет интернета, рестарт через !foo! сек."
				echo.!curtime! !lastmesm!>>%home%\bin\agent_status
			)
		)
		set /a ping_err_count=!ping_err_count!+1
		if !ping_err_count! equ %start_after_num_err_ping% (
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %debug% equ 1 echo.!curtime! рестарт
			set "lastmesm=рестарт"
			echo.!curtime! !lastmesm!>>%home%\bin\agent_status
			set /a restart_from_agent=1
		)
	) else (
		if !ping_err! equ 1 (
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %debug% equ 1 echo.!curtime! остановлен, нет интернета
			set "lastmesm=остановлен, нет интернета"
			echo.!curtime! !lastmesm!>>%home%\bin\agent_status
		)
	)
) else (
	set /a ping_err=0
	set /a ping_ok=!ping_ok!+1
	if "x%mode%"=="xstart" set /a start_trigger=1
	if !stop_trigger! equ 1 (
		if !ping_ok! equ 1 (
			set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
			set "curtime=!curtime: =0!"
			if %debug% equ 1 echo.!curtime! остановлен, есть интернет
			set "lastmesm=остановлен, есть интернет"
			echo.!curtime! !lastmesm!>>%home%\bin\agent_status
		)
	)
	if !start_trigger! equ 1 (
		if !start_err! equ 0 (
			if !ping_ok! equ 1 (
				set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
				set "curtime=!curtime: =0!"
				if %debug% equ 1 echo.!curtime! работает '..%cmd_run_short%', есть интернет
				set "lastmesm=работает '..%cmd_run_short%', есть интернет"
				echo.!curtime! !lastmesm!>>%home%\bin\agent_status
			)
		)
	)
)
if "x%update_status%"=="xupdate" (
	echo.ok>%home%\bin\agent_update_status
)
goto:@loop

:@start
if %start_trigger% equ 0 (
	set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
	set "curtime=!curtime: =0!"
	if %debug% equ 1 echo.!curtime! получен сигнал 'start'
	set "lastmesm=получен сигнал 'start'"
	echo.!curtime! !lastmesm!>>%home%\bin\agent_status
	set /a ping_err_count=0
	start "x" %cmd_run%
	set /a stop_trigger=0
	timeout /T 10 /NOBREAK >nul
)
if %restart_from_agent% equ 1 (
	set /a ping_err_count=0
	start "x" %cmd_run%
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
		if %debug% equ 1 echo.!curtime! ошибка запуска или работает пользователь
		set "lastmesm=ошибка запуска или работает пользователь"
		echo.!curtime! !lastmesm!>>%home%\bin\agent_status
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
			if %debug% equ 1 echo.!curtime! работает '..%cmd_run_short%', проверка интернета...
			set "lastmesm=работает '..%cmd_run_short%', проверка интернета..."
			echo.!curtime! !lastmesm!>>%home%\bin\agent_status
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
	if %debug% equ 1 echo.!curtime! остановлен, работает пользователь
	set "lastmesm=получен сигнал 'stop'"
	echo.!curtime! !lastmesm!>>%home%\bin\agent_status
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
		if %debug% equ 1 echo.!curtime! остановлен
	) else (
		set /a stop_trigger = 1
		set "curtime=!TIME:~0,2!.!TIME:~3,2!.!TIME:~6,2!"
		set "curtime=!curtime: =0!"
		if %debug% equ 1 echo.!curtime! остановлен, работает пользователь
	)
)
goto:@ping
