REM :: DIAGNOSTICS =========================
@echo off
setlocal EnableDelayedExpansion
chcp 1251 > nul
cls

REM :: AdguardSvc.exe
tasklist /FI "IMAGENAME eq AdguardSvc.exe" | find /I "AdguardSvc.exe" > nul
if !errorlevel!==0 (
    echo.[31m[x][0m[8GОбнаружен процесс 'Adguard'. 'Adguard' может вызывать проблемы с 'Discord'.
    echo.[8Ghttps://github.com/Flowseal/zapret-discord-youtube/issues/417
) else (
    echo.[[32mok[0m][8GПроверка 'Adguard' пройдена
)

REM :: Killer
sc query | findstr /I "Killer" > nul
if !errorlevel!==0 (
    echo.[31m[x][0m[8GНайдены сервисы 'Killer'. Конфликты с zapret.
    echo.[8Ghttps://github.com/Flowseal/zapret-discord-youtube/issues/2512#issuecomment-2821119513
) else (
    echo.[[32mok[0m][8GПроверка 'Killer' пройдена
)

REM :: Check Point
set "checkpointFound=0"
sc query | findstr /I "TracSrvWrapper" > nul
if !errorlevel!==0 (
    set "checkpointFound=1"
)

sc query | findstr /I "EPWD" > nul
if !errorlevel!==0 (
    set "checkpointFound=1"
)

if !checkpointFound!==1 (
    echo.[31m[x][0m[8GНайдены службы 'Check Point'. 'Check Point' конфликтует с Zapret.
    echo.[8GПопробуйте удалить Check Point
) else (
    echo.[[32mok[0m][8GПроверка 'Check Point' пройдена
)

REM :: SmartByte
sc query | findstr /I "SmartByte" > nul
if !errorlevel!==0 (
    echo.[31m[x][0m[8GНайдены службы 'SmartByte'. SmartByte конфликтует с Zapret.
    echo.[8GПопробуйте удалить или отключить 'SmartByte' через 'services.msc'.
) else (
    echo.[[32mok[0m][8GПроверка 'SmartByte' пройдена
)

REM :: VPN
sc query | findstr /I "VPN" > nul
if !errorlevel!==0 (
    echo.[33m[?][0m[8GНайдены некоторые VPN-сервисы. Некоторые VPN могут конфликтовать с Zapret.
    echo.[8GУбедитесь, что все VPN отключены.
) else (
    echo.[[32mok[0m][8GПроверка VPN пройдена
)

REM :: DNS
set "ServerAddresses="
set "InterfaceAliasOk="
set dnsfound=0
for /f %%a in ('2^>nul nslookup iana.org ^| find "192.0.43.8"') do set dnsfound=1
if %dnsfound% equ 0 (
	for /f "skip=3 tokens=*" %%a in ('2^>nul powershell -Command "get-netadapter | Select-Object Name"') do (
		set "InterfaceAlias=%%a"
		set foo=255
		for /L %%i in (255,-1,0) do (
			if "x!InterfaceAlias:~%%i,1!"=="x" set /a foo-=1
		)
		set count=0
		for /L %%i in (!foo!,-1,0) do (
			if !count! equ 0 if not "x!InterfaceAlias:~%%i,1!"=="x " (
				set foo=%%i
				set /a foo+=1
				set count=1
			)
		)
		for /L %%i in (0,1,!foo!) do (
			if %%i equ !foo! set "InterfaceAlias=!InterfaceAlias:~0,%%i!"
		)	
			
		for /f "skip=3 tokens=*" %%b in ('2^>nul powershell -Command "get-netadapter -Name \"!InterfaceAlias!\" | Select-Object Status"') do (
			set Status=%%b
			set foo=255
			for /L %%i in (255,-1,0) do (
				if "x!Status:~%%i,1!"=="x" set /a foo-=1
			)
			set count=0
			for /L %%i in (!foo!,-1,0) do (
				if !count! equ 0 if not "x!Status:~%%i,1!"=="x " (
					set foo=%%i
					set /a foo+=1
					set count=1
				)
			)
			for /L %%i in (0,1,!foo!) do (
				if %%i equ !foo! set "Status=!Status:~0,%%i!"
			)	
			if "x!Status!"=="xUp" (
				for /f "skip=3 tokens=1 delims={}" %%c in ('2^>nul powershell -Command "Get-DnsClientServerAddress -InterfaceAlias \"!InterfaceAlias!\" -AddressFamily \"IPv4\" | Select-Object ServerAddresses"') do (
					set "ServerAddresses=%%c"
					set InterfaceAliasOk=!InterfaceAlias!
				)
			)
		)
	)
)
if %dnsfound% equ 0 (
	if defined ServerAddresses (
		set "foo="
		for /f "tokens=1 delims=," %%i in ("!ServerAddresses!") do set foo=%%i
		if not "x!foo!"=="x" (
			set foo=!foo: =!
			set "ServerAddressPri=!foo!"
			for /f %%a in ('2^>nul nslookup iana.org !foo! ^| find "192.0.43.8"') do set dnsfound=1
			if !dnsfound! equ 0 (
				echo.[31m[x][0m[8GОсновной DNS-сервер [!ServerAddressPri!] не подходит для работы скрипта.
				echo.[8GРекомендуется установить известные DNS-серверы и настроить DoH. 
				rem netsh interface ipv4 set dns name=%InterfaceAliasOk% static 1.1.1.1 primary
				set "foo="
				for /f "tokens=2 delims=," %%i in ("!ServerAddresses!") do set foo=%%i
				if not "x!foo!"=="x" (
					set foo=!foo: =!
					set "ServerAddressSec=!foo!"
					for /f %%a in ('2^>nul nslookup iana.org !foo! ^| find "192.0.43.8"') do set dnsfound=1
					if !dnsfound! equ 0 (
						echo.[31m[x][0m[8GРезервный DNS-сервер [!ServerAddressSec!] не подходит для работы скрипта.
						echo.[8GРекомендуется установить известные DNS-серверы и настроить DoH. 
					)
				)
			)
		)
	)
)
if %dnsfound% equ 1 (
    echo.[[32mok[0m][8GПроверка DNS пройдена
) else (
	echo.[31m[x][0m[8GDNS-серверы не указаны.
	echo.[8GРекомендуется установить известные DNS-серверы и настроить DoH. 
)
echo.
REM :: Discord cache clearing
choice /C YN /D Y /T 5 /M "Хотите очистить кэш Discord? "
if %errorlevel% equ 255 exit
if %errorlevel% equ 0 exit
if %errorlevel% equ 1 (
	echo.
	tasklist /FI "IMAGENAME eq Discord.exe" | findstr /I "Discord.exe" > nul
    if !errorlevel!==0 (
        echo [33m[8GDiscord запущен, закрывается...[0m
        taskkill /F /IM Discord.exe> nul
        if !errorlevel! == 0 (
            echo.[[32mok[0m][32m[8GDiscord был успешно закрыт[0m
        ) else (
            echo.[31m[x][8GНевозможно закрыть Discord[0m
        )
    )

    set "discordCacheDir=%appdata%\discord"

    for %%d in ("Cache" "Code Cache" "GPUCache") do (
        set "dirPath=!discordCacheDir!\%%~d"
        if exist "!dirPath!" (
            rd /s /q "!dirPath!" 1>nul 2>nul
            if !errorlevel!==0 (
                echo.[[32mok[0m][32m[8GУспешно удалено[0m !dirPath!
            ) else (
                echo.[31m[x][0m[8GНе удалось удалить[0m !dirPath!
            )
        ) else (
            echo.[33m[i][0m[8G!dirPath! [33mуже и так пустой[0m
        )
    )
	echo.
)
echo.[8GНажмите любую клавишу для выхода.
pause >nul
for /l %%x in (5,-1,1) do (
	echo.[F
	<nul set /p =[8G[37mВыход через [32m%%x[37m с.[0m
	timeout /T 1 /NOBREAK >nul
)
exit
