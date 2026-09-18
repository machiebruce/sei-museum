@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PORT=8080"

rem Avvia il server locale in background (finestra minimizzata)
start "SEI Museum - server locale" /min powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%serve.ps1" -Port %PORT%

rem Aspetta che il server sia pronto
timeout /t 2 /nobreak >nul

set "BROWSER="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"

if not defined BROWSER (
    echo Non trovo Chrome ne' Edge nei percorsi standard.
    echo Apri manualmente il browser su http://localhost:%PORT%/
    pause
    exit /b 1
)

start "" "%BROWSER%" --kiosk --edge-kiosk-type=fullscreen --no-first-run --disable-session-crashed-bubble --disable-infobars --autoplay-policy=no-user-gesture-required "http://localhost:%PORT%/"
