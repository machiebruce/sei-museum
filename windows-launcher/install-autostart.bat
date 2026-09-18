@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT=%STARTUP%\SEI-Museum-Kiosk.lnk"

powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%SCRIPT_DIR%start-kiosk.bat'; $s.WorkingDirectory='%SCRIPT_DIR%'; $s.WindowStyle=7; $s.Save()"

if exist "%SHORTCUT%" (
    echo Avvio automatico configurato: il totem partira' da solo al login di Windows.
) else (
    echo Qualcosa e' andato storto, il collegamento non e' stato creato.
)
pause
