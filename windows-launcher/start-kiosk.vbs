' Lancia start-kiosk.bat senza mostrare nessuna finestra.
' Serve perche' un .bat avviato direttamente apre sempre una console cmd,
' che sul totem resterebbe visibile dietro al browser.
Dim shell, fso, here
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
here = fso.GetParentFolderName(WScript.ScriptFullName)
' 0 = finestra nascosta, False = non aspettare la fine
shell.Run """" & here & "\start-kiosk.bat""", 0, False
