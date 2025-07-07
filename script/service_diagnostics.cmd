REM :: DIAGNOSTICS =========================
@echo off
setlocal EnableDelayedExpansion
chcp 437 > nul
cls

REM :: AdguardSvc.exe
tasklist /FI "IMAGENAME eq AdguardSvc.exe" | find /I "AdguardSvc.exe" > nul
if !errorlevel!==0 (
    echo.[31m[x][0m Adguard process found. Adguard may cause problems with Discord
    echo.https://github.com/Flowseal/zapret-discord-youtube/issues/417
) else (
    echo.[[32mok[0m] Adguard check passed
)

REM :: Killer
sc query | findstr /I "Killer" > nul
if !errorlevel!==0 (
    echo.[31m[x][0m Killer services found. Killer conflicts with zapret
    echo.    https://github.com/Flowseal/zapret-discord-youtube/issues/2512#issuecomment-2821119513
) else (
    echo.[[32mok[0m] Killer check passed
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
    echo.[31m[x][0m Check Point services found. Check Point conflicts with zapret
    echo.    Try to uninstall Check Point
) else (
    echo.[[32mok[0m] Check Point check passed
)

REM :: SmartByte
sc query | findstr /I "SmartByte" > nul
if !errorlevel!==0 (
    echo.[31m[x][0m SmartByte services found. SmartByte conflicts with zapret
    echo.    Try to uninstall or disable SmartByte through services.msc
) else (
    echo.[[32mok[0m] SmartByte check passed[0m
)

REM :: VPN
sc query | findstr /I "VPN" > nul
if !errorlevel!==0 (
    echo.[33m[?][0m Some VPN services found. Some VPNs can conflict with zapret
    echo.    Make sure that all VPNs are disabled
) else (
    echo.[[32mok[0m] VPN check passed
)

REM :: DNS
set "dnsfound=0"
for /f "skip=1 tokens=*" %%a in ('wmic nicconfig where "IPEnabled=true" get DNSServerSearchOrder /format:table') do (
    echo %%a | findstr /i "192.168." >nul
    if !errorlevel!==0 (
        set "dnsfound=1"
    )
)
if !dnsfound!==1 (
    echo.[33m[?][0m DNS servers are probably not specified.
    echo.    Provider's DNS servers are automatically used, which may affect zapret.
	echo.    It is recommended to install well-known DNS servers and setup DoH
) else (
    echo.[[32mok[0m] DNS check passed
)

REM :: Discord cache clearing
choice /C YN /D Y /T 5 /M "Do you want to clear the Discord cache? "
if %errorlevel% equ 255 exit /b 1
if %errorlevel% equ 0 exit /b 1
set "CHOICE=%errorlevel%"

if /i "!CHOICE!" equ "1" (
    tasklist /FI "IMAGENAME eq Discord.exe" | findstr /I "Discord.exe" > nul
    if !errorlevel!==0 (
        echo [31mDiscord is running, closing...[0m
        taskkill /F /IM Discord.exe> nul
        if !errorlevel! == 0 (
            echo.[32mDiscord was successfully closed[0m
        ) else (
            echo.[31mUnable to close Discord[0m
        )
    )

    set "discordCacheDir=%appdata%\discord"

    for %%d in ("Cache" "Code Cache" "GPUCache") do (
        set "dirPath=!discordCacheDir!\%%~d"
        if exist "!dirPath!" (
            rd /s /q "!dirPath!"
            if !errorlevel!==0 (
                echo.[32mSuccessfully deleted[0m !dirPath!
            ) else (
                echo.[31mFailed to delete[0m !dirPath!
            )
        ) else (
            echo.!dirPath! [31mdoes not exist[0m
        )
    )
)
timeout /T 10 /NOBREAK
exit /b 0
