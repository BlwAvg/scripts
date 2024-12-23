@echo off
:: Check for Administrative Privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrative privileges.
) else (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

:: Logging output for easy review
set LOGFILE=%~dp0Maintenance_Log.txt

:: Add timestamp function
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set DATE=%%c-%%a-%%b
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME=%%a-%%b
set TIMESTAMP=%DATE%_%TIME%
echo Log Start Time: %TIMESTAMP% > %LOGFILE%

:: Run System File Checker
echo [%TIMESTAMP%] Running System File Checker (sfc /scannow)... >> %LOGFILE%
sfc /scannow >> %LOGFILE%
echo [%TIMESTAMP%] sfc /scannow completed. >> %LOGFILE%

:: Check Health using DISM
echo [%TIMESTAMP%] Checking health with DISM /CheckHealth... >> %LOGFILE%
DISM /Online /Cleanup-Image /CheckHealth >> %LOGFILE%
echo [%TIMESTAMP%] DISM /CheckHealth completed. >> %LOGFILE%

:: Scan Health using DISM
echo [%TIMESTAMP%] Scanning health with DISM /ScanHealth... >> %LOGFILE%
DISM /Online /Cleanup-Image /ScanHealth >> %LOGFILE%
echo [%TIMESTAMP%] DISM /ScanHealth completed. >> %LOGFILE%

:: Restore Health using DISM
echo [%TIMESTAMP%] Restoring health with DISM /RestoreHealth... >> %LOGFILE%
DISM /Online /Cleanup-Image /RestoreHealth >> %LOGFILE%
echo [%TIMESTAMP%] DISM /RestoreHealth completed. >> %LOGFILE%

:: Start Component Cleanup using DISM
echo [%TIMESTAMP%] Cleaning up components with DISM /StartComponentCleanup... >> %LOGFILE%
DISM.exe /online /cleanup-image /startcomponentcleanup >> %LOGFILE%
echo [%TIMESTAMP%] DISM /StartComponentCleanup completed. >> %LOGFILE%

:: Notify user
echo [%TIMESTAMP%] Maintenance completed. Check %LOGFILE% for details.

timeout /t 5
exit
