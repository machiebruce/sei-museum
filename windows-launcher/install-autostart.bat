@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT=%STARTUP%\SEI-Museum-Kiosk.lnk"

rem Il collegamento punta al wrapper .vbs: avvia il .bat senza aprire
rem nessuna finestra di console sul totem.
powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%SystemRoot%\System32\wscript.exe'; $s.Arguments=[char]34+'%SCRIPT_DIR%start-kiosk.vbs'+[char]34; $s.WorkingDirectory='%SCRIPT_DIR%'; $s.WindowStyle=7; $s.Save()"

if exist "%SHORTCUT%" (
    echo Avvio automatico configurato: il totem partira' da solo al login di Windows.
) else (
    echo Qualcosa e' andato storto, il collegamento non e' stato creato.
)
pause
