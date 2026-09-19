@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PORT=8080"

rem Profilo browser dedicato al totem: fondamentale perche' se Chrome/Edge
rem e' gia' aperto con il profilo normale, il comando qui sotto aprirebbe
rem solo una scheda nella finestra esistente e i flag (--kiosk compreso)
rem verrebbero ignorati.
set "KIOSK_PROFILE=%LOCALAPPDATA%\SEIMuseumKiosk\browser-profile"

rem Avvia il server locale in background, senza nessuna finestra visibile
start "" /b powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%SCRIPT_DIR%serve.ps1" -Port %PORT%

rem Aspetta che il server risponda davvero (max ~15 secondi)
powershell -NoProfile -Command "$u='http://localhost:%PORT%/'; for($i=0;$i -lt 30;$i++){ try{ (New-Object Net.WebClient).DownloadString($u) | Out-Null; exit 0 } catch { Start-Sleep -Milliseconds 500 } }; exit 1"

set "BROWSER="
set "BROWSER_KIND="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
    set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
    set "BROWSER_KIND=chrome"
)
if not defined BROWSER if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
    set "BROWSER_KIND=chrome"
)
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_KIND=edge"
)
if not defined BROWSER if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" (
    set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
    set "BROWSER_KIND=edge"
)

if not defined BROWSER (
    echo Non trovo Chrome ne' Edge nei percorsi standard.
    echo Apri manualmente il browser su http://localhost:%PORT%/
    pause
    exit /b 1
)

set "COMMON_FLAGS=--no-first-run --no-default-browser-check --disable-session-crashed-bubble --disable-infobars --disable-features=TranslateUI --autoplay-policy=no-user-gesture-required --user-data-dir=%KIOSK_PROFILE%"

if "%BROWSER_KIND%"=="edge" (
    rem Edge: l'URL deve stare subito dopo --kiosk, altrimenti il kiosk non parte.
    start "" "%BROWSER%" --kiosk "http://localhost:%PORT%/" --edge-kiosk-type=fullscreen --no-first-run %COMMON_FLAGS%
) else (
    start "" "%BROWSER%" --kiosk --start-fullscreen %COMMON_FLAGS% "http://localhost:%PORT%/"
)
