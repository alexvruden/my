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
set /a count=0
set /a count_dom=0
set /a count_ipv4=0
set /a count_ipv6=0
echo.Парсинг 'dump.csv'
echo.
for /f "skip=1 tokens=1,2 delims=;" %%a in (dump.csv) do (
	if not "x%%b"=="x" (
		set "foo=%%b"
		if "x!foo:~0,1!"=="x*" (
			echo.!foo:~2!>>dump.csv.domain.txt
		) else echo.!foo!>>dump.csv.domain.txt
		set /a count_dom+=1
	)
	set "foo=%%a"
	set "foo=!foo:|= !"
	for %%i in (!foo!) do (
		set goo=0
		for /f %%x in ('echo.%%i ^| find "."') do set goo=1
		if !goo! equ 1 (
			echo.%%i >>dump.csv.ipv4.txt
			set /a count_ipv4+=1
		) else (
			echo.%%i >>dump.csv.ipv6.txt
			set /a count_ipv6+=1
		)
	)
	set /a count+=1
 	<nul set /p =[2K[3;0H[?25lПрогресс: !count!
)
echo.
echo.Количество доменов: %count_dom%
echo.Количество ipv4   : %count_ipv4%
echo.Количество ipv6   : %count_ipv6%
echo.
pause