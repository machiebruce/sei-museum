@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PIDFILE=%SCRIPT_DIR%serve.pid"

if exist "%PIDFILE%" (
    set /p SERVER_PID=<"%PIDFILE%"
    taskkill /F /PID !SERVER_PID! >nul 2>&1
    del "%PIDFILE%" >nul 2>&1
)

taskkill /F /IM chrome.exe >nul 2>&1
taskkill /F /IM msedge.exe >nul 2>&1

echo Kiosk fermato.
pause
