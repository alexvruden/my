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
echo.#>dump.csv.domain.txt
echo.#>dump.csv.ipv4.txt
echo.#>dump.csv.ipv6.txt
(set LF=^
%=EMPTY=%
)
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
			)
		)
	)
	set /a count+=1
 	<nul set /p =[2K[3;0H[?25lПрогресс: !count!/%total%
)
echo.
echo.Количество доменов: %count_dom%
echo.Количество ipv4   : %count_ipv4%
echo.Количество ipv6   : %count_ipv6%
echo.
echo.Нажмите любую клавишу для выхода.
pause >nul
