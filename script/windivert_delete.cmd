@echo off

echo DELETE WINDIVERT DRIVER
sc qc windivert
if "x%errorlevel%"=="x0" (
	sc stop windivert
	sc delete windivert
)
pause
