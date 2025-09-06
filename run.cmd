@echo off

REM ======================================================================================

REM https://github.com/alexvruden/my

REM Description: Bypassing Censorship DPI 

REM Download from: https://github.com/alexvruden/my

REM ======================================================================================

2>nul powershell -Command "$Host.UI.SupportsVirtualTerminal" |find "True" >nul 2>&1 ||((echo.Terminal not support ANSI Escape codes.) &(echo.Exit.) &(echo.) &pause &exit)
echo.c([39;49m[7l[?12l[?25l
chcp 65001 > nul
setlocal EnableDelayedExpansion
for /f "skip=2 tokens=2*" %%a in ('2^>nul reg query "HKEY_CURRENT_USER\Control Panel\International" /v "LocaleName"') do set "OSLanguage=%%b"
if defined OSLanguage set OSLanguage=%OSLanguage:-=_%
set /a mode_con_cols=160, mode_con_lines=50, srv_trigger=0, term_trigger=0, param_trigger=1, strategy_trigger=0, ecode=0, homestrsize=0
set "home=%~dp0"
rem -- meta
set "foo=[32m"
set /a meta=0, cb=0
:@loopL9
set /a sf=0, fb=0
for /L %%c in (%cb%,1,255) do (
	if !fb! equ 0 (
		if "x!home:~%%c,1!"=="x)" (set /a sf=1, meta=1)
		if "x!home:~%%c,1!"=="x(" (set /a sf=1, meta=1)
		
		if "x!home:~%%c,1!"=="x\" set fb=1
		if "x!home:~%%c,1!"=="x" goto:@F
	)
)
if %sf% equ 1 set foo=%foo%[31m
set fb=0
for /L %%c in (%cb%,1,255) do (
	if "x!home:~%%c,1!"=="x" set fb=1
	if !fb! equ 0 (
		if not "x!home:~%%c,1!"=="x\" (
			set foo=!foo!!home:~%%c,1!
		) else (
			if %sf% equ 1 (
				set foo=!foo![32m!home:~%%c,1!
			) else set foo=!foo!!home:~%%c,1!
			set /a cb=%%c+1, fb=1
		)
	)
)
goto:@loopL9
:@F
if not "x%OSLanguage%"=="xru_RU" goto:@F
set hoo=Нажмите любую клавишу для выхода.
set coo=Ошибка.
goto:@L43
:@F
set hoo=Press any key to exit.
set coo=Error.
:@L43
set "foo=%foo%[m"
rem -- meta
set "home=%home:~0,-1%"
set "homenc=%home%"
if %meta% neq 1 goto:@L51
echo.
if not "x%OSLanguage%"=="xru_RU" goto:@F
echo.[5G[31mПуть к директории скрипта содержит метасимволы.[m
echo.
echo.[5GРабота скрипта в директории [ %foo% ] невозможна
echo.[5GПереместите файлы скрипта в другую директорию.
echo.
echo.[5G%hoo%
goto:@L45
:@F
echo.[5G[31mThe path to the script directory contains metacharacters.[m
echo.
echo.[5GScript cannot work in [ %foo% ] directory
echo.[5GMove the script files to another directory.
echo.
echo.[5G%hoo%
:@L45
pause >nul
exit
:@L51
for %%i in ("%home%") do set "home=%%~si"

if exist %home%\script\run_agent.cmd goto:@L75
echo.
if not "x%OSLanguage%"=="xru_RU" goto:@F
echo.[5G[31mЗапуск из архива без распаковки недопустим.[m 
echo.
echo.[5G%hoo%
goto:@L73
:@F
echo.[5G[31mRunning from an archive without unpacking is unacceptable.[m 
echo.
echo.[5G%hoo%
:@L73
pause >nul
exit
:@L75

for /L %%i in (1024,-1,1) do (
	if not "x!home:~%%i,1!"=="x" (
		set /a homestrsize=%%i + 2
		goto:@F
	)
)
:@F
cls
echo.
if "x%OSLanguage%"=="xru_RU" set "foo=Чтение языкового файла"
if not "x%OSLanguage%"=="xru_RU" set "foo=Reading language file"
if x%~1==xdebug-lang set debug=debug
if defined debug set "foo=Debug language"
if not exist %home%\lang\%OSLanguage% (
	if exist %home%\lang\%OSLanguage%.original (
		copy /y %home%\lang\%OSLanguage%.original %home%\lang\%OSLanguage% 1>nul 2>&1
	) else (
		if not exist %home%\lang\en_US (
			if exist %home%\lang\en_US.original (
				copy /y %home%\lang\en_US.original %home%\lang\en_US 1>nul 2>&1
				set "OSLanguage=en_US"
			)
		)
	)
)
if exist %home%\lang\%OSLanguage% set "coo=[OS]"
set /a line_count=2
<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%foo% '%OSLanguage%' %coo%[m[E
if "%coo%"=="[OS]" goto:@F
echo.
echo.[5G%hoo%
pause >nul
exit
:@F
for /f "eol=# tokens=1* delims==" %%a in (%home%\lang\%OSLanguage%) do (
	set lmess%%~a=%%~b
	if defined debug if %%~a lss 500 if %%~a neq 1 if %%~a neq 61 if %%~a neq 62 if %%~a neq 67 if %%~a neq 81 set lmess%%~a=lang%%~a
)
chcp %lmess1% >nul
for /L %%c in (500,1,510) do (
	if defined lmess%%c (
		set foo=0
		for /L %%i in (10,-1,0) do (
			if !foo! equ 0 if not "x!lmess%%c:~%%i,1!"=="x" (
				set /a lmess%%c_size=%%i+1
				set foo=1
			)
		)
	)
)
set "fakedir="
set /a profile_count=0
set "arg_1=%~1"
set "arg_2=%~2"
set "arg_3=%~3"
set foo=0
if defined arg_1 for %%a in (start stop debug-lang) do if "x%arg_1%"=="x%%a" set foo=1
if defined arg_1 if %foo% neq 1 echo.[5G[m%lmess94%. &goto:menu_0
>nul 2>&1 powershell -Help &&(
	set "_pwsh=powershell"
)||(
	echo.
	echo.[5G[m%lmess6% '[32mPowerShell[m'
	echo.
	echo.[5G%lmess5%
	pause >nul
	exit
)
>nul 2>&1 pwsh -v &&set "_pwsh_7=pwsh"
>nul 2>&1 net session &&goto:@L141
echo.
echo.[5G[m%lmess3% '[32m%lmess4%[m'.
echo.
<nul set /p =[5G
choice /N /C:%lmess507%%lmess508% /D %lmess507:~0,1% /T 300 /M "%lmess19% (%lmess508:~0,1%|%lmess507:~0,1%): "
if %errorlevel% equ 255 goto:@F
if %errorlevel% equ 0 goto:@F
if %errorlevel% leq %lmess507_size% goto:@L136
>nul 2>&1 net user admin ||goto:@F
echo.
runas /user:admin "%home%\run.cmd" &&exit
:@F
echo.
echo.[5G[31m%lmess20%.[m
:@L136
echo.
echo.[5G%lmess5%
pause >nul
exit
:@L141
if not exist %home%\bin  md %home%\bin 1>nul 2>&1
if not exist %home%\lists\hostlist  md %home%\lists\hostlist 1>nul 2>&1
if not exist %home%\lists\ipset  md %home%\lists\ipset 1>nul 2>&1
if not exist %home%\run.config (
	set /a line_count+=1
	<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%lmess7% 'run.config'[m[E
	(
	echo.# Generate from script. Do not edit this config
	echo.
	echo.eula=
	echo.
	echo.language=
	echo.show_popup=off
	echo.
	echo.check_update=on
	echo.new_version_available=
	echo.
	echo.daemon=on
	echo.custom_strategy=off
	echo.IPsetStatus=off
	echo.
	echo.# params for agent
	echo.
	echo.ip_router=
	echo.agent_mode=start
	echo.agent_start_strategy=none
	echo.agent_start_params=100
	)>%home%\run.config
)
set "bin_curl="
for /f "delims=" %%a in ('2^>nul dir /b /s %home%\bin\curl.exe') do (
	for %%i in ("%%~a") do (
		set "foo=%%~sdpi"
		if exist !foo!curl-ca-bundle.crt set "bin_curl=!foo!"
	)
)
if defined bin_curl set "bin_curl=%bin_curl:~0,-1%"
if not exist %home%\find-strategy-config.txt (
	set /a line_count+=1
	<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%lmess7% 'run.config'[m[E
	call:find_strategy_create_cfg
)
set /a line_count+=1
<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%lmess8% 'run.config'[m[E
for /F "skip=1 eol=# tokens=1,2 delims==" %%a in (%home%\run.config) do (
	set foo=%%a
	set /a aoo=0
	for %%i in (show_popup language new_version_available check_update eula daemon custom_strategy IPsetStatus ip_router agent_mode agent_start_strategy agent_start_params) do (
		if "x%%i"=="x!foo!" set /a aoo=1
	)
	if !aoo! equ 1 (
		set goo=%%b
		if not "x!foo!"=="xagent_start_strategy" (
			if defined goo set goo=!goo: =!
		)
		set !foo!=!goo!
	)
)
if not defined language goto:@F
if not exist %home%\lang\%language% if exist %home%\lang\%language%.original copy /y %home%\lang\%language%.original %home%\lang\%language% 1>nul 2>&1
if not exist %home%\lang\%language% goto:@F
set /a line_count+=1
<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%lmess2% '%language%' [config][m[E
chcp 65001 >nul
for /f "eol=# tokens=1* delims==" %%a in (%home%\lang\%language%) do set lmess%%~a=%%~b
chcp %lmess1% >nul
for /L %%c in (500,1,510) do (
	if defined lmess%%c (
		set foo=0
		for /L %%i in (10,-1,0) do (
			if !foo! equ 0 if not "x!lmess%%c:~%%i,1!"=="x" (
				set /a lmess%%c_size=%%i+1
				set foo=1
			)
		)
	)
)
:@F
set /a line_count+=1
<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%lmess9%[m[E
for /f "tokens=4,5,6 delims=[]. " %%a in ('ver') do (
	set b_ma=%%a%%b
	set b_mi=%%c
)
set "win_ver="
set "win_ver7="
for /f "tokens=3* delims= " %%a in ('2^>nul reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName ^| findstr "ProductName"') do set "os_name=%%a %%b"
if defined b_ma if defined os_name (
	set "win_ver_warn=[5G[31m%lmess10%[37m[E[5G%lmess11%:[E"
	set "win_ver_arch=[5G[36mArchitecture[37m: %PROCESSOR_ARCHITECTURE% [36mOS[37m:"
	if %b_ma% lss 62 (
		set win_ver=!win_ver_arch! %os_name%[E
		set win_ver=!win_ver!!win_ver_warn!
		set win_ver=!win_ver![5Ghttps://github.com/bol-van/zapret/blob/master/docs/windows.md#windows-7-и-windivert[E
		set "win_ver7=true"
	) else 	if %b_ma% lss 100 (
		set win_ver=!win_ver_arch! %os_name%[E
		set win_ver=!win_ver!!win_ver_warn!
		set win_ver=!win_ver![5Ghttps://github.com/bol-van/zapret-win-bundle#zapret-winws-bundle-for-windows[E
	) else if %b_ma% equ 100 (
		if %b_mi% lss 22000 (
			set win_ver=!win_ver_arch! %os_name%[E
		) else 	if %b_mi% geq 22000 (
			if "x%PROCESSOR_ARCHITECTURE%"=="xARM64" (
				set win_ver=!win_ver_arch! %os_name%[E
				set win_ver=!win_ver!!win_ver_warn!
				set win_ver=!win_ver![5Ghttps://github.com/bol-van/zapret-win-bundle#arm64-подготовка[E
			) else (
				set win_ver=!win_ver_arch! %os_name%[E
			)
		)
	) else (
		set win_ver=!win_ver_arch! %os_name%[E
	)
)
set "title_ver="
set "foo=0"
set dnsfound=0
set "arch=none"
set "archd=0"
set "cygwindir="
set "zapret_win_bundle_master="
for /f "delims=" %%i in ('2^>nul dir /b /s %home%\bin\bash.exe') do set cygwindir=%%~i
if defined cygwindir for %%i in ("%cygwindir%") do set "cygwindir=%%~sdpi"
if defined cygwindir set "zapret_win_bundle_master=%cygwindir%..\..\"
if not "x%PROCESSOR_ARCHITECTURE%"=="xARM64" (
	if defined win_ver7 (
		rem Windows 7
		if "x%PROCESSOR_ARCHITECTURE%"=="xAMD64" (
			for /f "delims=" %%I in ('2^>nul dir /b /s /a:d %home%\bin\windows-x86_64') do set winwsdir=%%~I
			if defined winwsdir (
				if not exist !winwsdir!\..\windows-7-amd64 (
					set /a line_count+=1
					echo.
					set /a line_count+=1
					echo.[!line_count!H[5G%lmess12% [36mWindows 7 AMD64[m, %lmess13%.
					set /a line_count+=1
					echo.
					set /a line_count+=1
					echo.[!line_count!H[5G%lmess14%:
					set /a line_count+=1
					echo.
					set /a line_count+=1
					echo.[!line_count!H[5G1. %lmess15% '[33m..\!winwsdir:~%homestrsize%!\..\windows-7-amd64[m'
					set /a line_count+=1
					echo.[!line_count!H[5G2. %lmess16% '[33m..\!winwsdir:~%homestrsize%!\[m'
					set /a line_count+=1
					echo.[!line_count!H[5G3. %lmess17% '[33mWinDivert64.sys[m', '[33mWinDivert.dll[m' %lmess18% [36mWindows 7 AMD64[m
					set /a line_count+=1
					echo.
					set /a line_count+=1
					echo.[!line_count!H[5G%lmess11%:
					set /a line_count+=1
					echo.[!line_count!H[5Ghttps://github.com/bol-van/zapret/blob/master/docs/windows.md#windows-7-и-windivert
					set /a line_count+=1
					echo.
					<nul set /p =[5G
					choice /N /C:%lmess507%%lmess508% /D %lmess507:~0,1% /T 300 /M "%lmess19% (%lmess508:~0,1%|%lmess507:~0,1%): "
					if !errorlevel! neq 255 if !errorlevel! neq 0 if !errorlevel! gtr %lmess507_size% set /a line_count+=15 &goto:@L394
					set /a line_count+=2
				) else (
					set "winwsdir=!winwsdir!\..\windows-7-amd64"
					set "arch=windows-7-amd64"
					set "archd=64"
				)
			)
			set "foo=1"
		) else (
			set "foo=0"
		)
	)
	if !foo! equ 0 (
		set "arch="
		set "archd="
		for /f "tokens=2 delims=:" %%i in ('2^>nul %_pwsh% -Command "Get-CimInstance Win32_operatingsystem | select OSArchitecture | Format-List -Property *"') do set archd=%%i
		if defined archd set archd=!archd: =!
		if "x!archd:~0,2!"=="x32" (set "arch=windows-x86") else (set "arch=windows-x86_64" )
		if defined archd set archd=!archd:~0,2!
		set "winwsdir="
		for /f "delims=" %%I in ('2^>nul dir /b /s /a:d %home%\bin\!arch!') do set winwsdir=%%~I
	)
) else (
	rem Windows ARM64
	set "foo=windows-x86_64"
	for /f "delims=" %%I in ('2^>nul dir /b /s /a:d %home%\bin\!foo!') do set "winwsdir=%%~I"
	if defined winwsdir (
		if not exist !winwsdir!\..\windows-arm64 (
			set /a line_count+=1
			echo.
			set /a line_count+=1
			echo.[!line_count!H[5G%lmess12% [36mARM64[m, %lmess13%.
			set /a line_count+=1
			echo.
			set /a line_count+=1
			echo.[!line_count!H[5G%lmess14%:
			set /a line_count+=1
			echo.
			set /a line_count+=1
			echo.[!line_count!H[5G1. %lmess24% '[36mtestsigning[m'
			set /a line_count+=1
			echo.[!line_count!H[5G2. %lmess15% '[33m..\!winwsdir:~%homestrsize%!\..\windows-arm64[m'
			set /a line_count+=1
			echo.[!line_count!H[5G3. %lmess16% '[33m..\!winwsdir:~%homestrsize%!\[m'
			set /a line_count+=1
			echo.[!line_count!H[5G4. %lmess17% '[33mWinDivert64.sys[m' %lmess18% [36mARM64[m
			set /a line_count+=1
			echo.[!line_count!H[5G5. %lmess25% "[36m%lmess26%[m" %lmess27%
			set /a line_count+=1
			echo.
			set /a line_count+=1
			echo.[!line_count!H[5G%lmess11%:
			set /a line_count+=1
			echo.[!line_count!H[5Ghttps://github.com/bol-van/zapret-win-bundle#arm64-подготовка
			set /a line_count+=1
			echo.
			<nul set /p =[5G
			choice /N /C:%lmess507%%lmess508% /D %lmess507:~0,1% /T 300 /M "%lmess19% (%lmess508:~0,1%|%lmess507:~0,1%): "
			if !errorlevel! neq 255 if !errorlevel! neq 0 if !errorlevel! gtr %lmess507_size% set /a line_count+=15 &goto:@L417
			set /a line_count+=2
		) else (
			set "winwsdir=!winwsdir!\..\windows-arm64"
			set "arch=windows-arm64"
			set "archd=64"
		)
	)
)
goto:@F
:@L394
chcp %lmess1% >nul
set /a line_count+=2
if defined zapret_win_bundle_master if exist %zapret_win_bundle_master%\win7\WinDivert64.sys (
	echo.
	md !winwsdir!\..\windows-7-amd64 1>nul 2>&1
	copy /Y !winwsdir!\*.* !winwsdir!\..\windows-7-amd64\*.* 1>nul 2>&1
	copy /Y %zapret_win_bundle_master%\win7\WinDivert64.sys !winwsdir!\..\windows-7-amd64 1>nul 2>&1
	copy /Y %zapret_win_bundle_master%\win7\WinDivert.dll !winwsdir!\..\windows-7-amd64 1>nul 2>&1
	copy /Y %zapret_win_bundle_master%\win7\WinDivert64.sys %zapret_win_bundle_master%\blockcheck\zapret\nfq 1>nul 2>&1
	copy /Y %zapret_win_bundle_master%\win7\WinDivert.dll %zapret_win_bundle_master%\blockcheck\zapret\nfq 1>nul 2>&1
) else (
	set /a line_count+=1
	echo.[!line_count!H[5G[31m%lmess20%.[m %lmess21%
	set /a line_count+=1
	echo.[!line_count!H[5G'[33mWinDivert64.sys[m'
	set /a line_count+=1
	echo.[!line_count!H[5G'[33mWinDivert.dll[m'
	set /a line_count+=1
	echo.[!line_count!H[5G%lmess22% '[33m%homenc%\bin\[m'
	set /a line_count+=1
	echo.[!line_count!H[5Ghttps://github.com/bol-van/zapret-win-bundle
	set /a line_count+=1
	echo.
	set /a line_count+=1
	echo.[!line_count!H[5G%lmess23%
	pause >nul
)
goto:@F
:@L417
chcp %lmess1% >nul
set /a line_count+=2
if defined zapret_win_bundle_master if exist %zapret_win_bundle_master%\arm64\WinDivert64.sys (
	echo.
	set foo=0
	bcdedit /set TESTSIGNING ON 1>nul 2>&1
	if !errorlevel! equ 0 set foo=1
	md !winwsdir!\..\windows-arm64 1>nul 2>&1
	copy /Y !winwsdir!\*.* !winwsdir!\..\windows-arm64\*.* 1>nul 2>&1
	copy /Y %zapret_win_bundle_master%\arm64\WinDivert64.sys !winwsdir!\..\windows-arm64 1>nul 2>&1
	copy /Y %zapret_win_bundle_master%\arm64\WinDivert64.sys %zapret_win_bundle_master%\blockcheck\zapret\nfq 1>nul 2>&1
	copy /Y %zapret_win_bundle_master%\arm64\ip2net.exe %zapret_win_bundle_master%\blockcheck\zapret\ip2net 1>nul 2>&1
	copy /Y %zapret_win_bundle_master%\arm64\mdig.exe %zapret_win_bundle_master%\blockcheck\zapret\mdig 1>nul 2>&1
	if !foo! equ 1 shutdown /r /t 60 /f 1>nul 2>&1
	if !foo! equ 0 (
		set /a line_count+=1
		echo.[!line_count!H[5G[31m%lmess28% '[36mtestsigning[m'
		set /a line_count+=1
		echo.[!line_count!H[5G%lmess29% '[36mtestsigning[m' %lmess30%
		set /a line_count+=1
		echo.[!line_count!H[5G%lmess25% "[36m%lmess26%[m" %lmess27%
	)
) else (
	set /a line_count+=1
	echo.[!line_count!H[5G[31m%lmess20%.[m %lmess21%: '[33mWinDivert64.sys[m'
	set /a line_count+=1
	echo.[!line_count!H[5G%lmess22% '[33m%homenc%\bin\[m'
	set /a line_count+=1
	echo.[!line_count!H[5Ghttps://github.com/bol-van/zapret-win-bundle
	set /a line_count+=1
	echo.
	set /a line_count+=1
	echo.[!line_count!H[5G%lmess23%
	pause >nul
)
:@F
netsh interface tcp set global timestamps=enabled 1>nul 2>&1
set "strategy_run="
if defined winwsdir (
	if not exist !winwsdir!\winws.exe (
		set "winwsdir="
	) else (
		for /f "delims=" %%I in ('!winwsdir!\winws.exe --version') do (
			set "title_ver=WinWS: %%I"
		)
	)
)
if not defined title_ver goto:@F
set foo=0
for /l %%a in (1,1,32) do (
	if "x!title_ver:~%%a,6!"=="xgithub" set foo=1
)
if %foo% equ 0 (
	set "winwsdir=" 
	set "title_ver="
)
:@F
if "x%arg_1%"=="xstart" (
	if not defined winwsdir exit
	if not defined title_ver exit
	if "x%arg_2%"=="x" (set "strategy_name=%agent_start_strategy%") else (set "strategy_name=%arg_2%")
	for %%i in ("%home%\strategy\!strategy_name!") do set "foo=%%~sni"
	set "strategy_apath=%home%\strategy\!foo!"
	call:@check_name_strategy strategy_apath
	if !errorlevel! equ 1 exit
	goto:@terminate
)
if "x%arg_1%"=="xstop" goto:@terminate
set /a goo=0
for /F "usebackq tokens=1* delims=:" %%a in (`"findstr /n ^^ %home%\run.cmd"`) do (
	if !goo! equ 0 (
		set "foo=%%b"
		if "x!foo:~7,7!"=="xupdated" (
			set "vruncmd=[v.1.!foo:~19,2!.!foo:~21,4!] " 
			set /a goo=1
		)
	)
)
set "_title_=Bypassing Censorship %vruncmd%[Multilanguage] %title_ver%"
set "_title_=%_title_:(=[%"
set "_title_=%_title_:)=]%"
if "x%check_update%"=="xon" (
	set /a line_count+=1
	<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%lmess31%[m[E
	call:check_update
	set "foo=%lmess32%"
	set /a goo=255
	for /L %%c in (255,-1,0) do if "x!foo:~%%c,1!"=="x" set /a goo-=1
	set /a goo=64-!goo!
	for /L %%c in (1,1,!goo!) do set "foo=!foo! "
	set "foo=!foo!https://github.com/alexvruden/my/releases"
	if "x%show_popup%"=="xon" if "x%new_version_available%"=="xtrue" %_pwsh% -Command "[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$objNotifyIcon=New-Object System.Windows.Forms.NotifyIcon;$objNotifyIcon.BalloonTipText='!foo!';$objNotifyIcon.Icon=[system.drawing.systemicons]::Information;$objNotifyIcon.BalloonTipTitle='Bypassing Censorship';$objNotifyIcon.BalloonTipIcon='None';$objNotifyIcon.Visible=$True;$objNotifyIcon.ShowBalloonTip(5000);" 
)
set /a line_count+=1
<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%lmess33%[m[E
cd /d %home%\strategy
for /f "delims=" %%i in ('2^>nul dir /b *.zip') do (
	if not exist %%~ni (
		tar -h 1>nul 2>&1 &&(tar -xf "%%~i" 1>nul 2>&1)||(%_pwsh% -command "Expand-Archive -Path '%%~i' -DestinationPath '.' -Force" 1>nul 2>&1)
	)
)
set /a line_count+=1
<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%lmess34%[m[E

for /f "tokens=1-4* delims= " %%a in ('2^>nul netsh interface ip show interfaces ^|find " connected" ^|find /v "Loopback"') do (
	set /a foo+=1
	set /a netsh_interface_index!foo!=%%~a
	set "netsh_interface_name!foo!=%%~e"
)
chcp %lmess1% >nul
set "_dnsclient="
netsh dnsclient >nul 2>&1 &&(set "_dnsclient=dnsclient")||(netsh dns >nul 2>&1 &&(set "_dnsclient=dns"))
if not defined _dnsclient goto:@F
for /L %%x in (1,1,%foo%) do (
	set /a line_count+=1
	<nul set /p =[!line_count!H[2K[!line_count!H[8G[2m!netsh_interface_name%%x!: 
	set "dnsserver1="
	set "dnsserver2="
	set /a goo=0
	for /f "delims=" %%a in ('2^>nul netsh interface ip show dnsservers "!netsh_interface_name%%x!" ^|find "."') do (
		set /a goo+=1
		set sa!goo!=%%a
	)
	for /L %%c in (1,1,!goo!) do (
		if defined sa%%c set sa%%c=!sa%%c: =!
		if %%c equ 1 (
			for /f "tokens=2 delims=:" %%a in ("!sa%%c!") do set dnsserver%%c=%%a
		) else (
			set dnsserver%%c=!sa%%c!
		)
	)
	if defined dnsserver1 netsh %_dnsclient% show encryption |find "!dnsserver1!" 1>nul 2>&1 ||(netsh interface ip delete dnsservers name="!netsh_interface_name%%x!" address=!dnsserver1! 1>nul 2>&1)
	if not defined dnsserver1 set "dnsserver1=1.1.1.1"
	netsh %_dnsclient% show encryption |find "!dnsserver1!" 1>nul 2>&1 ||(
		netsh %_dnsclient% show encryption |find "1.1.1.1" 1>nul 2>&1 ||(netsh %_dnsclient% add encryption server=1.1.1.1 dohtemplate=https://cloudflare-dns.com/dns-query 1>nul 2>&1)
		set "dnsserver1=1.1.1.1"
	)
	netsh %_dnsclient% set dnsservers name="!netsh_interface_name%%x!" source=static address=!dnsserver1! register=both 1>nul 2>&1
	rem netsh interface ipv6 set dnsservers name="!netsh_interface_name%%x!" source=static address=2606:4700:4700::1111 register=primary 1>nul 2>&1
	<nul set /p =!dnsserver1!
	if defined dnsserver2 netsh %_dnsclient% show encryption |find "!dnsserver2!" 1>nul 2>&1 ||(netsh interface ip delete dnsservers name="!netsh_interface_name%%x!" address=!dnsserver2! 1>nul 2>&1)
	if not defined dnsserver2 set "dnsserver2=1.0.0.1"
	netsh %_dnsclient% show encryption |find "!dnsserver2!" 1>nul 2>&1 ||(
		netsh %_dnsclient% show encryption |find "1.0.0.1" 1>nul 2>&1 ||(netsh %_dnsclient% add encryption server=1.0.0.1 dohtemplate=https://cloudflare-dns.com/dns-query 1>nul 2>&1)
		set "dnsserver2=1.0.0.1"
	)
	netsh interface ip add dnsservers name="!netsh_interface_name%%x!" address=!dnsserver2! index=2 1>nul 2>&1
	rem netsh interface ipv6 add dnsservers name="!netsh_interface_name%%x!" address=2606:4700:4700::1001 index=2 1>nul 2>&1
	<nul set /p =, !dnsserver2![m[E
)
netsh %_dnsclient% set global doh=yes 1>nul 2>&1
set foo=N/A
set goo=33
for /f "tokens=2 delims=:" %%a in ('2^>nul netsh %_dnsclient% show global') do set foo=%%a
echo.%foo% | find "enabled" 1>nul 2>&1 &&(set goo=32)
echo.%foo% | find "disanabled" 1>nul 2>&1 &&(set goo=31)
set /a line_count+=1
<nul set /p =[%line_count%H[2K[%line_count%H[8G[2mDNS over HTTPS: [%goo%m%foo%[m[E
ipconfig /flushdns 1>nul 2>&1
:@F
cd /d %home%
set /a line_count+=1
<nul set /p =[%line_count%H[2K[%line_count%H[5G[2m%lmess42%[m[E
timeout /T 2 /NOBREAK >nul
schtasks /Query /TN dpiagent 1>nul 2>&1 ||goto:@F
schtasks /Query /TN dpiagent /FO CSV /V | find "%home%\script\run_agent.cmd" 1>nul 2>&1 ||(
	schtasks /End /TN dpiagent 1>nul 2>&1
	schtasks /Delete /TN dpiagent /F 1>nul 2>&1 &&(
		if exist %home%\script\run_agent.cmd (
			schtasks /Create /F /TN dpiagent /NP /RU "SYSTEM" /SC ONSTART /TR "%home%\script\run_agent.cmd %home%" 1>nul 2>&1 &&(if defined winwsdir schtasks /Run /TN dpiagent 1>nul 2>&1)
		)
	)
)
:@F
if defined zapret_win_bundle_master if exist %zapret_win_bundle_master%\windivert-hide\Monkey64.sys if defined winwsdir if not "x%PROCESSOR_ARCHITECTURE%"=="xARM64" if not defined win_ver7 if %archd% equ 64 (
	if not exist %winwsdir%\Monkey64.sys copy /Y %zapret_win_bundle_master%\windivert-hide\Monkey64.sys %winwsdir%\Monkey64.sys 1>nul 2>&1
	if not exist %winwsdir%\WinDivert.dll.hide (
		if not exist %winwsdir%\WinDivert.dll.original (
			copy /Y %zapret_win_bundle_master%\windivert-hide\WinDivert.dll %winwsdir%\WinDivert.dll.hide 1>nul 2>&1
		)
	)
)
if not defined title_ver goto:@F
if not defined new_updated_winws goto:@F
echo.%title_ver% | find "%new_updated_winws%" 1>nul 2>&1 ||(set "str_updated_winws=[5G[92m%lmess43%[m [[33m%new_updated_winws%[m]: https://github.com/bol-van/zapret/releases")
:@F
mode con: cols=%mode_con_cols% lines=%mode_con_lines% 1>nul 2>&1
%_pwsh% -command "&{$H=Get-Host;$W=$H.UI.RawUI;$B=$W.BufferSize;$B.Width=%mode_con_cols%;$B.Height=9999;$W.BufferSize=$B;}" 1>nul 2>&1
if not defined eula call:eula_ &&(set eula=accepted)||(goto:menu_0)
:menu
chcp %lmess1%>nul
echo.]0;%_title_%\
echo.[7l[?12l[?25l
cls
set /a c1=5, c2=9, c3=13, c4=30, c5=55, c6=80, c7=100, c8=%mode_con_cols% - 10
echo.[5G[2m%lmess44%[m
if %dnsfound% equ 0 if defined w_dns_str <nul set /p =%w_dns_str%[m
set /a srv_menu_count=1000, strategy_menu_count=1000, parameter_menu_count=1000, agent_work=1000, terminate_count=1000, blockcheck_menu_count=1000, find_strategy_menu_count=1000, menu_choice=1000
if not exist %winwsdir%\winws.exe (
	echo.[5G[31m%lmess45% '[33m%homenc%\bin\[31m'[m
)
<nul set /p =[2m%win_ver%[m
if "x%check_update%"=="xon" if "x%new_version_available%"=="xtrue" (
	<nul set /p =[5G[92m%lmess32%[m: https://github.com/alexvruden/my/releases[E
	if defined new_updated_changelog (
		set new_updated_changelog=%new_updated_changelog:\r\n=[E[21G%
		<nul set /p =[5G%lmess46%:[20G[33m!new_updated_changelog![m[E
	)
)
if defined str_updated_winws <nul set /p =%str_updated_winws%[E
if not exist %home%\script\agent.log goto:@F
chcp 65001 >nul
for /f "delims=" %%i in (%home%\script\agent.log) do set "foo=%%i"
chcp %lmess1% >nul
echo.%foo% | find "%lmess1007%" 1>nul 2>&1 &&(<nul set /p =[5G[31m%lmess48%[m[E)
:@F
<nul set /p =[5G[2m%lmess47%[m
set "winws_pid="
set /a found_winws=0
for /f "tokens=1,2 delims=," %%a in ('2^>nul tasklist /fi "imagename eq winws*" /fo csv /nh') do (
	if "x%%~a"=="xwinws.exe" (
		set /a found_winws+=1
		set "winws_pid!found_winws!=%%~b"
		<nul set /p =[2m.[m
	)
)
if %found_winws% gtr 0 if %profile_count% gtr 0 if %profile_count% equ %found_winws% (
	set /a foo=0
	for /l %%a in (1,1,%profile_count%) do (
		for /l %%b in (1,1,%found_winws%) do (
			if !winws_pid%%b! equ !pid%%a! set /a foo+=1
		)
	)
	if !foo! equ %found_winws% goto:@F
)
set "foo="
set "strategy_run="
set /a profile_count=0
set "commandline="
set "daemon_status="
if %found_winws% gtr 0 ( 
	for /l %%m in (1,1,%found_winws%) do (
		for /f "tokens=* delims=" %%a in ('2^>nul %_pwsh% -Command "Get-WmiObject win32_process -Filter 'ProcessId ^= !winws_pid%%m!' | select commandline | Format-List -Property *"') do (
			set "rtg=%%a"
			set "rtg=!rtg:~14!"
			set "commandline=!commandline!!rtg!"
			<nul set /p =[2m.[m
		)
		set "commandline%%m=!commandline!"
		set "commandline="
	)
	for /l %%m in (1,1,%found_winws%) do (
		for /f "tokens=2-7 delims=[]" %%a in ("!commandline%%m!") do (
			set /a profile_count+=1
			set "n!profile_count!=%%~a"
			set "custom_str=%%~b"
			set "ip!profile_count!=%%~c"
			set "pr!profile_count!=%%~d"
			set "pid!profile_count!=!winws_pid%%m!"
			set "daemon_status=%%~e"
			set "mask_divert_pr=%%~f"
			<nul set /p =[2m.[m
		)
	)
	
)
:@F
echo.
echo.[1F[2K
REM set tt=(0x(B
set /a about_profile_strsize=%c8%-%c4%
set /a check_restart_str=0
if exist %winwsdir%\WinDivert.dll.original (set "mask_divert=on") else (set "mask_divert=off")
if %profile_count% gtr 0 ( 
	for /l %%i in (1,1,%profile_count%) do (
		if %%i equ 1 (
			<nul set /p =(0
			for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xGq
			<nul set /p =(B
			echo.
			if not "x%daemon_status%"=="x%daemon%" set /a check_restart_str+=1
			if not "x%custom_str%"=="x%custom_strategy%" set /a check_restart_str+=1
			if not "x%ip1%"=="x%IPsetStatus%" set /a check_restart_str+=1
			if not "x%mask_divert_pr%"=="x%mask_divert%" set /a check_restart_str+=1
			if !check_restart_str! neq 0 (
				echo.
				echo.[%c1%G[31m%lmess49% [%c4%G%lmess50%[m
				echo.
			)
			echo.[%c1%G%lmess51%:[%c4%G[m!n%%i!
			echo.
			if "x!daemon_status!"=="xon" ( set "offon=%lmess52%" ) else ( set "offon=%lmess53%" )
			echo.[%c4%G[33m%lmess54%[m: !offon!
			if "x!custom_str!"=="xon" ( set "offon=%lmess52%" ) else ( set "offon=%lmess53%" )
			echo.[%c4%G[33m%lmess55%[m: !offon!
			if "x!ip%%i!"=="xon" ( set "offon=%lmess52%" ) else ( set "offon=%lmess53%" )
			echo.[%c4%G[33m%lmess56%[m: !offon!
			if "x!mask_divert_pr!"=="xon" ( set "offon=%lmess52%" ) else ( set "offon=%lmess53%" )
			set /a foo=0
			if exist %winwsdir%\WinDivert.dll.original set /a foo=1
			if exist %winwsdir%\WinDivert.dll.hide set /a foo=1
			if !foo! equ 1 echo.[%c4%G[33m%lmess57%[m: !offon!
			set /a foo=%c4%
			set /a foo=!foo! - 1
			<nul set /p =(0
			for /l %%x in (1,1,!foo!) do <nul set /p =[%%xG[8mq
			<nul set /p =[m
			for /l %%x in (%c4%,1,%c8%) do <nul set /p =[%%xGq
			<nul set /p =(B
			echo.
		)
		set "about_profile=!pr%%i!"
		echo.[%c1%GPID: !pid%%i![%c4%G[36m!about_profile:~0,%about_profile_strsize%![m
	)
	<nul set /p =(0
	for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xGq
	<nul set /p =(B
	echo.
	set "strategy_run=!n1!" 
) else (
	if %found_winws% gtr 0 (
		echo.[%c1%G[31m%lmess58%[m
		<nul set /p =(0
		for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xGq
		<nul set /p =(B
		echo.
	)
)
set /a menu_count=1
set /a find_strategy_menu_count=!menu_count!
set "foo="
if defined count_strategy set "foo=[[32m%lmess59%[m]"
echo.[%c1%G[m!menu_count!.[%c2%G%lmess60%[m %foo%
if defined zapret_win_bundle_master if exist %zapret_win_bundle_master%\blockcheck\zapret\blockcheck.sh (
	set /a menu_count+=1
	set /a blockcheck_menu_count=!menu_count!
	echo.[%c1%G[m!menu_count!.[%c2%GBlockcheck[m
)
if defined lmess61_conv goto:@F
set /a foo=0
for /l %%c in (0,1,255) do (
	if !foo! equ 0 if "x!lmess61:~%%c,1!"=="x'" (
		set /a goo=%%c+1
		set /a foo+=1
	)
)
set moo=!lmess61:~0,%goo%!
set hoo=!lmess61:~%goo%!
set moo=%moo:'=[93m%
set hoo=%hoo:'=[33m%
set lmess61_conv=%moo%%hoo%
:@F
set /a foo=%c1%-1
set "a1="
if %param_trigger% equ 0 ( set "a1=[..]" ) else ( echo. )
echo.[%foo%G[33m%a1%[%c2%G[33m%lmess61_conv%[m
if %param_trigger% neq 0 (
	echo.
	if "x%daemon%"=="xon" (set "offon=[32m%lmess52%[m") else (set "offon=[31m%lmess53%[m")
	set /a menu_count+=1
	set /a parameter_menu_count=!menu_count!
	echo.[%c1%G[m!menu_count!.[%c2%G%lmess54% [%c5%G!offon!
	set /a menu_count+=1
	if "x%custom_strategy%"=="xon" (set "offon=[32m%lmess52%[m") else (set "offon=[31m%lmess53%[m")
	echo.[%c1%G[m!menu_count!.[%c2%G%lmess55% [%c5%G!offon!
	if "x%IPsetStatus%"=="xon" (set "offon=[32m%lmess52%[m") else (set "offon=[31m%lmess53%[m")
	set /a menu_count+=1
	echo.[%c1%G[m!menu_count!.[%c2%G%lmess56% [%c5%G!offon!
	if exist %winwsdir%\Monkey64.sys if defined winwsdir if not "x%PROCESSOR_ARCHITECTURE%"=="xARM64" if not defined win_ver7 if %archd% equ 64 (
		set /a foo=0
		if exist %winwsdir%\WinDivert.dll.original set /a foo=1
		if exist %winwsdir%\WinDivert.dll.hide set /a foo=1
		if !foo! equ 1 (
			set /a menu_count+=1
			if exist %winwsdir%\WinDivert.dll.original (
				set "mask_divert=on"
				set "offon=[32m%lmess52%[m" 
			) else ( 
				set "mask_divert=off"
				set "offon=[31m%lmess53%[m" 
			)
			echo.[%c1%G[m!menu_count!.[%c2%G%lmess57% [%c5%G!offon!
		)
	)
	echo.
)
if defined lmess62_conv goto:@F
set /a foo=0
for /l %%c in (0,1,255) do (
	if !foo! equ 0 if "x!lmess62:~%%c,1!"=="x'" (
		set /a goo=%%c+1
		set /a foo+=1
	)
)
set moo=!lmess62:~0,%goo%!
set hoo=!lmess62:~%goo%!
set moo=%moo:'=[93m%
set hoo=%hoo:'=[33m%
set lmess62_conv=%moo%%hoo%
:@F
set /a foo=%c1%-1
set /a about_strategy_strsize=%c8%-%c5%
if %strategy_trigger% equ 0 (
	echo.[%foo%G[33m[..][%c2%G%lmess62_conv%[m
) else ( 
	echo.[%c2%G%lmess62_conv%[%c5%G%lmess63%[m
	echo.
	set "strategy_count_name="
	set "strategy_name_spath="
	set /a foo=0
	for /f "delims=" %%I in ('2^>nul dir /b /a:d %home%\strategy\') do (
		set /a fexist=0
		set "sfoo="
		for %%m in ("%home%\strategy\%%~I") do set "sfoo=%%~sm"
		call:@check_name_strategy sfoo
		if !errorlevel! equ 1 set "sfoo="
		if not "x!sfoo!"=="x" (
			for /f "delims=" %%a in ('2^>nul dir /x /b "!sfoo!\*.strategy"') do set /a fexist=1
			if !fexist! neq 0 (
				set "hoo=!sfoo!\about"
				if not exist !sfoo!\about call:@save_about_strategy hoo
				if not exist !sfoo!\custom md !sfoo!\custom 1>nul 2>&1
				if not exist !sfoo!\skip md !sfoo!\skip 1>nul 2>&1
				set /p about_strategy=<!sfoo!\about
				call:@replace_meta about_strategy
				set xfoo=!sfoo!\about
				call:co_is_utf8 about_strategy xfoo
				set /a menu_count+=1
				if !strategy_menu_count! equ 1000 set /a strategy_menu_count=!menu_count!
				if "x!strategy_run!"=="x%%~I" (
					set /a c0=%c1% - 2
					echo.[!c0!G[32m^>[%c1%G[m!menu_count!.[%c2%G[32m%%~I [%c5%G[36m!about_strategy:~0,%about_strategy_strsize%![m
				) else ( 	
					echo.[%c1%G[m!menu_count!.[%c2%G%%~I [%c5%G[36m!about_strategy:~0,%about_strategy_strsize%![m
				) 
				set "strategy_count_name!menu_count!=%%~I"
				set "strategy_name_spath!menu_count!=!sfoo!"
				set /a foo=1
			)
		)
		if !strategy_menu_count! neq 1000 (
			set /a fooc=!menu_count!-!strategy_menu_count!
			if !fooc! geq 50 goto:@F
		)
	)
	if !foo! equ 0 ( 
		echo.[%c2%G[31m%lmess65%[m
		echo.[%c2%G%lmess66% '[33m%homenc%\strategy\[m'
	) 
	echo.
)
:@F

set /a task=100
schtasks /Query /TN dpiagent 1>nul 2>&1
if %errorlevel% EQU 0 set /a task=0
if defined lmess67_conv goto:@F
set /a foo=0
for /l %%c in (0,1,255) do (
	if !foo! equ 0 if "x!lmess67:~%%c,1!"=="x'" (
		set /a goo=%%c+1
		set /a foo+=1
	)
)
set moo=!lmess67:~0,%goo%!
set hoo=!lmess67:~%goo%!
set moo=%moo:'=[93m%
set hoo=%hoo:'=[33m%
set lmess67_conv=%moo%%hoo%
:@F
set /a foo=%c1%-1
set "a1="
if %srv_trigger% equ 0 set "a1=[..]"
echo.[%foo%G[33m%a1%[%c2%G%lmess67_conv%[m
if %srv_trigger% neq 0 ( 
	set /a srv_menu_count=%menu_count%+1
	if %task% equ 0 (
		2>nul %_pwsh% -Command "Get-WmiObject win32_process -Filter 'name = \"cmd.exe\"' | select commandline" |find "run_agent.cmd" 1>nul 2>&1
		if !errorlevel! equ 0 (
			call:@last_agent_message foo
			echo.[%c3%G%lmess68%: [32m%lmess70%[m
			echo.[%c3%G%lmess69%: [33m!foo![m
			set /a agent_work=1
		) else (
			echo.[%c3%G%lmess68%: [31m%lmess71%[m
			set /a agent_work=0
		)
		if !agent_work! equ 1 (
			if exist %home%\script\agent.log (
				set /a menu_count+=1
				echo.[%c2%G!menu_count!.[%c3%G%lmess72%[m
			)
			if not "x!agent_mode!"=="xstart" (
				set /a menu_count+=1
				echo.[%c2%G[m!menu_count!.[%c3%G%lmess73% '[32mstart[m'
			)
			if not "x!agent_mode!"=="xstop" (
				set /a menu_count+=1
				echo.[%c2%G[m!menu_count!.[%c3%G%lmess73% '[31mstop[m'
			)
			set /a menu_count+=1
			echo.[%c2%G[m!menu_count!.[%c3%G[33m%lmess74%[m
		) else (
			set /a menu_count+=1
			echo.[%c2%G[m!menu_count!.[%c3%G[33m%lmess75%[m
		)
		set /a menu_count+=1
		echo.[%c2%G[m!menu_count!.[%c3%G[31m%lmess76%[m
	) else (
		echo.[%c2%G[36m[[m %lmess77%: [31m%lmess78%[%c8%G[36m][m
		if defined strategy_run (
			set /a menu_count+=1
			echo.[%c2%G[m!menu_count!.[%c3%G[32m%lmess79%[m
		) else (
			echo.[%c2%G[33m%lmess80%[m
		)
	)
	echo.
)
if defined lmess81_conv goto:@F
set /a foo=0
for /l %%c in (0,1,255) do (
	if !foo! equ 0 if "x!lmess81:~%%c,1!"=="x'" (
		set /a goo=%%c+1
		set /a foo+=1
	)
)
set moo=!lmess81:~0,%goo%!
set hoo=!lmess81:~%goo%!
set moo=%moo:'=[93m%
set hoo=%hoo:'=[33m%
set lmess81_conv=%moo%%hoo%
:@F
set /a about_kill_strsize=%c8%-%c3%
if defined strategy_run (
	set /a menu_count+=1
	set /a terminate_count=!menu_count!
	echo.[%c1%G[m!menu_count!.[%c2%G[33m%lmess81_conv% '[m!strategy_run![33m'[m
	if %term_trigger% neq 0 ( 
		echo.[%c2%G[33m%lmess82%:
		for /l %%i in (1,1,%profile_count%) do (
			set /a menu_count+=1
			set "about_profile_kill=!pr%%i!"
			echo.[%c2%G[m!menu_count!.[36m[%c3%G !about_profile_kill:~0,%about_kill_strsize%! [m
		)
	)
)
echo.
echo.[%c1%G0.[%c2%G%lmess83%
<nul set /p =(0
for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xGq
<nul set /p =(B
echo.
echo.[?25l
:@choice_gtr_menu_count
set "str1choice=0123456789r%lmess501%%lmess502%%lmess503%%lmess500%%lmess504%%lmess505%"
set /a first_digit=1000
<nul set /p =[%c1%G
choice /N /C:%str1choice% /D r /T 60 /M "#:"
if %errorlevel% equ 255 (call:cerror show_line_num1 &goto:menu)
if %errorlevel% equ 0 (call:cerror show_line_num2 &goto:menu)
if %errorlevel% equ 11 goto:menu
set /a _errorlevel=%errorlevel%
set /a first_digit=%_errorlevel% - 1
set "first_digit_char="
for /l %%i in (0,1,50) do (
	if %first_digit% neq 1000 (
		if "x!str1choice:~%%i,1!"=="x!str1choice:~%first_digit%,1!" (
			set first_digit_char=!str1choice:~%%i,1!
			goto:@F
		)
	)
)
:@F

REM set /a foo=12+%lmess501_size%+%lmess502_size%+%lmess503_size%+%lmess500_size%+%lmess504_size%+%lmess505_size%
REM if %_errorlevel% geq %foo% goto:...
set /a foo=12+%lmess501_size%+%lmess502_size%+%lmess503_size%+%lmess500_size%+%lmess504_size%
if %_errorlevel% geq %foo% goto:@reload_strategy
set /a foo=12+%lmess501_size%+%lmess502_size%+%lmess503_size%+%lmess500_size%
if %_errorlevel% geq %foo% goto:run_info
set /a foo=12+%lmess501_size%+%lmess502_size%+%lmess503_size%
if %_errorlevel% geq %foo% goto:@param_trigger
set /a foo=12+%lmess501_size%+%lmess502_size%
if %_errorlevel% geq %foo% goto:@terminate_trigger
set /a foo=12+%lmess501_size%
if %_errorlevel% geq %foo% goto:@srv_menu_trigger
set /a foo=12
if %_errorlevel% geq %foo% goto:@strategy_trigger
set "str2choice=0123456789z"
set /a second_digit=1000
set "second_digit_char="
echo.[2F[2K
<nul set /p =[%c1%G
choice /N /C:0123456789z /D z /T 3 /M "#: %first_digit_char%"
if %errorlevel% equ 255 (call:cerror show_line_num3 &goto:menu)
if %errorlevel% equ 0 (call:cerror show_line_num4 &goto:menu)
if %errorlevel% equ 11 (
	set /a menu_choice=%first_digit%
) else (
	set /a second_digit=%errorlevel% - 1
	set /a menu_choice=%first_digit% * 10 + !second_digit!
)
for /l %%i in (0,1,50) do (
	if %second_digit% neq 1000 (
		if "x!str2choice:~%%i,1!"=="x!str2choice:~%second_digit%,1!" (
			set second_digit_char=!str2choice:~%%i,1!
			goto:@F
		)
	)
)
:@F
if %menu_choice% gtr %menu_count% (
	<nul set /p =[1F[2K
	goto:@choice_gtr_menu_count
)
<nul set /p =[1F[2K[%c1%G#: %first_digit_char%%second_digit_char%
echo.
echo.
if %menu_choice% equ 0 goto:menu_0
if %find_strategy_menu_count% neq 1000 if %menu_choice% equ %find_strategy_menu_count% goto:find_strategy
if %blockcheck_menu_count% neq 1000 if %menu_choice% equ %blockcheck_menu_count% goto:blockcheck
if %terminate_count% neq 1000 if %menu_choice% geq %terminate_count% goto:@terminate
if %srv_menu_count% neq 1000 if %menu_choice% geq %srv_menu_count% goto:menu_srv
if %strategy_menu_count% neq 1000 if %menu_choice% geq %strategy_menu_count% goto:@strategy_choice
if %parameter_menu_count% neq 1000 if %menu_choice% geq %parameter_menu_count% (
	set /a foo=%menu_choice% - %parameter_menu_count% + 1
	goto:menu_!foo!
)
goto:menu

:@save_about_strategy
call set save_about_strategy=%%%~1%%
chcp 65001 >nul
echo.%lmess64%>%save_about_strategy%
chcp %lmess1%>nul
set "save_about_strategy="
exit /b

:@reload_strategy
echo.
set /a reload_strategy_tamper=1
if defined strategy_apath if defined strategy_name goto:@terminate_all
if not defined strategy_run goto:@F
set "strategy_name=%strategy_run%"
for %%i in ("%home%\strategy\%strategy_name%") do set "foo=%%~sni"
set "strategy_apath=%home%\strategy\!foo!"
goto:@terminate_all
:@F
set /a reload_strategy_tamper=0
goto:menu

:@strategy_choice
if "x!strategy_count_name%menu_choice%!"=="x" goto:menu
set "strategy_name=!strategy_count_name%menu_choice%!"
set "strategy_apath=!strategy_name_spath%menu_choice%!"
if "x%strategy_name%"=="x" (
	echo.strategy_name=none
	echo.[5G%lmess84%
	pause >nul
	goto:menu
)
:@terminate
call:cecho x "%lmess227%"
if not defined strategy_run (
	call:check_kill
	if !errorlevel! equ 2 (
		echo.[5G[31m%lmess20%.[m %lmess226%
		echo.[5G%lmess84%
		pause >nul
		goto:menu
	)
	goto:@terminate_done
)
if "x%arg_1%"=="xstart" goto:@terminate_all
if "x%arg_1%"=="xstop" goto:@terminate_all
if %menu_choice% neq 1000 if %menu_choice% EQU %terminate_count% goto:@terminate_all
if %menu_choice% neq 1000 if %menu_choice% GTR %terminate_count% goto:@terminate_one
:@terminate_all
if not defined strategy_run (
	call:check_kill
	if !errorlevel! equ 2 (
		echo.[5G[31m%lmess20%.[m %lmess226%
		echo.[5G%lmess84%
		pause >nul
		goto:menu
	) else if !errorlevel! equ 0 for /l %%x in (1,1,%profile_count%) do set "!pid%%x!="
	goto:@terminate_done
)
call:cecho x3 "%lmess85%" "'%strategy_run%'"
call:check_kill
if %errorlevel% equ 2 (
	echo.[5G[31m%lmess20%.[m %lmess226%
	echo.[5G%lmess84%
	pause >nul
	goto:menu
)
set "strategy_run="
if "x%arg_1%"=="xstart" goto:@terminate_done
if "x%arg_1%"=="xstop" goto:@terminate_done
if %menu_choice% neq 1000 if %menu_choice% EQU %terminate_count% (
	call:cecho 2 "%lmess89%"
	echo.
	for /l %%x in (5,-1,1) do (
		echo.[F
		<nul set /p =[2K[5G[m%lmess87% [32m%%x[m %lmess88%[?25l
		timeout /T 1 /NOBREAK >nul
	)
	goto:menu
)
if %menu_choice% neq 1000 if %menu_choice% EQU %blockcheck_menu_count% goto:@terminate_done
if %menu_choice% neq 1000 if %menu_choice% LSS %terminate_count% goto:@terminate_done
if defined reload_strategy_tamper if %reload_strategy_tamper% equ 1 goto:@terminate_done
:@terminate_one
set /a cpofile=%menu_choice%-%terminate_count%
call:cecho x3x "%lmess86%" "'%strategy_run%'" "[!pr%cpofile%!]"
taskkill /F /PID !pid%cpofile%! /T 1>nul 2>&1 
tasklist /svc |find "winws" 2>nul |find "!pid%cpofile%!" >nul 2>&1 &&(call:cecho 1 "%lmess20%.")||(set "!pid%cpofile%!=")
call:cecho 2 "%lmess89%"
echo.
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p =[2K[5G[m%lmess87% [32m%%x[m %lmess88%[?25l
	timeout /T 1 /NOBREAK >nul
)
goto:menu
:@terminate_done
set /a reload_strategy_tamper=0
if "x%arg_1%"=="xstart" goto:@skiptxtmess
if "x%arg_1%"=="xstop" exit
if %menu_choice% neq 1000 if %menu_choice% EQU %blockcheck_menu_count% goto:blockcheck
if not defined winwsdir if defined arch (
	for /f "delims=" %%I in ('2^>nul dir /b /s /a:d %home%\bin\%arch%') do set "winwsdir=%%~I"
)
if not exist %winwsdir%\cygwin1.dll (
	echo.
	echo.[5G[m%lmess45% '[33m%homenc%\bin\[m'
	echo.
	echo.[5G%lmess11%:
	echo.[5Ghttps://github.com/bol-van/zapret/releases
	echo.
	echo.[5G%lmess84%
	pause >nul
	goto:menu
)
if not exist %winwsdir%\winws.exe (
	echo.
	echo.[5G[31m%lmess21%: [33m'..\!winwsdir:~%homestrsize%!\winws.exe'[m.
	goto:@F
) 
if not exist %winwsdir%\WinDivert.dll (
	echo.
	echo.[5G[31m%lmess21%: [33m'..\!winwsdir:~%homestrsize%!\WinDivert.dll'[m.
	goto:@F
)
if not exist %winwsdir%\WinDivert%archd%.sys (
	echo.
	echo.[5G[31m%lmess21%: [33m'..\!winwsdir:~%homestrsize%!\WinDivert%archd%.sys'[m.
	goto:@F
)
goto:@skiptxtmess
:@F
echo.
echo.[5G%lmess90%
echo.
echo.[5G[31m%lmess35%[m %lmess91%
echo.[5G[33mWINDIVERT[m - %lmess92%
echo.[5G[33mUPX[m - %lmess93%
echo.
echo.[5G[32m%lmess94%[m
echo.
echo.[5G%lmess95% '[33m%homenc%[m' %lmess96%
echo.
echo.[5G%lmess84%
pause >nul
goto:menu
:@skiptxtmess
set "fakedir=!winwsdir!\..\..\files\fake"
if exist %strategy_apath%\about set /p about_strategy=<%strategy_apath%\about
if not exist %strategy_apath%\log md %strategy_apath%\log >nul
del /F /Q %strategy_apath%\log\* >nul
set "zapret_hosts_user_exclude="
if not exist %home%\lists\exclude md %home%\lists\exclude >nul
if not exist %home%\lists\exclude\exclude-hosts.txt echo.#>%home%\lists\exclude\exclude-hosts.txt
for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\exclude\*.txt %home%\lists\exclude\*.lst %home%\lists\exclude\*.gz') do (
	set "zapret_hosts_user_exclude=!zapret_hosts_user_exclude! --hostlist-exclude=%home%\lists\exclude\%%X"
)
set "daemon_bakup=%daemon%"
set "custom_strategy_bakup=%custom_strategy%"
set "IPsetStatus_bakup=%IPsetStatus%"
if not defined arg_3 goto:@arg_3_default
if "x%arg_3:~0,1%"=="x0" (
	set "daemon=off"
) else (
	if "x%arg_3:~0,1%"=="x1" (set "daemon=on") else (goto:@error_arg3)
)
if "x%arg_3:~1,1%"=="x0" (
	set "custom_strategy=off"
) else (
	if "x%arg_3:~1,1%"=="x1" (set "custom_strategy=on") else (goto:@error_arg3)
)
if "x%arg_3:~2,1%"=="x0" (
	set "IPsetStatus=off"
) else (
	if "x%arg_3:~2,1%"=="x1" (set "IPsetStatus=on") else (goto:@error_arg3)
)
:@arg_3_default
call:cecho x3 "%lmess97%" "%homenc%\strategy\%strategy_name%\log\"
set /a pcount=0
set /a scount=0
set /a pause_on_error=0
call:parse_str "%strategy_apath%" "%homenc%\strategy\%strategy_name%"
if not exist %strategy_apath%\skip md %strategy_apath%\skip >nul
if "x%custom_strategy%"=="xon" (
	if not exist %strategy_apath%\custom md %strategy_apath%\custom >nul
	call:parse_str "%strategy_apath%\custom" "%homenc%\strategy\%strategy_name%\custom"
)
if %pcount% equ 0 goto:@nulpcount
call:cecho -x3 "%lmess98%:" "'%scount%'"
if %pcount% neq 0 call:cecho x3 "%lmess99%" "'%strategy_name%'"
set "name_strategy_file_parse_ok_tmp="
set /a scount=1
set "debug_or_daemon=--debug=1"
if "x%daemon%"=="xon" set debug_or_daemon=--daemon
set /a ecode=0
:@loop_dry_run_strategy
set "wscomment="
set "wsarg=!winws_arg%scount%!"
set "sabout=x"
if exist %strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!"-about.log set /p sabout=<%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-about.log"
set wscomment=--comment [%strategy_name%][%custom_strategy%][%IPsetStatus%][!sabout!][%daemon%]
%winwsdir%\winws.exe --dry-run !debug_or_daemon! !wscomment! !wsarg! 2>%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-dry-run-status-err.log" 1>%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-dry-run-status.log"
if !errorlevel! neq 0 (
	call:cecho -1x3 "%lmess20%." "%lmess100%" "'%homenc%\strategy\%strategy_name%\log\!name_strategy_file_parse_ok%scount%!-dry-run-status-err.log"
	set /a ecode=1
	goto:@strategy_list_end
)
%winwsdir%\winws.exe --wf-save="%strategy_apath%\log\!name_strategy_file_parse_ok%scount%!-save.raw" !wsarg! 2>>%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-wf-save-status-err.log" 1>>%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-wf-save-status.log"
set /a scount+=1
if %scount% leq %pcount% goto:@loop_dry_run_strategy
if %pcount% neq 0 call:cecho x3 "%lmess101%" "'%strategy_name%'"
set /a scount=1
:@loop_run_strategy
set "wscomment="
set "wsarg=!winws_arg%scount%!"
set "sabout=x"
chcp 65001 >nul
if exist %strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!"-about.log set /p sabout=<%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-about.log"
chcp %lmess1% >nul
if exist %winwsdir%\WinDivert.dll.original (
	set "mask_divert=on"
) else set "mask_divert=off"
set wscomment=--comment [%strategy_name%][%custom_strategy%][%IPsetStatus%][%sabout%][%daemon%][%mask_divert%]
if "x%daemon%"=="xon" goto:@loop_run_strategy_daemon_on
chcp 65001 >nul
echo.start "[%sabout%] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] Monkey:[%mask_divert%]" %winwsdir%\winws.exe %debug_or_daemon% %wscomment% %wsarg% >>%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-run-cmd.bat.example"
chcp %lmess1% >nul
start "[%sabout%] Custom:[%custom_strategy%] IPset:[%IPsetStatus%] Monkey:[%mask_divert%]" %winwsdir%\winws.exe %debug_or_daemon% %wscomment% %wsarg%
goto:@loop_run_strategy_message
:@loop_run_strategy_daemon_on
chcp 65001 >nul
echo.%winwsdir%\winws.exe %debug_or_daemon% %wscomment% %wsarg% >>%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-run-cmd.bat.example"
chcp %lmess1% >nul
%winwsdir%\winws.exe %debug_or_daemon% %wscomment% %wsarg% 2>>%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-run-status-err.log" 1>>%strategy_apath%\log\"!name_strategy_file_parse_ok%scount%!-run-status.log"
if %errorlevel% neq 0 (
	call:cecho -1x3 "%lmess20%." "%lmess100%" "'%homenc%\strategy\%strategy_name%\log\!name_strategy_file_parse_ok%scount%!-run-status-err.log"
	set /a ecode=1
	goto:@strategy_list_end
)
set /a foo=0
for /f "delims=" %%a in ('tasklist /svc ^| find "winws"') do set /a foo+=1
if %foo% neq %scount% (
	call:cecho -1x "%lmess20%."
	call:cecho -x "%lmess102%"
	call:cecho -xx "%lmess103%" "'[33m%lmess54% [31m%lmess53%[33m[m'"
	set /a ecode=1
	goto:@strategy_list_end
)
:@loop_run_strategy_message
call:cecho -x6x2 "!name_strategy_for_cecho%scount%! :" "[!sabout!]" "-" "ok"
set /a scount+=1
if %scount% leq %pcount% goto:@loop_run_strategy

:@nulpcount
if %pcount% neq 0 ( 
	call:cecho 2 "%lmess89%" 
	set /a ecode=0
) else (
	call:cecho -1 "%lmess104%" 
	set /a ecode=1
)
:@strategy_list_end
if "x%arg_1%"=="xstart" (
	set "daemon=%daemon_bakup%"
	set "custom_strategy=%custom_strategy_bakup%"
	set "IPsetStatus=%IPsetStatus_bakup%"
	exit %ecode%
)
set "strategy_run_failure="
if %pcount% equ 0 goto:@strategy_list_exit
if %ecode% neq 0 (
	set strategy_run_failure=%strategy_name%
	goto:@strategy_list_exit
)
set /a foo=0
if "x%daemon%"=="xon" set /a foo+=100
if "x%custom_strategy%"=="xon" set /a foo+=10
if "x%IPsetStatus%"=="xon" set /a foo+=1
set agent_start_strategy=%strategy_name%
set /a agent_start_params=%foo%
call:sconfig
:@strategy_list_exit
echo.
if %ecode% equ 0 if %pause_on_error% equ 0 goto:@F
echo.[%c3%G%lmess84%
pause >nul
goto:menu
:@F
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p =[2K[5G[m%lmess87% [32m%%x[m %lmess88%[?25l
	timeout /T 1 /NOBREAK >nul
)
goto:menu

:@error_arg3
set /a ecode=1
echo.[5G[31m%lmess105%: [m'[33m%arg_3%[m']
goto:@strategy_list_end
:@strategy_trigger
if %strategy_trigger% equ 0 ( set /a strategy_trigger=1 ) else ( set /a strategy_trigger=0 )
goto:menu
:@srv_menu_trigger
if %srv_trigger% equ 0 ( set /a srv_trigger=1 ) else ( set /a srv_trigger=0 )
goto:menu
:@terminate_trigger
if %term_trigger% equ 0 ( set /a term_trigger=1 ) else ( set /a term_trigger=0 )
goto:menu
:@param_trigger
if %param_trigger% equ 0 ( set /a param_trigger=1 ) else ( set /a param_trigger=0 )
goto:menu
:menu_0
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p =[5G[m%lmess83% %lmess106% [32m%%x[m %lmess88%
	timeout /T 1 /NOBREAK >nul
)
exit /b %ecode%

:menu_1
set "debug=%debug%"
if "x%daemon%"=="xon" ( 
	set "daemon=off" 
	set "debug=on" 
) else ( 
	set "daemon=on"
	set "debug=off"
)
call:sconfig
goto:menu

:menu_2
set /a foo=0
set "foob="
set "fooe="
if "x%custom_strategy%"=="xon" (set "custom_strategy=off") else (set "custom_strategy=on")
call:sconfig
goto:menu

:menu_3
if "x%IPsetStatus%"=="xon" (set "IPsetStatus=off") else (set "IPsetStatus=on")
call:sconfig
goto:menu

:menu_4
:windivert_hide
REM echo.[5G[[33mi[m][8G https://github.com/bol-van/zapret-win-bundle/tree/master/windivert-hide
if exist %winwsdir%\WinDivert.dll.original (
	move /Y %winwsdir%\WinDivert.dll %winwsdir%\WinDivert.dll.hide 1>nul 2>&1
	move /Y %winwsdir%\WinDivert.dll.original %winwsdir%\WinDivert.dll 1>nul 2>&1
	set "mask_divert=off"
) else (
	move /Y %winwsdir%\WinDivert.dll %winwsdir%\WinDivert.dll.original 1>nul 2>&1
	move /Y %winwsdir%\WinDivert.dll.hide %winwsdir%\WinDivert.dll 1>nul 2>&1
	set "mask_divert=on"
)
goto:menu

:cerror
echo.
set "_cerror=0"
for /F "usebackq tokens=1 delims=:" %%a in (`"findstr /n %~1 %home%\run.cmd"`) do set _cerror=%%a
if x%~2==x- goto:@F
echo.[5G[31m%lmess20%.[m Line #%_cerror%
echo.[5G%lmess23%
pause >nul
:@F
exit /b %_cerror%

:blockcheck
echo.
if not defined pos (
	set /a pos=10
	set /a _pos=!pos!-4
)
call:find_strategy_create_cfg
if not exist %zapret_win_bundle_master%\cygwin\bin\bash.exe (
	echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess20%. [m%lmess21%: '[33mbash.exe[m'
	goto:@F
)
if not exist %zapret_win_bundle_master%\blockcheck\zapret\blockcheck.sh (
	echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess20%. [m%lmess21%: '[33mblockcheck.sh[m'
:@F
	echo.
	echo.[%pos%G[m%lmess22% '[33m%homenc%\bin\[m':
	echo.
	echo.[%pos%Ghttps://github.com/bol-van/zapret-win-bundle/archive/refs/heads/master.zip
	echo.
	echo.[%pos%G%lmess84%
	pause >nul
	goto:menu
)
call:check_kill
if %errorlevel% equ 2 (
	echo.[5G[31m%lmess20%.[m %lmess226%
	echo.[5G%lmess84%
	pause >nul
	goto:menu
)
echo.[%_pos%G[[33mi[m][%pos%G%lmess107% '[33m%homenc%\find-strategy-config.txt[m' %lmess108%
echo.
echo.[%pos%G%lmess109%
pause >nul
(set LF=^
%=EMPTY=%
)
copy /Y %home%\find-strategy-config.txt %zapret_win_bundle_master%\blockcheck\zapret\config 1>nul 2>&1
start %zapret_win_bundle_master%\cygwin\bin\bash -i "%zapret_win_bundle_master%\blockcheck\zapret\blog.sh"
echo.
echo.[%_pos%G[[33mi[m][%pos%G%lmess110% '[33m%homenc%\bin\..\blockcheck\blockcheck.log[m'
(
echo.@echo off
echo.:loop
echo.cls
echo.more /e /p /s %zapret_win_bundle_master%\blockcheck\blockcheck.log
echo.echo.
echo.pause
echo.goto:loop
)>%home%\blockcheck.log.cmd
echo.[%_pos%G[[33mi[m][%pos%G%lmess111% '[33m%homenc%\blockcheck.log.cmd[m'
echo.
echo.[%pos%G%lmess84%
pause >nul
goto:menu

:menu_srv
if not exist %home%\script\run_agent.cmd (
	echo.[5G[31m%lmess21%[m '[33m%homenc%\script\run_agent.cmd[m'
	echo.[5G%lmess84%
	pause >nul
	goto:menu
)
set /a calog=1000, caenable=1000, cadisable=1000, castart=1000, castop=1000, cadel=1000
if %agent_work% equ 1 (
	set /a calog=0
	if not "x%agent_mode%"=="xstart" set /a castart=1
	if not "x%agent_mode%"=="xstop" set /a castop=1
	set /a cadisable=2, cadel=3
)
if %agent_work% equ 0 (
	set /a caenable=0, cadel=1
)
schtasks /Query /TN dpiagent 1>nul 2>&1
if %errorlevel% EQU 0 (
	set /a foo=%menu_choice% - %srv_menu_count%
	if !foo! equ !calog! (
		goto:@show_agent_message
	) else if !foo! equ !castart! (
		set "agent_mode=start"
		echo.[5G[m%lmess113% '[32mstart[m' %lmess114%
		call:sconfig
	) else if !foo! equ !castop! (
		set "agent_mode=stop"
		echo.[5G[m%lmess113% '[31mstop[m' %lmess114%
		call:sconfig
	) else if !foo! equ !caenable! (
		schtasks /Run /TN dpiagent 1>nul 2>&1
		if !errorlevel! EQU 0 (
			echo.[5G[32m%lmess115%[m
		) else echo.[5G[31m%lmess116%[m
	) else if !foo! equ !cadisable! (
		schtasks /End /TN dpiagent 1>nul 2>&1
		if !errorlevel! EQU 0 (
			echo.[5G[32m%lmess117%[m
		) else echo.[5G[31m%lmess118%[m
	) else if !foo! equ !cadel! (
		schtasks /End /TN dpiagent 1>nul 2>&1
		schtasks /Delete /TN dpiagent /F 1>nul 2>&1
		if !errorlevel! EQU 0 (
			if "x%show_popup%"=="xon" (
				%_pwsh% -Command "[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$objNotifyIcon=New-Object System.Windows.Forms.NotifyIcon;$objNotifyIcon.BalloonTipText='%lmess119%';$objNotifyIcon.Icon=[system.drawing.systemicons]::Information;$objNotifyIcon.BalloonTipTitle='Bypassing Censorship';$objNotifyIcon.BalloonTipIcon='None';$objNotifyIcon.Visible=$True;$objNotifyIcon.ShowBalloonTip(5000);"
			) else (
				echo.[5G[32m%lmess119%[m
			)
		) else (
			echo.[5G[31m%lmess120%[m
		)
	)
) else (
	set "agent_mode=start"
	call:sconfig
	if not exist %home%\script\agent.log echo.#>%home%\script\agent.log
	schtasks /Create /F /TN dpiagent /NP /RU "SYSTEM" /SC ONSTART /TR "%home%\script\run_agent.cmd %home%" 1>nul 2>&1
	if !errorlevel! EQU 0 (
		if "x%show_popup%"=="xon" (
			%_pwsh% -Command "[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$objNotifyIcon=New-Object System.Windows.Forms.NotifyIcon;$objNotifyIcon.BalloonTipText='%lmess121%';$objNotifyIcon.Icon=[system.drawing.systemicons]::Information;$objNotifyIcon.BalloonTipTitle='Bypassing Censorship';$objNotifyIcon.BalloonTipIcon='None';$objNotifyIcon.Visible=$True;$objNotifyIcon.ShowBalloonTip(5000);"
			schtasks /Run /TN dpiagent 1>nul 2>&1
		) else (
			echo.
			echo.[5G[32m%lmess121%[m
			schtasks /Run /TN dpiagent 1>nul 2>&1 &&(echo.[5G[32m%lmess115%[m)||(echo.[5G[31m%lmess116%[m)
		)
	) else (
		echo.[5G[31m%lmess122%[m
	)
)
echo.
for /l %%x in (10,-1,1) do (
	echo.[F
	<nul set /p =[2K[5G[m%lmess87% [32m%%x[m %lmess88%[?25l
	timeout /T 1 /NOBREAK >nul
)
goto:menu

:@show_agent_message
cls
echo.
echo.[5G%lmess112% [[33m%homenc%\script\agent.log[m]
<nul set /p =(0
for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xGq
<nul set /p =(B[E
echo.
chcp 65001 >nul
for /f "tokens=1* delims= " %%a in (%home%\script\agent.log) do (
	echo.[5G[33m%%a[m %%b
)
chcp %lmess1% >nul
echo.
<nul set /p =(0
for /l %%x in (%c1%,1,%c8%) do <nul set /p =[%%xGq
<nul set /p =(B
echo.
echo.
echo.[5G%lmess84%
pause >nul
goto:menu

:@last_agent_message
set "last_agent_message="
chcp 65001 >nul
if exist %home%\script\agent.log (
	for /f "tokens=1* delims= " %%a in (%home%\script\agent.log) do set "last_agent_message=%%b"			
)
chcp %lmess1% >nul
if defined last_agent_message set %~1=%last_agent_message%
exit /b

:cecho
set "curtime=%TIME:~0,2%.%TIME:~3,2%.%TIME:~6,2%"
set "curtime=%curtime: =0%"
set bitmask=%~1
set /a cecho_notime=0
for /L %%a in (0,1,9) do (
	if !cecho_notime! equ 0 (set /a bmloc = %%a + 2) else (set /a bmloc = %%a + 1)
	if "x!bitmask:~%%a,1!"=="x-" (
		set /a cecho_notime=1
	) else (
		if not "x!bitmask:~%%a,1!"=="x" set "bm!bmloc!=3!bitmask:~%%a,1!"
		if "x!bitmask:~%%a,1!"=="xx" set "bm!bmloc!=0"
	)
)
if %cecho_notime% equ 0 <nul set /p =[%curtime%]
<nul set /p =[%c3%G
if not "x%~2"=="x" <nul set /p = [%bm2%m%~2
if not "x%~3"=="x" <nul set /p = [%bm3%m %~3
if not "x%~4"=="x" <nul set /p = [%bm4%m %~4
if not "x%~5"=="x" <nul set /p = [%bm5%m %~5
if not "x%~6"=="x" <nul set /p = [%bm6%m %~6
if not "x%~7"=="x" <nul set /p = [%bm7%m %~7
if not "x%~8"=="x" <nul set /p = [%bm8%m %~8
if not "x%~9"=="x" <nul set /p = [%bm9%m %~9
echo.[m
exit /b

:sconfig
(
echo.# Generate from script. Do not edit this config
echo.
echo.eula=%eula%
echo.
echo.language=%language%
echo.show_popup=%show_popup%
echo.
echo.check_update=%check_update%
echo.new_version_available=%new_version_available%
echo.
echo.daemon=%daemon%
echo.custom_strategy=%custom_strategy%
echo.IPsetStatus=%IPsetStatus%
echo.
echo.# params for agent
echo.
echo.ip_router=%ip_router%
echo.agent_mode=%agent_mode%
echo.agent_start_strategy=%agent_start_strategy%
echo.agent_start_params=%agent_start_params%
)>%home%\run.config
exit /b

:check_update
set /a updated=2025090517
set foo=0
set "_curl=curl"
%_curl% -V 1>nul 2>&1 &&(set foo=1)
if %foo% equ 0 (
	set "_curl="
	if exist %home%\curl.exe (
		set "_curl=%home%\curl.exe"
	) else if exist %home%\bin\curl.exe (
		set "_curl=%home%\bin\curl.exe"
	) else if defined bin_curl set "_curl=%bin_curl%"
	if not "x!_curl!"=="x" set foo=1
)
if %foo% equ 0 exit /b 1
for /f "tokens=2 delims=:" %%a in ('2^>nul %_curl% --max-time 2 -sH "Accept: application/vnd.github+json" https://api.github.com/repos/alexvruden/my/releases/latest ^|findstr "updated_at"') do (
	set new_updated=%%a
)
chcp 65001 >nul
for /f "tokens=2 delims=:" %%a in ('2^>nul %_curl% --max-time 2 -sH "Accept: application/vnd.github+json" https://api.github.com/repos/alexvruden/my/releases/latest ^|findstr "body"') do (
	set new_updated_changelog=%%a
)
chcp %lmess1% >nul
for /f "tokens=2 delims=:" %%a in ('2^>nul %_curl% --max-time 2 -sH "Accept: application/vnd.github+json" https://api.github.com/repos/bol-van/zapret/releases/latest ^|findstr "tag_name"') do (
	set new_updated_winws=%%a
)
if defined new_updated_winws (
	set new_updated_winws=%new_updated_winws:"=%
	set new_updated_winws=!new_updated_winws:,=!
	set new_updated_winws=!new_updated_winws: =!
)
if defined new_updated_changelog (
	set new_updated_changelog=%new_updated_changelog:"=%
)
if defined new_updated (
	set new_updated=%new_updated:"=%
	set new_updated=!new_updated:,=!
	set new_updated=!new_updated: =!
	set new_updated=!new_updated:-=!
	set new_updated=!new_updated:T=!
	set new_updated=!new_updated:~0,10!
	if %updated% lss !new_updated! (
		set "new_version_available=true" 
	) else ( 
		set "new_version_available=false" 
	)
)
call:sconfig
exit /b 0

:parse_str
set "parse_str_strategy_apath=%~1"
set "str_file_path_for_cecho=%~2"
for /f "delims=" %%I in ('2^>nul dir /b %parse_str_strategy_apath%\*.strategy') do (
	set parse_str_lcount=1
	set "skip_profile=off"
	set "skip_profile_ipset=off"
	set "skip_WinDivert=off"
	set "profile_param="
	set "tmp_profile_param="
	set "sabout="
	set "psabout="
	set "sWinDivert="
	set /a WinDivert_mayok=0
	for %%a in ("%parse_str_strategy_apath%\%%~I") do set "foo=%%~sa"
	for /F "usebackq tokens=1* delims=:" %%a in (`"findstr /n ^^^^ !foo!"`) do (
		set "fletter="
		set "sletter="
		for /f "tokens=1* delims==" %%M in ("%%b") do (
			set "fletter=%%~M"
			set "sletter=%%~N"
		)
		set parse_str_lcount=%%a
		set "foo=!fletter!"
		if defined fletter set "fletter=!fletter: =!"
		set /a parse_desync = 0
		if "x!fletter:~0,1!"=="x$" (
			if not "x!foo:~1!"=="x" set "psabout=!foo:~1!"
		) else if "x!fletter:~0,1!"=="x#" (
			set "foo="
		) else if "x!fletter:~0,1!"=="x" (
			set "foo="
		) else (
			if "x!fletter!"=="xHOSTLIST" (
				if not exist %home%\lists\hostlist\hostlist-auto.txt (
					call:cecho -xx3 "%%~I [!parse_str_lcount!]:" "%lmess123%" "'%homenc%\lists\hostlist\hostlist-auto.txt'"
					echo.#>%home%\lists\hostlist\hostlist-auto.txt
				)
				for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\hostlist\*.txt %home%\lists\hostlist\*.lst %home%\lists\hostlist\*.gz') do (
					set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%X"
				)
				set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\hostlist-auto.txt"
			) else if "x!fletter!"=="xHOSTLIST_NOAUTO" (
				set /a foo = 0
				for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\hostlist\*.txt %home%\lists\hostlist\*.lst %home%\lists\hostlist\*.gz') do (
					set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%X"
					set /a foo = 1
				)
				if !foo! equ 0 (
					call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess20%." "%lmess21%:" "'%homenc%\lists\hostlist\*'"
					call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
					set "skip_profile=on"
					set /a pause_on_error=1
				)
			) else if "x!fletter!"=="x--hostlist-auto" (
				if "x!sletter!"=="x" (
					if not exist %home%\lists\hostlist\hostlist-auto.txt (
						call:cecho -xx3 "%%~I [!parse_str_lcount!]:" "%lmess123%" "'%homenc%\lists\hostlist\hostlist-auto.txt'"
						echo.#>%home%\lists\hostlist\hostlist-auto.txt
					)
					set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\hostlist-auto.txt"
				) else (
					if not exist %home%\lists\hostlist\!sletter! (
						set "hoo=!sletter!"
						call:@get_file hoo &&(
							if not exist %home%\lists\hostlist\!hoo! echo.#>%home%\lists\hostlist\!hoo!
							set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\!hoo!"
						) || (
							call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess20%." "%lmess21%:" "'%homenc%\lists\hostlist\*'"
							call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
							set "skip_profile=on"
							set /a pause_on_error=1
						)
					) else (
						set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\!sletter!"
					)
				)
			) else if "x!fletter!"=="x--hostlist" (
				if "x!sletter!"=="x" (
					set /a foo = 0
					for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\hostlist\*.txt %home%\lists\hostlist\*.lst %home%\lists\hostlist\*.gz') do (
						set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\%%X"
						set /a foo = 1
					)
					if !foo! equ 0 (
						call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess20%." "%lmess21%:" "'%homenc%\lists\hostlist\*'"
						call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
						set "skip_profile=on"
						set /a pause_on_error=1
					)				
				) else (
					if exist %home%\lists\hostlist\!sletter! (
						set "profile_param=!profile_param! --hostlist=%home%\lists\hostlist\!sletter!"
					) else (
						set "hoo=!sletter!"
						call:@get_file hoo
						if not exist %home%\lists\hostlist\!hoo! (
							call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess20%." "%lmess21%:" "'%homenc%\lists\hostlist\!hoo!'"
							call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
							set "skip_profile=on"
							set /a pause_on_error=1
						) else (
							set "profile_param=!profile_param! --hostlist-auto=%home%\lists\hostlist\!hoo!"
						)
					)
				)
			) else if "x!fletter!"=="xIPSET" (
					if "x%IPsetStatus%"=="xon" (
						set /a foo = 0
						for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\ipset\*.txt %home%\lists\ipset\*.lst %home%\lists\ipset\*.gz') do (
							set "profile_param=!profile_param! --ipset=%home%\lists\ipset\%%~X"
							set /a foo = 1
						)
						if !foo! equ 0 (
							call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess20%." "%lmess21%:" "'%homenc%\lists\ipset\*'"
							call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "IPSET" "%lmess125%"	
							set "skip_profile=on"
							set "skip_profile_ipset=on"
						)				
					) else (
						set "skip_profile=on"
						set "skip_profile_ipset=on"
						call:cecho -x3x3 "%%~I [!parse_str_lcount!]:" "%lmess126%" "WinWS %lmess127%" "'%lmess56%: %lmess53%'"
					)
			) else if "x!fletter!"=="x--ipset" (
				if "x!sletter!"=="x" (
					if "x%IPsetStatus%"=="xon" (
						set /a foo = 0
						for /f "delims=" %%X in ('2^>nul dir /B %home%\lists\ipset\*.txt %home%\lists\ipset\*.lst %home%\lists\ipset\*.gz') do (
							set "profile_param=!profile_param! --ipset=%home%\lists\ipset\%%~X"
							set /a foo = 1
						)
						if !foo! equ 0 (
							call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess20%." "%lmess21%:" "'%homenc%\lists\ipset\*'"
							call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
							set "skip_profile=on"
							set "skip_profile_ipset=on"
						)				
					) else (
						set "skip_profile=on"
						set "skip_profile_ipset=on"
						call:cecho -xx33 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
						call:cecho -x3x3 "%%~I [!parse_str_lcount!]:" "%lmess126%" "WinWS %lmess127% --ipset" "'%lmess56%: %lmess53%'"
					)
				) else (
					if "x%IPsetStatus%"=="xon" (
						if exist %home%\lists\ipset\!sletter! (
							set "profile_param=!profile_param! --ipset=%home%\lists\ipset\!sletter!"
						) else (
							set "hoo=!sletter!"
							call:@get_file hoo
							if not exist %home%\lists\ipset\!hoo! (
								call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess20%." "%lmess21%:" "'%homenc%\lists\ipset\!hoo!'"
								call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
							) else (
								set "profile_param=!profile_param! --ipset=%home%\lists\ipset\!hoo!"
							)
						)
					) else (
						set "skip_profile=on"
						set "skip_profile_ipset=on"
						call:cecho -xx33 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
						call:cecho -x3x3 "%%~I [!parse_str_lcount!]:" x"%lmess126%" "WinWS %lmess127% --ipset" "'%lmess56%: %lmess53%'"
					)
				)
			) else if "x!fletter!"=="x--wf-raw" (
				set "LN=!sletter!"
				if "x!LN:~0,1!"=="x@" (
					if exist %parse_str_strategy_apath%\!LN:~1! (
						set sWinDivert=--wf-raw=@%parse_str_strategy_apath%\!LN:~1!
					) else (
						set "skip_WinDivert=on"
						set /a pause_on_error=1
						call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess20%." "%lmess21%:" "'%homenc%\strategy\%strategy_name%\!LN:~1!'"
						call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"
					)
				) else (
					rem generate raw filter
					set "WinDivert_generate_filter=!LN!"
					set "psabout=!LN!"
					set "strategy_raw_file=%parse_str_strategy_apath%"
					call:generate_raw_file WinDivert_generate_filter strategy_raw_file
					if !errorlevel! equ 0 (
						call:cecho -x23 "%%~I [!parse_str_lcount!]:" "%lmess128%:" "'%homenc%\strategy\%strategy_name%\!strategy_raw_file!'"
						set sWinDivert=--wf-raw=@%parse_str_strategy_apath%\!strategy_raw_file!
					) else (
						set "skip_WinDivert=on"
						set /a pause_on_error=1
						call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"
						call:cecho -x1x "%%~I [!parse_str_lcount!]:" "%lmess126%" "WinDivert %lmess127% --wf-raw"
					)
				)
				if "x!sabout!"=="x" (
					if "x!psabout!"=="x" ( set "sabout=!sWinDivert:~5!" ) else ( set "sabout=!psabout!" )
				) else (
					if "x!psabout!"=="x" ( set "sabout=!sabout! !sWinDivert:~5!" ) else ( set "sabout=!sabout! !psabout!" )
				)
				set "LN="
				set "psabout="
			) else if "x!fletter!"=="x--wf-tcp" (
				if "x!sletter!"=="x" (
					set "skip_WinDivert=on"
					call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
					call:cecho -x1x "%%~I [!parse_str_lcount!]:" "%lmess126%" "WinDivert %lmess127% --wf-tcp"
				) else set sWinDivert=--wf-tcp=!sletter!
				if "x!sabout!"=="x" (
					if "x!psabout!"=="x" ( set "sabout=!sWinDivert:~5!" ) else ( set "sabout=!psabout!" )
				) else (
					if "x!psabout!"=="x" ( set "sabout=!sabout! !sWinDivert:~5!" ) else ( set "sabout=!sabout! !psabout!" )
				)
				set "psabout="
				set /a WinDivert_mayok=1
			) else if "x!fletter!"=="x--wf-udp" (
				if "x!sletter!"=="x" (
					set "skip_WinDivert=on"
					call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
					call:cecho -x1x "%%~I [!parse_str_lcount!]:" "%lmess126%" "WinDivert %lmess127% --wf-udp"
				) else set sWinDivert=--wf-udp=!sletter!
				if "x!sabout!"=="x" (
					if "x!psabout!"=="x" ( set "sabout=!sWinDivert:~5!" ) else ( set "sabout=!psabout!" )
				) else (
					if "x!psabout!"=="x" ( set "sabout=!sabout! !sWinDivert:~5!" ) else ( set "sabout=!sabout! !psabout!" )
				)
				set "psabout="
				set /a WinDivert_mayok=1
			) else if "x!fletter!"=="x--filter-udp" (
				if "x!sletter!"=="x" (
					set "skip_profile=on"
					set /a pause_on_error=1
					call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
					call:cecho -x1x "%%~I [!parse_str_lcount!]:" "%lmess126%" "WinWS %lmess127% --filter-udp"
				) else set "profile_param=!profile_param! --filter-udp=!sletter!"
			) else if "x!fletter!"=="x--filter-tcp" (
				if "x!sletter!"=="x" (
					set "skip_profile=on"
					set /a pause_on_error=1
					call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
					call:cecho -x1x "%%~I [!parse_str_lcount!]:" "%lmess126%" "WinWS %lmess127% --filter-udp"
				) else set "profile_param=!profile_param! --filter-tcp=!sletter!"
			) else if "x!fletter!"=="x--dpi-desync-split-seqovl-pattern" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-split-seqovl-pattern" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fakedsplit-pattern" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-tls" (
				set "foo=!sletter!"
				if defined foo set "foo=!foo: =!"
				if "x!foo!"=="x" (
					set "profile_param=!profile_param! !fletter!=^!"
				) else set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-unknown" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-syndata" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-wireguard" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-dht" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-discord" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-stun" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-udplen-pattern" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-quic" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--dpi-desync-fake-unknown-udp" (
				set /a parse_desync = 1
			) else if "x!fletter!"=="x--new" (
				if "x!skip_profile!"=="xoff" (
					set /a scount+=1
					if "x!tmp_profile_param!"=="x" ( 
						set "tmp_profile_param=!profile_param! %zapret_hosts_user_exclude%" 
					) else ( 
						set "tmp_profile_param=!tmp_profile_param! !profile_param! %zapret_hosts_user_exclude%" 
					)
					set "profile_param=--new"
					if "x!sabout!"=="x" ( 
						if not "x!psabout!"=="x" set "sabout=!psabout!" 
					) else ( 
						if not "x!psabout!"=="x" set "sabout=!sabout! !psabout!" 
					)
				) else (
					if "x%skip_profile_ipset%"=="xon" call:cecho -x3x3 "%%~I [!parse_str_lcount!]:" "%lmess126%" "WinWS %lmess127%" "'%lmess56%: %lmess53%'"
					if "x%skip_profile_ipset%"=="xoff" call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess126%" "WinWS %lmess127%" "'!psabout!'"
					set "profile_param="
					set "skip_profile=off"
					set "skip_profile_ipset=off"
				)
				set "psabout=" 
			) else if "x!sletter!"=="x" (
				set "profile_param=!profile_param! !fletter!"
			) else (
				set "profile_param=!profile_param! !fletter!=!sletter!"
			)
			if !parse_desync! equ 1 (
				set "foo=!sletter!"
				if defined foo set "foo=!foo: =!"
				if "x!foo:~0,2!"=="x0x" (
					set "profile_param=!profile_param! !fletter!=!sletter!"
				) else if "x!foo:~0,4!"=="xHEX:" (
					call:random_hex foo !foo:~4!
					set "profile_param=!profile_param! !fletter!=!foo!"
				) else (
					if exist %fakedir%\!sletter! ( 
						set "profile_param=!profile_param! !fletter!=%fakedir%\!sletter!"
					) else (
						set "hoo=!sletter!"
						call:@get_file hoo
						if not exist %fakedir%\!hoo! (
							call:cecho -x1x3 "%%~I [!parse_str_lcount!]:" "%lmess20%." "%lmess21%:" "'..\!fakedir:~%homestrsize%!\!hoo!'"
							call:cecho -xx31 "%%~I [!parse_str_lcount!]:" "%lmess124%" "!fletter!=!sletter!" "%lmess125%"	
						) else (
							set "profile_param=!profile_param! !fletter!=%fakedir%\!hoo!"
						)
					)
				)
			)
		)
	)
	if not "x!profile_param!"=="x" (
		if "x!skip_WinDivert!"=="xoff" if !WinDivert_mayok! equ 1 (
			if "x!skip_profile!"=="xoff" (
				set /a scount+=1
				if "x!tmp_profile_param!"=="x" ( 
					set "tmp_profile_param=!profile_param! %zapret_hosts_user_exclude%" 
				) else (
					set "tmp_profile_param=!tmp_profile_param! !profile_param! %zapret_hosts_user_exclude%"
				)
				if "x!sabout!"=="x" ( 
					if not "x!psabout!"=="x" set "sabout=!psabout!" 
				) else ( 
					if not "x!psabout!"=="x" set "sabout=!sabout! !psabout!" 
				)
				set "psabout="
			) else (
				set "skip_profile=off"
				set "skip_profile_ipset=off"
			)
			if not "x!tmp_profile_param!"=="x" (
				set /a pcount+=1
				set "name_strategy_file_parse_ok!pcount!=%%~nI"
				set "name_strategy_for_cecho!pcount!=%%~I"
				set "winws_arg!pcount!=!sWinDivert! !tmp_profile_param!"
				if "x!sabout!"=="x" ( 
					set "sabout=no about"
				)
				set "sabout=!sabout:[={!"
				set "sabout=!sabout:]=}!"
				echo.!sabout!>>%strategy_apath%\log\"%%~nI-about.log"
			) else set /a pause_on_error=1
		) else set /a pause_on_error=1
	) else set /a pause_on_error=1
)
exit /b

:progress_in_percent_begin
if defined pinp goto:@F
set /a progress_in_percent_begin_max=%~1
set /a temp_percent_count=0, pinp=0, pinp_count=1
set /a percent_step = %progress_in_percent_begin_max% / 100
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
	goto:@F
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
	goto:@F
)
set /a percent_step=%progress_in_percent_begin_max%
set /a pinp_count=100 / %percent_step%
set /a foo=0
for /L %%c in (0,1,99) do set /a percent_step%%c=%percent_step%
:@F
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

:check_run
set /a ecode=1
set check_run_loop_count=1
:@check_run_loop
tasklist /svc |find "winws" >nul 2>&1 &&(set /a ecode=0 &goto:@F)
for /L %%a in (1,1,10) do ping localhost -n 1 >nul 2>&1
set /a check_run_loop_count+=1
if %check_run_loop_count% leq 100 goto:@check_run_loop
:@F
set "check_run_loop_count="
exit /b %ecode%

:check_kill
set /a ecode=1
set check_kill_foo=1
:@check_kill_loop
tasklist /svc |find "winws" >nul 2>&1 ||(set /a ecode=0 &goto:@F)
taskkill /F /IM winws.exe /T 1>nul 2>&1 ||(set /a ecode=1)
for /L %%a in (1,1,10) do ping localhost -n 1 >nul 2>&1
set /a check_kill_foo+=1
if %check_kill_foo% leq 100 goto:@check_kill_loop
:@F
set check_kill_foo=%~1
if defined check_kill_foo goto:@F 
if exist %winwsdir%\WinDivert.dll.original (
	sc qc monkey 1>nul 2>&1 &&(
		sc stop monkey 1>nul 2>&1
		sc delete monkey 1>nul 2>&1
	)
	sc qc monkey 1>nul 2>&1 &&(set /a ecode=3)
)else (
	sc qc windivert 1>nul 2>&1 &&(
		sc stop windivert 1>nul 2>&1
		sc delete windivert 1>nul 2>&1
	)
	sc qc windivert 1>nul 2>&1 &&(set /a ecode=2)
)
:@F
set "check_kill_foo="
exit /b %ecode%

:find_strategy
cls
echo.
if not exist %home%\strategy\strategy.lst.example (
(
echo.# utf-8
echo.[HTTP]
echo.
echo.[HTTPS]
echo.
echo.[HTTP3]
echo.
echo.[END]
)>%home%\strategy\strategy.lst.example
)
set /a pos=10
set /a _pos=%pos%-5
set /a line_jump_num=2
if not defined winwsdir (
	echo.[%_pos%G[[33mi[m][%pos%G%lmess45% '[33m%homenc%\bin\[m'
	echo.
	echo.[%pos%G %lmess11%:
	echo.[%pos%G https://github.com/bol-van/zapret/releases
	echo.
	goto:@find_strategy_end
)
if not exist %winwsdir%\WinDivert.dll (
	echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess21%[m [33m'..\!winwsdir:~%homestrsize%!\WinDivert.dll'[m.
	goto:@find_strategy_txtmess
)
if not exist %winwsdir%\WinDivert%archd%.sys (
	echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess21%[m [33m'..\!winwsdir:~%homestrsize%!\WinDivert%archd%.sys'[m.
	goto:@find_strategy_txtmess
)
if defined count_strategy (
	call:check_kill
	if !errorlevel! equ 2 (
		echo.[5G[31m%lmess20%.[m %lmess226%
		echo.[5G%lmess84%
		pause >nul
		goto:menu
	)
	set /a line_jump_num+=1
	echo.[!line_jump_num!H[%_pos%G[[33mi[m][%pos%G%lmess129% '[33m%count_strategy%[m', %lmess130%
	set /a line_begin=%line_begin_mem%+%count_strategy%
	goto:@return_find
)
REM set date_runing=%date:~6,4%-%date:~3,2%-%date:~0,2%
set /a find_strategy_found=0, find_strategy_kill_error=0, find_strategy_run_error=0, ap2_old=0
set "curl_cmd_scan="
echo.[%pos%G%lmess131% '[33mblockcheck[m' %lmess132%
echo.
echo.[%_pos%G[[33mi[m][%pos%G%lmess227%
call:check_kill
if %errorlevel% equ 2 (
	echo.[5G[31m%lmess20%.[m %lmess226%
	echo.[5G%lmess84%
	pause >nul
	goto:menu
)
if not exist %home%\find-strategy-config.txt (
	echo.[%_pos%G[[33mi[m][%pos%G%lmess7% '[33m%homenc%\find-strategy-config.txt[m'
	call:find_strategy_create_cfg
) else (
	echo.[%_pos%G[[33mi[m][%pos%G%lmess8% '[33m%homenc%\find-strategy-config.txt[m'
)
for /F "skip=1 eol=# tokens=1* delims==" %%a in (%home%\find-strategy-config.txt) do (
	set foo=%%a
	if defined foo set foo=!foo: =!
	if not "x!foo!"=="x" (
		set /a aoo=0
		for %%i in (STRATEGY_LIST_NAME CURL CURL_OPT CURL_MAX_TIME ENABLE_HTTP TTPS_TLS12 ENABLE_HTTPS_TLS13 ENABLE_HTTP3 REPEATS HTTP_PORT HTTPS_PORT QUIC_PORT SCANLEVEL DOMAINS PKTWS_EXTRA_PRE PKTWS_EXTRA) do (
			if "x%%i"=="x!foo!" set /a aoo=1
		)
		if !aoo! equ 1 (
			set goo=%%b
			set /a hoo=0
			if "x!foo!"=="xDOMAINS" set /a hoo=1
			if "x!foo!"=="xPKTWS_EXTRA_PRE" set /a hoo=1
			if "x!foo!"=="xPKTWS_EXTRA" set /a hoo=1
			if "x!foo!"=="xSTRATEGY_LIST_NAME" set /a hoo=1
			if !hoo! equ 0 if defined goo set goo=!goo: =!
			set "!foo!=!goo!"
		)
	)
)
echo.[%_pos%G[[33mi[m][%pos%G%lmess133%
if not defined DOMAINS set "DOMAINS=rutracker.org"
set DOMAINSFULL=%DOMAINS%
set DOMAINSFULL=%DOMAINSFULL:"=%
set /a foo=0
for %%i in (%DOMAINSFULL%) do (
	set /a foo+=1
	if !foo! equ 1 set DOMAINS=%%i
)
if %foo% gtr 1 (
	echo.[%_pos%G[[31mx[m][%pos%G[31mDOMAINS:[m "%DOMAINSFULL%"
	echo.[%_pos%G[[33mi[m][%pos%G%lmess134%
)
if defined DOMAINS set DOMAINS=%DOMAINS: =%
if defined CURL_MAX_TIME set "CURL_MAX_TIME=%CURL_MAX_TIME%"
if not defined CURL_MAX_TIME set "CURL_MAX_TIME=0.5"
if defined CURL_MAX_TIME echo.[%pos%G[36mCURL_MAX_TIME:[m %CURL_MAX_TIME%
set "type_find="
if defined ENABLE_HTTP if "x%ENABLE_HTTP%"=="x1" set "type_find=[HTTP]"
if defined ENABLE_HTTP3 if "x%ENABLE_HTTP3%"=="x1" set "type_find=[HTTP3]"
if defined ENABLE_HTTPS_TLS12 if "x%ENABLE_HTTPS_TLS12%"=="x1" set "type_find=[HTTPS]"
if defined ENABLE_HTTPS_TLS13 if "x%ENABLE_HTTPS_TLS13%"=="x1" set "type_find=[HTTPS]"
if not defined type_find set "type_find=[HTTPS]"
set /a foo=0
if defined ENABLE_HTTP if "x%ENABLE_HTTP%"=="x1" set /a foo+=1
if defined ENABLE_HTTPS_TLS12 if "x%ENABLE_HTTPS_TLS12%"=="x1" set /a foo+=1
if defined ENABLE_HTTP3 if "x%ENABLE_HTTP3%"=="x1" set /a foo+=1
if %foo% geq 2 (
	echo.[%_pos%G[[31mx[m][%pos%G%lmess135%: HTTP, HTTPS, HTTP3
	echo.[%_pos%G[[33mi[m][%pos%G%lmess136% HTTPS
	set "type_find=[HTTPS]"
)
if "x%type_find%"=="x[HTTP]" (
	if not defined HTTP_PORT set "HTTP_PORT=80"
	if defined HTTP_PORT echo.[%pos%G[36mHTTP_PORT:[m !HTTP_PORT!
)
if "x%type_find%"=="x[HTTP3]" (
	if not defined QUIC_PORT set "QUIC_PORT=443"
	if defined QUIC_PORT echo.[%pos%G[36mQUIC_PORT:[m !QUIC_PORT!
)
if "x%type_find%"=="x[HTTPS]" (
	if not defined HTTPS_PORT set "HTTPS_PORT=443"
	if defined HTTPS_PORT echo.[%pos%G[36mHTTPS_PORT:[m !HTTPS_PORT!
	if not defined ENABLE_HTTPS_TLS13 (
		set ENABLE_HTTPS_TLS13=0
	) else set ENABLE_HTTPS_TLS13=%ENABLE_HTTPS_TLS13%
	if not defined ENABLE_HTTPS_TLS12 (
		if "x!ENABLE_HTTPS_TLS13!"=="x0" set ENABLE_HTTPS_TLS12=1
	) else set ENABLE_HTTPS_TLS12=%ENABLE_HTTPS_TLS12%
	if "x!ENABLE_HTTPS_TLS13!"=="x1" (
		set "TLSver=--tlsv1.3"
		set "TLSmax="
	) else (
		set ENABLE_HTTPS_TLS12=1
		set "TLSver=--tlsv1.2"
		set "TLSmax=--tls-max 1.2"
	)
	if defined ENABLE_HTTPS_TLS12 echo.[%pos%G[36mENABLE_HTTPS_TLS12:[m !ENABLE_HTTPS_TLS12!
	if defined ENABLE_HTTPS_TLS13 echo.[%pos%G[36mENABLE_HTTPS_TLS13:[m !ENABLE_HTTPS_TLS13!
)
set /a REPEATSw=0
if defined REPEATS set /a REPEATSw=%REPEATS%
if %REPEATSw% lss 1 set "REPEATS=4"
if defined REPEATS echo.[%pos%G[36mREPEATS:[m %REPEATS%
set "curl_version="
if defined CURL (
	if not "x%CURL%"=="xcurl" (
		set foo=%CURL:/=\%
		if exist !foo! (
			for /f "delims=" %%a in ('2^>nul !foo! -V') do (
				set curl_version=%%a
				goto:@F
			)
		)
	)
)
:@F
if "x!curl_version:~0,4!"=="xcurl" ( set "CURLw=%foo%" ) else ( set "CURLw=curl" )
set "curl_version="
for /f "delims=" %%a in ('2^>nul %CURLw% -V') do (
	set curl_version=%%a
	goto:@F
)
:@F
if not "x!curl_version:~0,4!"=="xcurl" (
	echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess137%[m 'cURL'
	echo.[%_pos%G[[33mi[m][%pos%G%lmess45% '[33m%homenc%\bin\[m'
	if defined bin_curl (set "foo=%bin_curl%\curl.exe") else (set "foo=%home%\bin\[path-to-curl]\curl.exe")
	set foo=!foo:\=/!
	echo.[%pos%G%lmess138% '[33m%homenc%\find-strategy-config.txt[m' %lmess139% '[36mCURL=!foo![m'
	echo.
	echo.[%pos%G %lmess11% :
	echo.[%pos%G https://curl.se/windows/
	echo.
	goto:@find_strategy_end
)
if defined CURL echo.[%pos%G[36mCURL:[m %CURLw%
set "CURL=%CURLw%"
set "_CURL_OPT="
set "foo="
if defined CURL_OPT (
	for %%c in (%CURL_OPT%) do (
		if "x-k"=="x%%c" set "foo=!foo! %%c"
	)
)
if defined foo echo.[%pos%G[36mCURL_OPT:[m %foo%
set "_CURL_OPT=%foo%"
if defined SCANLEVEL echo.[%pos%G[36mSCANLEVEL:[m %SCANLEVEL%
if defined PKTWS_EXTRA_PRE echo.[%pos%G[36mPKTWS_EXTRA_PRE:[m %PKTWS_EXTRA_PRE%
if defined PKTWS_EXTRA echo.[%pos%G[36mPKTWS_EXTRA:[m %PKTWS_EXTRA%
set PKTWS_EXTRA_PRE=--hostlist-domains=%DOMAINS% %PKTWS_EXTRA_PRE%
set curl_version=%curl_version:(=%
set curl_version=%curl_version:)=%
for /f "tokens=2 delims= " %%a in ("%curl_version%") do set "foo=%%a"
echo.[%_pos%G[[32m+[m][%pos%G%lmess140% 'cURL' v.%foo%
set aoo=[2K[%_pos%G[[33mi[m][%pos%G%lmess228%
for /L %%c in (255,-1,0) do (
	if not "x!lmess228:~%%c,1!"=="x" (
		set /a foo=%%c+%pos%+1
		goto:@F
	)
)
:@F
if not defined STRATEGY_LIST_NAME set STRATEGY_LIST_NAME=strategy
set coo=0
for %%c in (%STRATEGY_LIST_NAME%) do (
	set /a coo+=1
	set "file_lst_arr!coo!=%%c.lst"
)
if %coo% equ 0 (
	echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess20%.[m %lmess21%
	goto:@find_strategy_end
)
set /a moo=1, total_strategy=0, boo=0
:@STRATEGY_LIST_NAME_LOOP
<nul set /p =%aoo%
set /a line_begin=1, total_strategy_tmp=0
set STRATEGY_LIST_NAME_TMP=!file_lst_arr%moo%!
if not exist %home%\strategy\%STRATEGY_LIST_NAME_TMP% goto:@F
for /F "usebackq tokens=1* delims=:" %%a in (`"findstr /n ^^ %home%\strategy\%STRATEGY_LIST_NAME_TMP%"`) do (
	set "hoo="
	set hoo=%%b
	set total_line=%%a
	if defined hoo (
		set hoo=!hoo: =!
		if !line_begin! neq 1 (
			if "x!hoo:~0,1!"=="x[" goto:@F
			if not "x!hoo:~0,1!"=="x#" (
				set /a total_strategy_tmp+=1, boo+=1
				set "find_strategy_line_!boo!=%STRATEGY_LIST_NAME_TMP% [%%a]"
				set "find_strategy_string_!boo!=%%b"
			)
		)
		if !line_begin! equ 1 if "x!hoo!"=="x%type_find%" set /a line_begin=0
	)
	<nul set /p =[%foo%G[0K[%foo%G [33m%STRATEGY_LIST_NAME_TMP% [%%a][m %type_find%: !total_strategy_tmp!
)
:@F
<nul set /p =[%foo%G[0K[%foo%G [33m%STRATEGY_LIST_NAME_TMP%[m %type_find%: %total_strategy_tmp%[E
set /a moo+=1
set /a total_strategy+=%total_strategy_tmp%
if %moo% gtr %coo% goto:@F
goto:@STRATEGY_LIST_NAME_LOOP
:@F
if %total_strategy% equ 0 (
	echo.[%_pos%G[[31mx[m][%pos%G%lmess141% %type_find%
	goto:@find_strategy_end
) else echo.[%_pos%G[[32m+[m][%pos%G%lmess154% %type_find% : %total_strategy%
set line_begin_mem=1
echo.[%_pos%G[[33mi[m][%pos%G%lmess143% [33m%DOMAINS%[m
set "_resolve="
for /f "delims=" %%a in ('2^>nul %CURL% --max-time 3 https://dns.google/resolve?name^=%DOMAINS%') do (
	set _resolve=%%a
)
set foo=0
if defined _resolve set foo=1
if %foo% equ 1 for /f "delims=" %%k in ('echo %_resolve% ^|find /i "Answer"') do set foo=2
if %foo% equ 2 goto:@F
echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess144%[m
goto:@find_strategy_end
:@F
for /f "tokens=4 delims={}" %%k in ("%_resolve%") do (
	for /f "tokens=5 delims=:" %%a in ("%%~k") do set ip_dom=%%a
)
if not defined ip_dom (
	echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess145%: [33m%_resolve%[m
	goto:@find_strategy_end
)
set ip_dom=%ip_dom:"=%
set ip_dom=%ip_dom: =%
for /f "tokens=1 delims=:" %%i in ("%ip_dom%") do set "ip_dom=%%i"
echo.[%_pos%G[[32m+[m][%pos%G%lmess140% IP: [33m%ip_dom%[m
set foo=0
for /f %%a in ('2^>nul nslookup iana.org %dnsserver1% ^| find "192.0.43.8"') do set foo=1
if %foo% equ 1 (
    echo.[%_pos%G[[33mi[m][%pos%G%lmess146% DNS1: [%dnsserver1%]
) else (
	echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess20:~0,-1%.[m DNS1: [%dnsserver1%]
	echo.[%pos%G%lmess40%
)
set "curl_user_agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.88 Safari/537.36"
if "x%type_find%"=="x[HTTPS]" (
	REM set curl_cmd_scan=--connect-to %DOMAINS%::[%ip_dom%]:%HTTPS_PORT% -ISsk -A "%curl_user_agent%" --max-time %CURL_MAX_TIME% %TLSver% %TLSmax% https://%DOMAINS%
	REM set curl_cmd_scan_long=--connect-to %DOMAINS%::[%ip_dom%]:%HTTPS_PORT% -Ssk -A "%curl_user_agent%" --max-time 60 %TLSver% %TLSmax% https://%DOMAINS%
	set curl_cmd_scan=-ISs %_CURL_OPT% -A "%curl_user_agent%" --max-time %CURL_MAX_TIME% %TLSver% %TLSmax% https://%DOMAINS%
	set curl_cmd_scan_long=-Ss %_CURL_OPT% -A "%curl_user_agent%" --max-time 60 %TLSver% %TLSmax% https://%DOMAINS%
	set _PORT=%HTTPS_PORT%
	set _HTTP=HTTPS
)
if "x%type_find%"=="x[HTTP3]" (
	REM set curl_cmd_scan=--connect-to %DOMAINS%::[%ip_dom%]:%QUIC_PORT% -Ss -A "%curl_user_agent%" --max-time %CURL_MAX_TIME% --http3-only https://%DOMAINS%
	REM set curl_cmd_scan_long=--connect-to %DOMAINS%::[%ip_dom%]:%QUIC_PORT% -Ss -A "%curl_user_agent%" --max-time 60 --http3-only https://%DOMAINS%
	set curl_cmd_scan=-Ss %_CURL_OPT% -A "%curl_user_agent%" --max-time %CURL_MAX_TIME% --http3-only https://%DOMAINS%
	set curl_cmd_scan_long=-Ss %_CURL_OPT% -A "%curl_user_agent%" --max-time 60 --http3-only https://%DOMAINS%
	set _PORT=%QUIC_PORT%
	set _HTTP=QUIC
)
if "x%type_find%"=="x[HTTP]" (
	set "foo="
	if defined _CURL_OPT (
		for %%c in (%_CURL_OPT%) do (
			if not "x-k"=="x%%c" set "foo=!foo! %%c"
		)
	)
	set "_CURL_OPT=!foo!"
	REM set curl_cmd_scan=--connect-to %DOMAINS%::[%ip_dom%]:%HTTP_PORT% -SsD %home%\bin\blk-hdr.txt -A "%curl_user_agent%" --max-time %CURL_MAX_TIME% http://%DOMAINS%
	REM set curl_cmd_scan_long=--connect-to %DOMAINS%::[%ip_dom%]:%HTTP_PORT% -SsD %home%\bin\blk-hdr.txt -A "%curl_user_agent%" --max-time 60 http://%DOMAINS%
	set curl_cmd_scan=-SsD !_CURL_OPT! %home%\bin\blk-hdr.txt -A "%curl_user_agent%" --max-time %CURL_MAX_TIME% http://%DOMAINS%
	set curl_cmd_scan_long=-SsD !_CURL_OPT! %home%\bin\blk-hdr.txt -A "%curl_user_agent%" --max-time 60 http://%DOMAINS%
	set _PORT=%HTTP_PORT%
	set _HTTP=HTTP
)
set "find_strategy_position_end="
for /f "delims=" %%I in ('2^>nul dir /b %home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.*') do set find_strategy_position_end=%%~xI
if not defined find_strategy_position_end (
	set /a find_strategy_position_end=0
) else (
	set find_strategy_position_end=!find_strategy_position_end:.=!
	set /a find_strategy_position_end=!find_strategy_position_end!
)
if %find_strategy_position_end% neq 0 (
	echo.[%_pos%G[[33mi[m][%pos%G%lmess147% '[33m%homenc%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_end%[m'
	echo.[%_pos%G[[33mi[m][%pos%G%lmess148% '[33m%find_strategy_position_end%[m', %lmess130%
)
if exist %home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_end% (
	for /F "skip=1" %%a in (%home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_end%) do set /a find_strategy_found+=1
) else echo.# %curl_cmd_scan% >%home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.%find_strategy_position_end%
if %find_strategy_position_end% geq %total_strategy% (
	echo.[%_pos%G[[31mx[m][%pos%G%lmess150%
	goto:@find_strategy_end
)
set ext_old=%find_strategy_position_end%
set /a count_strategy=%find_strategy_position_end%
call:progress_in_percent_begin %total_strategy%
set /a ap2=0
set /a foo=0
for /L %%c in (0,1,99) do (
	set /a foo+=!percent_step%%c!
	if %count_strategy% lss !foo! (
		set /a pinp = %%c
		set /a ap2 = %%c
		goto:@F
	)
)
:@F
set /a line_begin=1+%count_strategy%
cls
set /a line_jump_num=1
echo.
:@return_find
echo.]0;[!ap2!%%] %_title_%\
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[32m%lmess149% [33m'%DOMAINS%'[m [%ip_dom%][31m:%_PORT%[m
set /a line_jump_num+=1
echo.
set "foo=| 0        | 1        | 2        | 3        | 4                    | 5                       | 6                                   | 7        |"
set /a pos_table=%pos%-4
set /a pos_count=0
for /l %%x in (0,1,160) do (
	if "x!foo:~%%x,1!"=="x!pos_count!" (
		set /a pos!pos_count!=%pos_table%+%%x
		set /a pos_count+=1
	)
)
set "foo=0          1          2          3          4                      5                         6                                     7          8"
set /a pos_count=0
for /l %%x in (0,1,160) do (
	if "x!foo:~%%x,1!"=="x!pos_count!" (
		set /a ipos!pos_count!=%pos_table%+%%x
		set /a pos_count+=1
	)
)
<nul set /p =(0
for /l %%x in (%ipos0%,1,%ipos8%) do (
	if %%x equ %ipos0% (
		<nul set /p =[%%xGl
	) else if %%x equ %ipos1% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos2% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos3% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos4% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos5% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos6% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos7% (
		<nul set /p =[%%xGw
	) else if %%x equ %ipos8% (
		<nul set /p =[%%xGk
	) else (
		<nul set /p =[%%xGq
	)
)
<nul set /p =(B
echo.
<nul set /p =[2K(0[%ipos0%Gx[%ipos1%Gx[%ipos2%Gx[%ipos3%Gx[%ipos4%Gx[%ipos5%Gx[%ipos6%Gx[%ipos7%Gx[%ipos8%Gx(B
<nul set /p =[%pos0%G%lmess151%[%pos1%G%lmess152%[%pos2%G%lmess153%[%pos3%G%lmess154%[%pos4%G%lmess155%[%pos5%G%lmess156%[%pos6%G%lmess69%[%pos7%G%lmess158%[E
<nul set /p =(0
for /l %%x in (%ipos0%,1,%ipos8%) do (
	if %%x equ %ipos0% (
		<nul set /p =[%%xGt
	) else if %%x equ %ipos1% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos2% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos3% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos4% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos5% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos6% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos7% (
		<nul set /p =[%%xGn
	) else if %%x equ %ipos8% (
		<nul set /p =[%%xGu
	) else (
		<nul set /p =[%%xGq
	)
)
<nul set /p =(B
echo.
REM echo.[?25l
<nul set /p =7
<nul set /p =8[2K(0[%ipos0%Gx[%ipos1%Gx[%ipos2%Gx[%ipos3%Gx[%ipos4%Gx[%ipos5%Gx[%ipos6%Gx[%ipos7%Gx[%ipos8%Gx(B
echo.
<nul set /p =(0
for /l %%x in (%ipos0%,1,%ipos8%) do (
	if %%x equ %ipos0% (
		<nul set /p =[%%xGm
	) else if %%x equ %ipos1% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos2% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos3% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos4% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos5% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos6% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos7% (
		<nul set /p =[%%xGv
	) else if %%x equ %ipos8% (
		<nul set /p =[%%xGj
	) else (
		<nul set /p =[%%xGq
	)
)
<nul set /p =(B
echo.
set /a line_jump_num+=6
set /a line_jump_num+=1
if %mode_con_lines% geq 40 (set /a foo=%mode_con_lines%-10) else (set /a foo=%mode_con_lines%-5)
echo.[%line_jump_num%;%foo%r
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess159% '[33m..\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.*[m'
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess160% [[36m%DOMAINS%-%_PORT%-%_HTTP%[m]
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess161%
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess162% '[33m..\strategy\blockcheck\[[36mdate[33m]\%DOMAINS%\%_HTTP%\*-[[36m%lmess163%[33m][m'
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess164% '[36m*-[%lmess163%][m' %lmess165% '[33m..\strategy\[m'
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess166%
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess167% '[36m%lmess69%: [32m%lmess59%[m' %lmess168%: ['[36m%lmess506%[m']
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess169%
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess170%
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G[31m%lmess35%[m %lmess171%
set /a line_jump_num+=1
echo.[%line_jump_num%H[%_pos%G[[33mi[m][%pos%G%lmess172% ['[36m%lmess506%[m']: %lmess173%
set /a ipos7dec=%ipos7%-1
set /a ipos8dec=%ipos8%-1
set "empty6="
for /L %%c in (%pos6%,1,%ipos7dec%) do set "empty6=!empty6! "
set "empty7="
for /L %%c in (%pos7%,1,%ipos8dec%) do set "empty7=!empty7! "
set ap2_old=0
set /a find_strategy_loop_count=%line_begin%
set "last_message=none"
:@find_strategy_loop
set "read_line=!find_strategy_string_%find_strategy_loop_count%!"
set "line_count=!find_strategy_line_%find_strategy_loop_count%!"
if not defined read_line goto:@find_strategy_next
set comment_char=%read_line: =%
set comment_char=%comment_char:~0,1%
if "x%comment_char%"=="x#" goto:@find_strategy_next
<nul set /p =8[%pos0%G!ap2!%%[%pos1%G%count_strategy%[%pos2%G%total_strategy%[%pos3%G%find_strategy_found%[%pos4%G%find_strategy_run_error%[%pos5%G%find_strategy_kill_error%[%pos6%G%lmess34%[%pos7%G%empty7%[?25l[8m
set foo=0
set hoo=!TIME:~0,8!
for /l %%c in (1,1,50) do (
	%CURL% -I --max-time 6 %dnsserver1% 1>nul 2>&1 &&(goto:@F)||(
		if !foo! equ 0 (
			set foo=1
			if not "x!last_message!"=="xcurlping" set /a line_jump_num+=1
			echo.[!line_jump_num!H[%_pos%G[m[[33mi[m][%pos%G[!hoo!] [33m%lmess48%, %lmess1007%[m
			set "last_message=curlping"
		)
	)
)
set "jump=ping_error"
goto:@find_strategy_
:@F
set "hoo="
<nul set /p =8[%pos0%G!ap2!%%[%pos1%G%count_strategy%[%pos2%G%total_strategy%[%pos3%G%find_strategy_found%[%pos4%G%find_strategy_run_error%[%pos5%G%find_strategy_kill_error%[%pos6%G%empty6%[%pos7%G[?25l[8m
<nul set /p =8[%pos0%G!ap2!%%[%pos1%G%count_strategy%[%pos2%G%total_strategy%[%pos3%G%find_strategy_found%[%pos4%G%find_strategy_run_error%[%pos5%G%find_strategy_kill_error%[%pos6%G%lmess7%[%pos7%G[?25l[8m
call:progress_in_percent_count ap2
set /a count_strategy+=1
if defined PKTWS_EXTRA_PRE (
	set /a read_linecount=0
	for /L %%c in (0,1,16) do (
		if !read_linecount! equ 0 if "x!read_line:~%%c,1!"=="x " (
			set read_line=!read_line:~0,%%c! %PKTWS_EXTRA_PRE% !read_line:~%%c!
			set /a read_linecount=1
		)
	)
)
if defined PKTWS_EXTRA (
	set read_line=!read_line! %PKTWS_EXTRA%
)
set /a read_linecount=0
for /L %%c in (1024,-1,0) do (
	if "x!read_line:~%%c,2!"=="x--" (
		set "read_line!read_linecount!=!read_line:~%%c!"
		set "read_line=!read_line:~0,%%c!"
		set /a read_linecount+=1
	)
)
set /a read_linecount-=1
set /a generate_count=%read_linecount%
set "winws_arg_str_="
set "winws_arg_str_e="
set exist_fake_tls_std=0
for /L %%c in (%read_linecount%,-1,0) do (
	set /a parse_desync = 0
	if defined read_line%%c (
		for /F "tokens=1,2 delims==" %%d in ("!read_line%%c!") do (
			if "x%%d"=="x--dpi-desync-fake-tls" (
				set "foo=%%e"
				set "_fake=%%e"
				if defined foo set "foo=!foo: =!"
				if "x!foo!"=="x" (
					set exist_fake_tls_std=1
					set "winws_arg_str_=!winws_arg_str_! --dpi-desync-fake-tls=^^^^^!"
					set "generate_str%%c=--dpi-desync-fake-tls=^!"
				) else (
					set /a parse_desync = 1
				)
			) else if "x%%d"=="x--dpi-desync-fakedsplit-pattern" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-fake-unknown" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-fake-syndata" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-fake-wireguard" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-fake-dht" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-fake-discord" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-fake-stun" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-udplen-pattern" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-split-seqovl-pattern" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-fake-quic" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--dpi-desync-fake-unknown-udp" (
				set /a parse_desync = 1
			) else if "x%%d"=="x--wf-tcp" (
				set "winws_arg_str_=!winws_arg_str_! --wf-tcp=%_PORT%"
				set "generate_str%%c=--wf-tcp=%_PORT%"
			) else if "x%%d"=="x--wf-udp" (
				set "winws_arg_str_=!winws_arg_str_! --wf-udp=%_PORT%"
				set "generate_str%%c=--wf-udp=%_PORT%"
			) else (
				set "winws_arg_str_=!winws_arg_str_! !read_line%%c!"
				set "generate_str%%c=!read_line%%c!"
			)
			if !parse_desync! equ 1 (
				set "foo=%%e"
				set "hoo=%%e"
				if defined foo set "foo=!foo: =!"
				if "x!foo:~0,2!"=="x0x" (
					set "winws_arg_str_=!winws_arg_str_! !read_line%%c!"
					set "generate_str%%c=!read_line%%c!"
				) else (
					call:@get_file hoo
					set "winws_arg_str_=!winws_arg_str_! %%d=%winwsdir%\..\..\files\fake\!hoo! "
					set "generate_str%%c=%%d=%fakedir%\!hoo!"
				)
			)
		)
	)
)
<nul set /p =8[%pos0%G!ap2!%%[%pos1%G%count_strategy%[%pos2%G%total_strategy%[%pos3%G%find_strategy_found%[%pos4%G%find_strategy_run_error%[%pos5%G%find_strategy_kill_error%[%pos6%G%empty6%[%pos7%G[?25l[8m
<nul set /p =8[%pos0%G!ap2!%%[%pos1%G%count_strategy%[%pos2%G%total_strategy%[%pos3%G%find_strategy_found%[%pos4%G%find_strategy_run_error%[%pos5%G%find_strategy_kill_error%[%pos6%G%lmess231%[%pos7%G[?25l[8m
%winwsdir%\winws.exe --daemon %winws_arg_str_% %winws_arg_str_e% 1>nul 2>&1
if %errorlevel% equ 0 (
	set /a curl_ret_code_0=1000
	for /l %%c in (1,1,%REPEATS%) do (
		set curl_ret_code=0
		%CURL% %curl_cmd_scan% 1>nul 2>&1
		set curl_ret_code_str=!errorlevel!
		if !curl_ret_code_str! equ 0 set /a curl_ret_code_0=0
		set /a curl_ret_code+=!curl_ret_code_str!
		if !curl_ret_code_str! equ 0 (
			set "curl_ret_code_str_s=[32mOK[m"
		) else if !curl_ret_code_str! equ 2 (
			set "jump=curl_2"
			if %%c equ %REPEATS% goto:@find_strategy_
			set "curl_ret_code_str_s=[31mFAILED_INIT[m"
		) else if !curl_ret_code_str! equ 6 (
			set "jump=curl_6"
			if %%c equ %REPEATS% goto:@find_strategy_
			set "curl_ret_code_str_s=[31mCOULDNT_RESOLVE_HOST[m"
		) else if !curl_ret_code_str! equ 28 (
			set "curl_ret_code_str_s=[33mOPERATION_TIMEDOUT[m"
		) else if !curl_ret_code_str! equ 35 (
			set "curl_ret_code_str_s=[33mSSL_CONNECT_ERROR[m"
		) else (
			set "curl_ret_code_str_s=[33mUNKNOWN_ERROR[m"
			set /a line_jump_num+=1
			echo.[!line_jump_num!H[%_pos%G[m[[33mi[m][%pos%GcURL: [33m%lmess20% [!curl_ret_code_str!][m'
			set "last_message=retcode"
		)
		<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G%empty6%[%pos7%G%%c[?25l[8m
		<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G!curl_ret_code_str_s![%pos7%G%%c[?25l[8m
		if %%c equ %REPEATS% (
			set foo=0
			if !curl_ret_code! equ 0 (
				<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G%empty6%[%pos7%G%empty7%[?25l[8m
				<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G%lmess174%[%pos7%G[?25l[8m
				%CURL% %curl_cmd_scan_long% 1>nul 2>&1
				if !errorlevel! equ 0 set foo=1
			) else (
				if !curl_ret_code_0! equ 0 if "x%SCANLEVEL%"=="xquick" if %REPEATS% gtr 1 set foo=1
			)
			if !foo! equ 1 (
				set /a find_strategy_found+=1
				echo.%line_count%: %winws_arg_str_% %winws_arg_str_e% >>%home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.!ext_old!
				move /Y %home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.!ext_old! %home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.!count_strategy! 1>nul 2>&1
				set ext_old=!count_strategy!
				call:create_strategy "%line_count%"
			)
		)
	)
) else (
	echo.[%date_runing%] %line_count%: %winwsdir%\winws.exe --debug=1 %winws_arg_str_% %winws_arg_str_e% >>%home%\strategy\error-%DOMAINS%-%_PORT%-%_HTTP%.log
	%winwsdir%\winws.exe --daemon %winws_arg_str_% %winws_arg_str_e% 1>nul 2>"%temp%\run_cmd_find_strategy_winws_error"
	set /a find_strategy_run_error+=1
	set /a line_jump_num+=1
	echo.[!line_jump_num!H[%_pos%G[m[[31mx[m][%pos%G[31m%lmess155%.[m %lmess100% '[33m..\strategy\error-%DOMAINS%-%_PORT%-%_HTTP%.log[m'
	set "last_message=runerror"
)
call:check_kill -drv
if %errorlevel% neq 0 (
	set /a find_strategy_kill_error+=1
	set "jump=kill_error"
	goto:@find_strategy_
)
if not "x%ap2_old%"=="x%ap2%" (
	move /Y %home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.%ext_old% %home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.%count_strategy% 1>nul 2>&1
	set ext_old=%count_strategy%
	set "ap2_old=%ap2%"
	echo.]0;[!ap2!%%] %_title_%\
)
<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G%empty6%[%pos7%G%empty7%[?25l[8m
<nul set /p =8[%pos0%G!ap2!%%[%pos1%G!count_strategy![%pos2%G%total_strategy%[%pos3%G!find_strategy_found![%pos4%G!find_strategy_run_error![%pos5%G!find_strategy_kill_error![%pos6%G[32m%lmess59%[m[%pos7%G[?25l[8m
set "jump=end_choice"
choice /N /C:z%lmess506% /D z /T 1  1>nul 2>&1
if %errorlevel% neq 1 goto:@find_strategy_
:@find_strategy_next
set /a find_strategy_loop_count+=1
if %find_strategy_loop_count% leq %total_line% goto:@find_strategy_loop
set "jump=break"
goto:@find_strategy_
:@find_strategy_txtmess
echo.
echo.[%pos%G%lmess90%
echo.
echo.[%pos%G[31m%lmess35%[m: %lmess91%. 
echo.[%pos%G[33mWINDIVERT[m - %lmess92%
echo.[%pos%G[33mUPX[m - %lmess93%
echo.
echo.[%pos%G[32m%lmess94%[m
echo.
echo.[%pos%G%lmess95% '[33m%homenc%[m' %lmess96%
goto:@find_strategy_end
:@find_strategy_
set hoo=!TIME:~0,8!
if "x%jump%"=="xbreak" set ap2=100
if "x%jump%"=="xcurl_2" set "foo="
if "x%jump%"=="xcurl_6" set "foo="
<nul set /p =8[%pos0%G%ap2%%%[%pos1%G%count_strategy%[%pos2%G%total_strategy%[%pos3%G%find_strategy_found%[%pos4%G%find_strategy_run_error%[%pos5%G%find_strategy_kill_error%[%pos6%G%empty6%[%pos7%G%empty7%[?25l[8m[2E
call:check_kill
if %errorlevel% equ 2 (
	set /a line_jump_num+=1
	echo.[!line_jump_num!H[%pos%G[m[!hoo!] [31m%lmess20%.[m %lmess226%
)
set /a line_jump_num+=1
echo.[m[%line_jump_num%H
set /a line_jump_num+=1
echo.[%pos%G[!hoo!]
goto:@find_strategy_%jump%
:@find_strategy_break
if exist %home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.%ext_old% (
	move /Y %home%\strategy\run-%DOMAINS%-%_PORT%-%_HTTP%.%ext_old% %home%\strategy\done-%DOMAINS%-%_PORT%-%_HTTP%.log 1>nul 2>&1
)
echo.[%pos%G%lmess89%
echo.
echo.[%pos%G%lmess175%: [32m%find_strategy_found%[m
if %find_strategy_found% neq 0 (
	echo.[%pos%G%lmess176% '[33m%homenc%\strategy\done-%DOMAINS%-%_PORT%-%_HTTP%.log[m'
	echo.[%pos%G%lmess177% '[33m%homenc%\strategy\blockcheck\%DOMAINS%\%_HTTP%\[m'
	echo.[%pos%G%lmess164% '[36m%DOMAINS%-%_HTTP%-[%lmess163%][m' %lmess165% '[33m%homenc%\strategy\[m'
)
goto:@find_strategy_end
:@find_strategy_curl_2
echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess178%[m
echo.[%_pos%G[%pos%G%lmess179%
echo.[%_pos%G[%pos%G%lmess180%
echo.[%_pos%G[%pos%G%lmess45% '[33m%homenc%\bin\[m'
if defined bin_curl (set "foo=%bin_curl%\curl.exe") else (set "foo=%home%\bin\[path-to-curl]\curl.exe")
set foo=%foo:\=/%
echo.[%pos%G%lmess138% '[33m%homenc%\find-strategy-config.txt[m' %lmess139% '[36mCURL=%foo%[m'
echo.
echo.[%pos%G%lmess11% :
echo.[%pos%Ghttps://curl.se/windows/
goto:@find_strategy_end
:@find_strategy_curl_6
echo.[%_pos%G[[31mx[m][%pos%G[31m%lmess20:~0,-1%. [mcURL "[31mCould not resolve host[m". %lmess181%
echo.[%pos%G%lmess182%
echo.[%pos%G%lmess183%
echo.[%pos%G%lmess184%
echo.[%pos%G%lmess185%
echo.
echo.[%pos%G%lmess186%:
echo.
echo.[%pos%G1. %lmess187%
echo.[%pos%G2. %lmess188%
goto:@find_strategy_end
:@find_strategy_end_choice
goto:menu
:@find_strategy_run_error
echo.[%pos%G[31m%lmess155%[m
echo.
echo.[%pos%G'winws.exe %winws_arg_str_% %winws_arg_str_e%'
echo.
echo. [36m-- begin type error --[31m
echo.
type "%temp%\run_cmd_find_strategy_winws_error"
echo.
echo. [36m--  end type error  --[m
echo.
goto:@find_strategy_end_error
:@find_strategy_kill_error
echo.[%pos%G[31m%lmess156%[m
goto:@find_strategy_end_error
:@find_strategy_ping_error
echo.[%pos%G[!hoo!] [31m%lmess189%[m
goto:@find_strategy_end_error
:@find_strategy_end_error
echo.[%pos%G%lmess190%
:@find_strategy_end
echo.
echo.[%pos%G%lmess84%
echo.[?25h
pause >nul
goto:menu

:create_strategy
set "_dir=%~1"
set "_dir=%_dir: =-%"
set "_dir=%_dir:.lst=%"
set "_dir=%_dir:[=%"
set "_dir=%_dir:]=%"
set date_runing=%date:~6,4%-%date:~3,2%-%date:~0,2%
set "generate_to=%home%\strategy\blockcheck\%date_runing%\%DOMAINS%\%_HTTP%\%_dir%" 
if not exist %generate_to% ( 
	md %generate_to%\custom >nul 2>&1
	md %generate_to%\skip >nul 2>&1
)
chcp 65001 >nul
if not exist %generate_to%\about echo.%lmess191% %_dir%: %DOMAINS%:%_PORT% %_HTTP% >%generate_to%\about
echo.#Create from %~1 >%generate_to%\%_PORT%-%_HTTP%.strategy
for /l %%i in (%generate_count%,-1,0) do (
	if defined generate_str%%i (
		if not "x!generate_str%%i:~0,10!"=="x--hostlist" (
			echo.!generate_str%%i!>>%generate_to%\%_PORT%-%_HTTP%.strategy
		) else (
			echo.--hostlist=>>%generate_to%\%_PORT%-%_HTTP%.strategy
		)
	)
)
if "x%_HTTP%"=="xHTTPS" (
	call:@create_strategy_base_http
	call:@create_strategy_base_http3
) else if "x%_HTTP%"=="xHTTP" (
	call:@create_strategy_base_https
	call:@create_strategy_base_http3
) else if "x%_HTTP%"=="xHTTP3" (
	call:@create_strategy_base_http
	call:@create_strategy_base_https
)
chcp %lmess1% >nul
exit /b

:@create_strategy_base_http
if not exist %generate_to%\80-HTTP.strategy (
	(
	echo.# Create from script base_http
	echo.--wf-tcp=80
	echo.--dpi-desync=fake,fakedsplit
	echo.--dpi-desync-autottl=2
	echo.--dpi-desync-fooling=badseq
	echo.--hostlist-auto=
	)>%generate_to%\80-HTTP.strategy
)
exit /b

:@create_strategy_base_https
if not exist %generate_to%\443-HTTPS.strategy (
	(
	echo.# Create from script base_https
	echo.--wf-tcp=443
	echo.--hostlist=
	echo.--dpi-desync=fake,multidisorder
	echo.--dpi-desync-split-pos=1,midsld
	echo.--dpi-desync-repeats=11
	echo.--dpi-desync-fooling=md5sig
	echo.--dpi-desync-fake-tls-mod=rnd,dupsid,sni=www.google.com
	echo.--new
	echo.--dpi-desync=fake,multidisorder
	echo.--dpi-desync-split-pos=midsld
	echo.--dpi-desync-repeats=6
	echo.--dpi-desync-fooling=badseq,md5sig
	echo.--hostlist-auto=
	)>%generate_to%\443-HTTPS.strategy
)
exit /b

:@create_strategy_base_http3
if not exist %generate_to%\443-HTTP3.strategy (
	(
	echo.# Create from script base_http3
	echo.--wf-udp=443
	echo.--hostlist=
	echo.--dpi-desync=fake
	echo.--dpi-desync-repeats=11
	echo.--dpi-desync-fake-quic=quic_initial_www_google_com.bin
	echo.--new
	echo.--dpi-desync=fake
	echo.--dpi-desync-repeats=11
	echo.--hostlist-auto=
	)>%generate_to%\443-HTTP3.strategy
)
if exist %generate_to% (
	set /a line_jump_num+=1
	echo.[!line_jump_num!H[%_pos%G[m[[32m+[m][%pos%G%lmess7%: [33m..\!generate_to:~%homestrsize%![m
) else (
	set /a line_jump_num+=1
	echo.[!line_jump_num!H[%_pos%G[m[[31mx[m][%pos%G[31m%lmess20%.[m %lmess7%: [33m..\!generate_to:~%homestrsize%![m
)
exit /b

:generate_raw_file
set "generate_raw_file_str=%~1"
set "generate_raw_file_out=%~2"
call set generate_raw_file_str=%%%generate_raw_file_str%%%
call set generate_raw_file_out=%%%generate_raw_file_out%%%
if not defined generate_raw_file_str exit /b 1
if not defined generate_raw_file_out exit /b 1
(set LF=^
%=EMPTY=%
)
set /a coo=0
set /a ccc=50
:@generate_raw_file_loop_clear
set "ip_raw_array%coo%="
set "port_raw_array%coo%="
set /a coo+=1
if %coo% gtr %ccc% goto:@F
goto:@generate_raw_file_loop_clear
:@F
for /f "tokens=1,2,3,4 delims={}" %%a in ("%generate_raw_file_str%") do (
	set "generate_raw_file_name=%%a"
	set "generate_raw_proto=%%b"
	set "port_raw_str=%%c"
	set "ip_raw_str=%%d"
)
if not defined generate_raw_file_name exit /b 1
if not defined generate_raw_proto exit /b 1
set "generate_raw_file_out=%generate_raw_file_out%\%generate_raw_file_name%"
if not defined port_raw_str goto:@F
set port_raw_str=%port_raw_str: =%
set port_raw_str=%port_raw_str:,= %
set /a generate_raw_file_count=0
for %%a in (%port_raw_str%) do (
	set "port_raw_array!generate_raw_file_count!=%%a"
	set /a generate_raw_file_count+=1
)
:@F
if not defined ip_raw_str goto:@F
set ip_raw_str=%ip_raw_str: =%
set ip_raw_str=%ip_raw_str:,= %
set /a generate_raw_file_count=0
for %%a in (%ip_raw_str%) do (
	set "ip_raw_array!generate_raw_file_count!=%%a"
	set /a generate_raw_file_count+=1
)
:@F
if exist %generate_raw_file_out% del /f /q %generate_raw_file_out%
if not "x%generate_raw_proto%"=="xtcp" goto:@F
<nul set /p =^^!impostor and ^^!loopback and ((!LF!>%generate_raw_file_out%
<nul set /p =outbound and (^^!tcp or tcp.Syn or tcp.Rst or tcp.Fin or tcp.PayloadLength^>0) >>%generate_raw_file_out%
goto:@L2555
:@F
<nul set /p =^^!impostor and ^^!loopback and ((!LF!>%generate_raw_file_out%
<nul set /p =outbound >>%generate_raw_file_out%
:@L2555

rem ----- outbound port

if not defined port_raw_str goto:@L2602
<nul set /p =and (>>%generate_raw_file_out%
set /a generate_raw_file_count=0
:@loop_port_raw_array_outbound
set "port_raw_array_b="
set "port_raw_array_e="
for /f "tokens=1,2 delims=-" %%a in ("!port_raw_array%generate_raw_file_count%!") do (
	set "port_raw_array_b=%%a"
	set "port_raw_array_e=%%b"
)
if not defined port_raw_array_e goto:@L2565
if "x%port_raw_array_b:~0,1%"=="x~" goto:@F
<nul set /p =(%generate_raw_proto%.DstPort^>=%port_raw_array_b% and %generate_raw_proto%.DstPort^<=%port_raw_array_e%>>%generate_raw_file_out%
goto:@L2568
:@F
set "port_raw_array_b=%port_raw_array_b:~1%"
<nul set /p =(%generate_raw_proto%.DstPort^<%port_raw_array_b% and %generate_raw_proto%.DstPort^>%port_raw_array_e%>>%generate_raw_file_out%
goto:@L2568
:@L2565
if "x%port_raw_array_b:~0,1%"=="x~" goto:@F
<nul set /p =(%generate_raw_proto%.DstPort==%port_raw_array_b%>>%generate_raw_file_out%
goto:@L2568
:@F
set "port_raw_array_b=%port_raw_array_b:~1%"
<nul set /p =(%generate_raw_proto%.DstPort^^!=%port_raw_array_b%>>%generate_raw_file_out%
:@L2568
set /a generate_raw_file_count+=1
if not defined port_raw_array%generate_raw_file_count% goto:@F
<nul set /p =) or >>%generate_raw_file_out%
goto:@loop_port_raw_array_outbound
:@F
<nul set /p =)) >>%generate_raw_file_out%
:@L2602

rem ----- outbound ip

if not defined ip_raw_str goto:@L2621
set /a generate_raw_file_count=0
<nul set /p =and (>>%generate_raw_file_out%
:@loop_ip_raw_array_outbound
set "ip_raw_array_b="
set "ip_raw_array_e="
for /f "tokens=1,2 delims=-" %%a in ("!ip_raw_array%generate_raw_file_count%!") do (
	set "ip_raw_array_b=%%a"
	set "ip_raw_array_e=%%b"
)
if not defined ip_raw_array_e goto:@L2601
if "x%ip_raw_array_b:~0,1%"=="x~" goto:@F
<nul set /p =(ip.DstAddr^>=%ip_raw_array_b% and ip.DstAddr^<=%ip_raw_array_e%>>%generate_raw_file_out%
goto:@L2603
:@F
set "ip_raw_array_b=%ip_raw_array_b:~1%"
<nul set /p =(ip.DstAddr^<%ip_raw_array_b% and ip.DstAddr^>%ip_raw_array_e%>>%generate_raw_file_out%
goto:@L2603
:@L2601
if "x%ip_raw_array_b:~0,1%"=="x~" goto:@F
<nul set /p =(ip.DstAddr==%ip_raw_array_b%>>%generate_raw_file_out%
goto:@L2603
:@F
set "ip_raw_array_b=%ip_raw_array_b:~1%"
<nul set /p =(ip.DstAddr^^!=%ip_raw_array_b%>>%generate_raw_file_out%
:@L2603
set /a generate_raw_file_count+=1
if not defined ip_raw_array%generate_raw_file_count% goto:@F
<nul set /p =) or >>%generate_raw_file_out%
goto:@loop_ip_raw_array_outbound
:@F
<nul set /p =)) >>%generate_raw_file_out%

:@L2621

<nul set /p =and (((ip.DstAddr^>127.255.255.255 or ip.DstAddr^<127.0.0.1) and (ip.DstAddr^>10.255.255.255 or ip.DstAddr^<10.0.0.0) and (ip.DstAddr^>192.168.255.255 or ip.DstAddr^<192.168.0.0) and (ip.DstAddr^>172.31.255.255 or ip.DstAddr^<172.16.0.0) and (ip.DstAddr^>169.254.255.255 or ip.DstAddr^<169.254.0.0)) or ((ipv6.DstAddr^>::1) and (ipv6.DstAddr^>=2001:1::0 or ipv6.DstAddr ^< 2001::0) and (ipv6.DstAddr^>=fe00::0 or ipv6.DstAddr^<fc00::0) and (ipv6.DstAddr^>=ffff::0 or ipv6.DstAddr^<ff00::0)))) or (!LF!>>%generate_raw_file_out%
if not "x%generate_raw_proto%"=="xudp" goto:@F
<nul set /p =inbound and tcp and false))!LF!>>%generate_raw_file_out%
goto:@generate_raw_file_end
:@F
<nul set /p =inbound and (tcp or ((tcp.Ack and tcp.Syn or tcp.Rst or tcp.Fin) or (>>%generate_raw_file_out%
<nul set /p =tcp.PayloadLength^>=12 and tcp.Payload32[0]==0x48545450 and tcp.Payload16[2]==0x2F31 and tcp.Payload[6]==0x2E and tcp.Payload16[4]==0x2033 and tcp.Payload[10]==0x30 and (tcp.Payload[11]==0x32 or tcp.Payload[11]==0x37)))) >>%generate_raw_file_out%

rem ----- inbound port

if not defined port_raw_str goto:@L2680
set /a generate_raw_file_count=0
<nul set /p =and (>>%generate_raw_file_out%
:@loop_port_raw_array_inbound
set "port_raw_array_b="
set "port_raw_array_e="
for /f "tokens=1,2 delims=-" %%a in ("!port_raw_array%generate_raw_file_count%!") do (
	set "port_raw_array_b=%%a"
	set "port_raw_array_e=%%b"
)
if not defined port_raw_array_e goto:@L2665
if "x%port_raw_array_b:~0,1%"=="x~" goto:@F
<nul set /p =(%generate_raw_proto%.SrcPort^>=%port_raw_array_b% and %generate_raw_proto%.SrcPort^<=%port_raw_array_e%>>%generate_raw_file_out%
goto:@L2667
:@F
set "port_raw_array_b=%port_raw_array_b:~1%"
<nul set /p =(%generate_raw_proto%.SrcPort^<%port_raw_array_b% and %generate_raw_proto%.SrcPort^>%port_raw_array_e%>>%generate_raw_file_out%
goto:@L2667
:@L2665
if "x%port_raw_array_b:~0,1%"=="x~" goto:@F
<nul set /p =(%generate_raw_proto%.SrcPort==%port_raw_array_b%>>%generate_raw_file_out%
goto:@L2667
:@F
set "port_raw_array_b=%port_raw_array_b:~1%"
<nul set /p =(%generate_raw_proto%.SrcPort^^!=%port_raw_array_b%>>%generate_raw_file_out%
:@L2667
set /a generate_raw_file_count+=1
if not defined port_raw_array%generate_raw_file_count% goto:@F
<nul set /p =) or >>%generate_raw_file_out%
goto:@loop_port_raw_array_inbound
:@F
<nul set /p =)) >>%generate_raw_file_out%
:@L2680

rem ----- inbound ip

if not defined ip_raw_str goto:@L2720
set /a generate_raw_file_count=0
<nul set /p =and (>>%generate_raw_file_out%
:@loop_ip_raw_array_inbound
set "ip_raw_array_b="
set "ip_raw_array_e="
for /f "tokens=1,2 delims=-" %%a in ("!ip_raw_array%generate_raw_file_count%!") do (
	set "ip_raw_array_b=%%a"
	set "ip_raw_array_e=%%b"
)
if not defined ip_raw_array_e goto:@L2696
if "x%ip_raw_array_b:~0,1%"=="x~" goto:@F
<nul set /p =(ip.SrcAddr^>=%ip_raw_array_b% and ip.SrcAddr^<=%ip_raw_array_e%>>%generate_raw_file_out%
goto:@L2698
:@F
set "ip_raw_array_b=%ip_raw_array_b:~1%"
<nul set /p =(ip.SrcAddr^<%ip_raw_array_b% and ip.SrcAddr^>%ip_raw_array_e%>>%generate_raw_file_out%
goto:@L2698
:@L2696
if "x%ip_raw_array_b:~0,1%"=="x~" goto:@F
<nul set /p =(ip.SrcAddr==%ip_raw_array_b%>>%generate_raw_file_out%
goto:@L2698
:@F
set "ip_raw_array_b=%ip_raw_array_b:~1%"
<nul set /p =(ip.SrcAddr^^!=%ip_raw_array_b%>>%generate_raw_file_out%
:@L2698
set /a generate_raw_file_count+=1
if not defined ip_raw_array%generate_raw_file_count% goto:@F
<nul set /p =) or >>%generate_raw_file_out%
goto:@loop_ip_raw_array_inbound
:@F
<nul set /p =)) >>%generate_raw_file_out%
 
:@L2720

<nul set /p =and (((ip.SrcAddr^>127.255.255.255 or ip.SrcAddr^<127.0.0.1) and (ip.SrcAddr^>10.255.255.255 or ip.SrcAddr^<10.0.0.0) and (ip.SrcAddr^>192.168.255.255 or ip.SrcAddr^<192.168.0.0) and (ip.SrcAddr^>172.31.255.255 or ip.SrcAddr^<172.16.0.0) and (ip.SrcAddr^>169.254.255.255 or ip.SrcAddr^<169.254.0.0)) or ((ipv6.SrcAddr^>::1) and (ipv6.SrcAddr^>=2001:1::0 or ipv6.SrcAddr^<2001::0) and (ipv6.SrcAddr^>=fe00::0 or ipv6.SrcAddr^<fc00::0) and (ipv6.SrcAddr^>=ffff::0 or ipv6.SrcAddr^<ff00::0)))))!LF!>>%generate_raw_file_out%
:@generate_raw_file_end
set /a coo=0
:@generate_raw_file_loop_reset
set "ip_raw_array%coo%="
set "port_raw_array%coo%="
set /a coo+=1
if %coo% gtr %ccc% goto:@F
goto:@generate_raw_file_loop_reset
:@F

set %~2=%generate_raw_file_name%
exit /b 0

:co_is_utf8
call set co_is_utf8_2=%%%~2%%
chcp 65001 >nul
set /p co_is_utf8_foo=<%co_is_utf8_2%
chcp %lmess1% >nul
set co_is_utf8_foo=!co_is_utf8_foo:(={!
set co_is_utf8_foo=!co_is_utf8_foo:)=}!
set %~1=%co_is_utf8_foo%
exit /b

:@replace_meta
call set replace_meta_foo=%%%~1%%
set replace_meta_foo=%replace_meta_foo:(={%
set replace_meta_foo=%replace_meta_foo:)=}%
set %~1=%replace_meta_foo%
exit /b

:@check_name_strategy
call set check_name_strategy_foo=%%%~1%%
set /a fb=0
set /a sf=0
set /a ecode=0
for /L %%c in (0,1,1023) do (
	if !fb! equ 0 (
		if "x!check_name_strategy_foo:~%%c,1!"=="x)" set /a sf=1, fb=1
		if "x!check_name_strategy_foo:~%%c,1!"=="x(" set /a sf=1, fb=1
		if "x!check_name_strategy_foo:~%%c,1!"=="x" set /a fb=1
	)
)
if %sf% equ 1 set /a ecode=1
exit /b %ecode%

:random_hex
REM RFC 8446 for TLS 1.3, RFC 5246 for TLS 1.2, etc. to correctly encode the various fields:
REM Handshake Type: Client Hello (0x01)
REM Length: Length of the Client Hello message
REM Protocol Version: Supported TLS version (e.g., 0x0303 for TLS 1.2, 0x0304 for TLS 1.3)
REM Random: A 32-byte client-generated random value
REM Session ID: For session resumption
REM Cipher Suites: List of supported cipher suites, ordered by client preference
REM Compression Methods: List of supported compression methods
REM Extensions: Various extensions like Server Name Indication (SNI), Supported Groups, ALPN, etc.

REM ClientHello {
    REM Type (1) = 0x01,
    REM Length (3),

    REM LegacyVersion (2) = 0x0303,
    REM Random (32),

    REM # Устарело
    REM LegacySessionIdLength (1),
    REM LegacySessionId (LegacySessionIdLength),

    REM CipherSuitesLength (2),
    REM CipherSuites (CipherSuitesLength),
  
    REM # Устарело
    REM LegacyCompressionMethods(2) = 0x0100,
    
    REM ExtensionsLength (2),
    REM Extensions (ExtensionsLength),
REM }

REM https://habr.com/ru/companies/timeweb/articles/764260/
REM https://hackware.ru/?p=19139

if x%~1==x exit /b 1
if x%~2==x exit /b 2
set /a len=%~2
set /a dec=%~2
set "chars=0123456789ABCDEF"
for /L %%a in (1,1,8) do (
	set /a "d=dec&15,dec>>=4"
	for /f %%b in ("!d!") do set "lhstr=!chars:~%%b,1!!lhstr!"
	rem call set "lhstr=%%chars:~!d!,1%%!lhstr!"
)
rem for TLS 1.2
set "hex=0x010000000000%lhstr:~2%0303"
for /L %%a in (1,1,%len%) do (
	rem set /a rnd=(%RANDOM%*(max-min+1)/32768)+min
	set /a rnd=!RANDOM!*15 / 32768
	for /f %%b in ("!rnd!") do set "hex=!hex!!chars:~%%b,1!"
	rem for /L %%b in (!rnd!,1,!rnd!) do set "hex=!hex!!chars:~%%b,1!"
    rem call set "hex=!hex!%%chars:~!rnd!,1%%"
)
set %~1=%hex%
exit /b 0

:help
cls
echo.
echo.[5G[m%lmess192%
echo.
echo.[5G%lmess84%
pause >nul
goto:menu

:run_info
cls
echo.
echo.[5G[m%lmess225%: '[33m%homenc%\info.txt[m'
set "hoo="
for /f "delims=" %%a in ('2^>nul %_pwsh% -Command "Get-WmiObject win32_process -Filter 'name = \"cmd.exe\"' | select commandline" ^|find "run_agent.cmd"') do (
	echo %%a | find "powershell" ||(set hoo=%%a)
)
set foo=-
for /L %%c in (0,1,80) do set foo=!foo!-
set moo=#
for /L %%c in (0,1,80) do set moo=!moo!#
start "x" /min cmd /k "chcp 65001 &del /f /q %TEMP%\sc_srv.txt &(for /f "tokens=1* delims=:" %%a in ('powershell -command "Get-Service ^| Where-Object { $_.Status -eq \"Running\" } ^| Select-Object Name,DisplayName ^|Format-List -Property *"') do echo.%%b >>%TEMP%\sc_srv.txt) &exit"
start "x" /min cmd /k "chcp 65001 &del /f /q %TEMP%\sc_windivert.txt &(for /f "delims=" %%a in ('2^>nul powershell -command "Get-Service -Name \"windivert\" ^| Select-Object Name,Status ^|Format-List -Property *"') do echo.%%a >>%TEMP%\sc_windivert.txt) &exit"
start "x" /min cmd /k "chcp 65001 &del /f /q %TEMP%\sc_monkey.txt &(for /f "delims=" %%a in ('2^>nul powershell -command "Get-Service -Name \"monkey\" ^| Select-Object Name,Status ^|Format-List -Property *"') do echo.%%a >>%TEMP%\sc_monkey.txt) &exit"
timeout /T 2 >nul
(set LF=^
%=EMPTY=%
)
chcp 65001 >nul
(
<nul set /p =# UTF-8!LF!!LF!# INFO!LF!!LF!%moo%!LF!# [VAR]!LF!%moo%!LF!
echo.Home short   :[%home%]
echo.Home long    :[%homenc%]
echo.Home winws   :[%winwsdir%]
echo.Blockcheck   :[%zapret_win_bundle_master%]
echo.ARCH         :[%arch%]
echo.ARCHD        :[%archd%]
echo.ARCH SYS     :[%PROCESSOR_ARCHITECTURE%]
echo.Is Win7      :[%win_ver7%]
echo.Build        :[%b_ma%]
echo.Build minor  :[%b_mi%]
echo.OS           :[%os_name%]
echo.OSLanguage   :[%OSLanguage%]
echo.Pwsh 5       :[%_pwsh%]
echo.Pwsh 7       :[%_pwsh_7%]
REM echo.
<nul set /p =!LF!%moo%!LF!# [LS %winwsdir%]!LF!%moo%!LF!
dir /b %winwsdir%
<nul set /p =!LF!%moo%!LF!# [TASK AGENT]!LF!%moo%!LF!
1>nul 2>nul schtasks /Query /TN dpiagent &&(schtasks /Query /TN dpiagent /FO LIST /V)
<nul set /p =!LF!%moo%!LF!# [CMD AGENT]!LF!%moo%!LF!
echo.%hoo%
<nul set /p =!LF!%moo%!LF!# [CONFIG]!LF!%moo%!LF!
type %home%\run.config
<nul set /p =!LF!%moo%!LF!# [DNS]!LF!%moo%!LF!
netsh interface ipv4 show interfaces
netsh interface ipv4 show dnsservers
>nul 2>&1 netsh dnsclient &&(
<nul set /p =%foo%!LF!netsh dnsclient show encryption!LF!%foo%!LF!
netsh dnsclient show encryption
<nul set /p =%foo%!LF!netsh dnsclient show global!LF!%foo%!LF!
netsh dnsclient show global
echo.%foo%
)||(
>nul 2>&1 netsh dns &&(
<nul set /p =%foo%!LF!netsh dns show encryption!LF!%foo%!LF!
netsh dns show encryption
<nul set /p =%foo%!LF!netsh dns show global!LF!%foo%!LF!
netsh dns show global
echo.%foo%
))
<nul set /p =!LF!%moo%!LF!# [SERVICE ACTIVE]!LF!%moo%!LF!
set /a coo=0
for /f "delims=" %%a in (%TEMP%\sc_srv.txt) do (
	if !coo! equ 0 set hoo=[%%a ]
	if !coo! equ 1 (
		set hoo=!hoo!: %%a
		set /a coo=0
		set /a coo-=1
		echo.!hoo!
	)
	set /a coo+=1
)
<nul set /p =!LF!%moo%!LF!# [DRIVER ACTIVE]!LF!
if exist %TEMP%\sc_windivert.txt type %TEMP%\sc_windivert.txt
if exist %TEMP%\sc_monkey.txt type %TEMP%\sc_monkey.txt
<nul set /p =!LF!%moo%!LF!# [ADGUARD]!LF!%moo%!LF!
tasklist /svc | find "AdguardSvc"
<nul set /p =!LF!%moo%!LF!# [KILLER]!LF!%moo%!LF!
type %TEMP%\sc_srv.txt | find "Killer"
<nul set /p =!LF!%moo%!LF!# [CHECK POINT]!LF!%moo%!LF!
type %TEMP%\sc_srv.txt | find "TracSrvWrapper"
type %TEMP%\sc_srv.txt | find "EPWD"
<nul set /p =!LF!%moo%!LF!# [SMARTBYTE]!LF!%moo%!LF!
type %TEMP%\sc_srv.txt | find "SmartByte"
<nul set /p =!LF!%moo%!LF!# [VPN]!LF!%moo%!LF!
type %TEMP%\sc_srv.txt | find "VPN"
echo.
set "hoo="
if defined strategy_run (
	set "hoo=%strategy_run%"
	set "goo=RUN"
)
if defined strategy_run_failure (
	set "hoo=%strategy_run_failure%"
	set "goo=FAILURE"
)
if defined hoo (
	<nul set /p =%moo%!LF!# [STRATEGY !goo!:!hoo!]!LF!%moo%!LF!
	for /f "delims=" %%c in ('2^>nul dir /b %home%\strategy\"!hoo!"\*.strategy') do (
		<nul set /p =%foo%!LF!  [%%c]!LF!%foo%!LF!
		type %home%\strategy\"!hoo!"\%%c
	)
	<nul set /p =%moo%!LF!# [STRATEGY !goo!:%strategy_run%\custom]!LF!%moo%!LF!
	for /f "delims=" %%c in ('2^>nul dir /b %home%\strategy\"!hoo!"\custom\*.strategy') do (
		<nul set /p =%foo%!LF!  [%%c]!LF!%foo%!LF!
		type %home%\strategy\"!hoo!"\custom\%%c
	)
	<nul set /p =%moo%!LF!# [STRATEGY !goo!:CMD]!LF!%moo%!LF!
	for /f "delims=" %%c in ('2^>nul dir /b %home%\strategy\"!hoo!"\log\*.example') do (
		<nul set /p =%foo%!LF!  [%%c]!LF!%foo%!LF!
		type %home%\strategy\"!hoo!"\log\%%c
	)
	<nul set /p =%moo%!LF!# [STRATEGY !goo!:ERRORS]!LF!%moo%!LF!
	for /f "delims=" %%c in ('2^>nul dir /b %home%\strategy\"!hoo!"\log\*-dry-run-status-err.log %home%\strategy\"!hoo!"\log\*-run-status-err.log') do (
		<nul set /p =%foo%!LF!  [%%c]!LF!%foo%!LF!
		type %home%\strategy\"!hoo!"\log\%%c
	)
	<nul set /p =%moo%!LF!# [STRATEGY !goo!:END]!LF!%moo%!LF!!LF!
)
echo.# INFO END
)>%home%\info.txt
if exist %TEMP%\sc_srv.txt del /f /q %TEMP%\sc_srv.txt
if exist %TEMP%\sc_windivert.txt del /f /q %TEMP%\sc_windivert.txt
if exist %TEMP%\sc_monkey.txt del /f /q %TEMP%\sc_monkey.txt
chcp %lmess1% >nul
echo.[5G[32m%lmess89%[m
echo.
for /l %%x in (3,-1,1) do (
	echo.[F
	<nul set /p =[2K[5G[m%lmess87% [32m%%x[m %lmess88%[?25l
	timeout /T 1 /NOBREAK >nul
)
goto:menu

:eula_
if defined arg_1 exit /b 0
cls
echo.
<nul set /p =[2;5H
call:@stix_bat "%lmess230%"
echo.
<nul set /p =[5G
choice /N /C:%lmess507%%lmess508% /D %lmess507:~0,1% /T 300 /M "%lmess19% (%lmess508:~0,1%|%lmess507:~0,1%): "
if %errorlevel% neq 255 if %errorlevel% neq 0 if %errorlevel% gtr %lmess507_size% exit /b 0
exit /b 1

:@stix_bat
rem stix "text"
rem stix "BS" 5
if "x%~1"=="xBS" (
	<nul set /p "= "
	set /a "stix_1_count=%~2"
	set /a "stix_1_count-=1"
	for /L %%a in (1,1,!stix_1_count!) do (
		<nul set /p "= "
	)
 	<nul set /p "="
	exit /b
)
set "stix_var=%~1"
if not defined stix_var exit /b 1
:@stix_bat_loop
set "stix_var_1=%stix_var:~0,1%"
set "stix_var_2=%stix_var:~1,1%"
set "stix_var=%stix_var:~1%"
if "x%stix_var_2%"=="x " set "stix_var=%stix_var:~1%"
if "x%stix_var_2%"=="x " (
	<nul set /p "=%stix_var_1% "
	for /L %%a in (1,1,10) do ping localhost -n 1 >nul
) else ( 
	<nul set /p =%stix_var_1%
	for /L %%a in (1,1,10) do ping localhost -n 1 >nul
)
if not "x%stix_var%"=="x" goto:@stix_bat_loop
echo.
exit /b 0

:@get_file
call set get_file_foo=%%%~1%%
set /a get_file_count=0
for /L %%c in (1024,-1,0) do (
	if "x!get_file_foo:~%%c,1!"=="x\" (
		set /a get_file_count=%%c+1
		goto:@F
	)
	if "x!get_file_foo:~%%c,1!"=="x/" (
		set /a get_file_count=%%c+1
		goto:@F
	)
)
:@F
if %get_file_count% equ 0 exit /b 1
set %~1=!get_file_foo:~%get_file_count%!
exit /b 0

:find_strategy_create_cfg
if exist %home%\find-strategy-config.txt exit /b
rem https://github.com/bol-van/zapret?tab=readme-ov-file#проверка-провайдера
set hoo=%home%
if defined bin_curl set hoo=%bin_curl%
set hoo=%hoo:\=/%
curl -V 1>nul 2>&1 &&(set CURLb=# CURL=curl)||(if exist %bin_curl%\curl.exe set CURLb=CURL=%hoo%/curl.exe)
(set LF=^
%=EMPTY=%
)
set foo=-
for /L %%c in (0,1,80) do set foo=!foo!-
set /a cstr= 0 &set bstr%cstr%=#
set /a cstr+=1 &set bstr%cstr%=# %lmess193%
set /a cstr+=1 &set bstr%cstr%=# %lmess194%: C:/folder/who/curl.exe
set /a cstr+=1 &set bstr%cstr%=# %lmess195%
set /a cstr+=1 &set bstr%cstr%=# %lmess196%
set /a cstr+=1 &set bstr%cstr%=# %lmess197%
set /a cstr+=1 &set bstr%cstr%=# %lmess198%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# STRATEGY_LIST_NAME - %lmess229% ..\strategy\*.lst
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=STRATEGY_LIST_NAME=strategy
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# CURL - %lmess199%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# CURL=curl
set /a cstr+=1 &set bstr%cstr%=# CURL=%hoo%/curl.exe
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=%CURLb%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=# CURL_OPT - %lmess200%
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# CURL_OPT=-k
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=# CURL_MAX_TIME - %lmess201%
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# CURL_MAX_TIME=2
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=# SCANLEVEL=quick^|standard^|force - %lmess202%
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=SCANLEVEL=standard
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=# REPEATS - %lmess203%
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=REPEATS=4
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=# DOMAINS - %lmess204%
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=DOMAINS=rutracker.org x.com discord.com 
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=# HTTP_PORT, HTTPS_PORT, QUIC_PORT - %lmess205%
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=#      HTTP
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# ENABLE_HTTP=0^|1 - %lmess206% plain http
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# ENABLE_HTTP=1
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# HTTP_PORT=80
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=#      HTTPS
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# ENABLE_HTTPS_TLS12=0^|1 - %lmess206% https TLS 1.2
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=ENABLE_HTTPS_TLS12=1
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# ENABLE_HTTPS_TLS13=0^|1 - %lmess206% https TLS 1.3
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# ENABLE_HTTPS_TLS13=0
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=HTTPS_PORT=443
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=#      HTTP3 / QUIC
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# ENABLE_HTTP3=0^|1 - %lmess206% QUIC
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# ENABLE_HTTP3=1
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# QUIC_PORT=443
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# %foo%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# PARALLEL=0^|1 - %lmess207%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=PARALLEL=0
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# CURL_MAX_TIME_QUIC - %lmess208%
set /a cstr+=1 &set bstr%cstr%=# CURL_MAX_TIME_DOH - %lmess209%
set /a cstr+=1 &set bstr%cstr%=# CURL_CMD=1 - %lmess210%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# IPVS=4^|6^|46 - %lmess211%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=IPVS=4
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# BATCH=1 - %lmess212%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=BATCH=1
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# SKIP_DNSCHECK=1 - %lmess213%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=SKIP_DNSCHECK=0
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# SKIP_IPBLOCK=1 - %lmess214%
set /a cstr+=1 &set bstr%cstr%=# SKIP_TPWS=1 - %lmess215%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=SKIP_TPWS=0
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# SKIP_PKTWS=1 - %lmess216%
set /a cstr+=1 &set bstr%cstr%=# PKTWS_EXTRA, TPWS_EXTRA - %lmess217%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# PKTWS_EXTRA=--dpi-desync-autottl=2
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=PKTWS_EXTRA=
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# PKTWS_EXTRA_1 .. PKTWS_EXTRA_9, TPWS_EXTRA_1 .. TPWS_EXTRA_9 - %lmess218%
set /a cstr+=1 &set bstr%cstr%=# PKTWS_EXTRA_PRE - %lmess219%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=PKTWS_EXTRA_PRE=
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# PKTWS_EXTRA_PRE_1 .. PKTWS_EXTRA_PRE_9 - %lmess220%
set /a cstr+=1 &set bstr%cstr%=# SECURE_DNS=0^|1 - %lmess221%
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=SECURE_DNS=1
set /a cstr+=1 &set bstr%cstr%=
set /a cstr+=1 &set bstr%cstr%=# DOH_SERVERS - %lmess222%
set /a cstr+=1 &set bstr%cstr%=# DOH_SERVER - %lmess223%
set /a cstr+=1 &set bstr%cstr%=# UNBLOCKED_DOM - %lmess224%
chcp 65001 >nul
for /L %%c in (0,1,%cstr%) do (
	if not "x!bstr%%c!"=="x" <nul set /p =!bstr%%c!!LF!>>%home%\find-strategy-config.txt
	if "x!bstr%%c!"=="x" echo.>>%home%\find-strategy-config.txt
)
chcp %lmess1% >nul
exit /b