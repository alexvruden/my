@echo off
rem https://github.com/alexvruden/my
chcp 1251 >nul
setlocal EnableDelayedExpansion
if not exist dump.csv (
	echo.Скачать архив и распаковать список.
	echo.https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv.gz
	echo.
	pause
	exit
)
(set LF=^
%=EMPTY=%
)
<nul set /p =#!LF!>dump.csv.domain.txt
<nul set /p =#!LF!>dump.csv.ipv4.txt
<nul set /p =#!LF!>dump.csv.ipv6.txt
set /a count=0
set /a total=0
set "str_dom="
set /a count_dom=0
set "str_ipv4="
set /a count_ipv4=0
set "str_ipv6="
set /a count_ipv6=0
echo.Парсинг 'dump.csv'
echo.
<nul set /p =[2K[3;0H[?25lЧитаем список...
for /f "skip=1" %%a in (dump.csv) do set /a total+=1
call:progress_in_percent_begin %total%
for /f "skip=1 tokens=1,2 delims=;" %%a in (dump.csv) do (
	if not "x%%b"=="x" (
		set "foo=%%b"
		if "x!foo:~0,1!"=="x*" (
			set "str_dom=!str_dom!!LF!!foo:~2!"
		) else (
			set "str_dom=!str_dom!!LF!!foo!"
		)
		set /a count_dom+=1
		if not "x!str_dom:~8000,1!"=="x" (
			<nul set /p =!str_dom!!LF!>>dump.csv.domain.txt
			set "str_dom="
		)
	)
	set "foo=%%a"
	set "foo=!foo:|= !"
	for %%i in (!foo!) do (
		set goo=0
		for /f %%x in ('echo.%%i ^| find "."') do set goo=1
		if !goo! equ 1 (
			set str_ipv4=!str_ipv4!!LF!%%i
			set /a count_ipv4+=1
			if not "x!str_ipv4:~8000,1!"=="x" (
				<nul set /p =!str_ipv4!!LF!>>dump.csv.ipv4.txt
				set "str_ipv4="
			)
		) else (
			set str_ipv6=!str_ipv6!!LF!%%i
			set /a count_ipv6+=1
			if not "x!str_ipv6:~8000,1!"=="x" (
				<nul set /p =!str_ipv6!!LF!>>dump.csv.ipv6.txt
				set "str_ipv6="
				set /a show=1
			)
		)
	)
	set /a count+=1
	call:progress_in_percent_count pr
	<nul set /p =[2K[3;0H[?25lПрогресс: !count!/%total% [!pr!%%]
)
<nul set /p =[2K[3;0H[?25lГотово
echo.
echo.Количество доменов : %count_dom%
echo.Количество ipv4    : %count_ipv4%
echo.Количество ipv6    : %count_ipv6%
echo.
echo.Нажмите любую клавишу для выхода.
pause >nul
exit

:progress_in_percent_begin
if defined pinp goto:@progress_in_percent_begin_exit
set /a progress_in_percent_begin_max=%~1
set /a temp_percent_count=0
set /a pinp = 0
set /a percent_step = %progress_in_percent_begin_max% / 100
set /a pinp_count=1
if %percent_step% neq 0 (
	if %progress_in_percent_begin_max% geq 1000 (
		set "decimal=%progress_in_percent_begin_max:~2,2%"
	) else (
		set "decimal=%progress_in_percent_begin_max:~1,2%"
	)
	if !decimal! equ 0 set /a decimal=1
	set /a correction = 100 / !decimal!
	set /a foo=0
	for /L %%c in (0,1,99) do (
		set /a percent_step%%c=%percent_step%
		if !foo! equ !correction! (
			set /a percent_step%%c+=1
			set /a foo=0
		) else set /a foo+=1
	)
	goto:@progress_in_percent_begin_exit
)
set /a percent_step = %progress_in_percent_begin_max% / 10
set /a pinp_count=10
if %percent_step% neq 0 (
	set "decimal=%progress_in_percent_begin_max:~1,1%"
	if !decimal! equ 0 set /a decimal=1
	set /a correction = 100 / !decimal!
	set /a foo=0
	for /L %%c in (0,1,99) do (
		set /a percent_step%%c=%percent_step%
		if !foo! equ !correction! (
			set /a percent_step%%c+=1
			set /a foo=0
		) else set /a foo+=1
	)
	goto:@progress_in_percent_begin_exit
)
set /a percent_step=%progress_in_percent_begin_max%
set /a pinp_count=100 / %percent_step%
set /a foo=0
for /L %%c in (0,1,99) do set /a percent_step%%c=%percent_step%
:@progress_in_percent_begin_exit
exit /b

:progress_in_percent_count
set /a temp_percent_count+=1
if %pinp% lss 100 (
	if %temp_percent_count% equ !percent_step%pinp%! (
		set /a temp_percent_count=0
		set /a pinp+=%pinp_count%
	)
)
set /a %~1=%pinp%
exit /b
