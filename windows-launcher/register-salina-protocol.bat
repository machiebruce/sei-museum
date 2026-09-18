@echo off
setlocal

rem Deve stare nella stessa cartella che contiene "app_deploy\WindowsNoEditor\saline.exe"
set "APP_DIR=%~dp0"
set "APP_EXE=%APP_DIR%app_deploy\WindowsNoEditor\saline.exe"

if not exist "%APP_EXE%" (
    echo ERRORE: non trovo saline.exe in "%APP_EXE%"
    echo Sposta questo file .bat nella cartella che contiene "app_deploy", poi riprova.
    pause
    exit /b 1
)

reg add "HKCU\Software\Classes\salina-app" /ve /d "URL:Salina App Protocol" /f >nul
reg add "HKCU\Software\Classes\salina-app" /v "URL Protocol" /d "" /f >nul
reg add "HKCU\Software\Classes\salina-app\shell\open\command" /ve /d "\"%APP_EXE%\"" /f >nul

echo.
echo Protocollo salina-app:// registrato con successo per l'utente corrente.
echo Eseguibile collegato: %APP_EXE%
echo.
pause
