@echo off
set "SHORTCUT=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\SEI-Museum-Kiosk.lnk"
if exist "%SHORTCUT%" (
    del "%SHORTCUT%"
    echo Avvio automatico rimosso.
) else (
    echo Non risulta configurato alcun avvio automatico.
)
pause
