# Apertura di saline.exe dalla card "La vita in Salina"

Un browser non può lanciare un .exe locale direttamente per motivi di sicurezza. La card sul sito ora punta a un link con protocollo custom `salina-app://launch`, che va registrato una volta sul PC Windows del museo perché apra `saline.exe`.

## Setup (una tantum, sul PC del museo)

1. Copia questa cartella `windows-launcher` nella stessa cartella che contiene `app_deploy` (quindi `app_deploy\WindowsNoEditor\saline.exe` deve trovarsi allo stesso livello, es. `.../app_deploy/WindowsNoEditor/saline.exe`).
2. Fai doppio clic su `register-salina-protocol.bat`. Non servono permessi di amministratore (scrive solo in HKEY_CURRENT_USER).
3. Da questo momento in poi, cliccando la card sul sito, il browser proporrà di aprire "Salina App Protocol" con `saline.exe`.

Per rimuovere la registrazione: esegui `unregister-salina-protocol.bat`.

## Nota sul popup di conferma del browser

Chrome/Edge, al primo utilizzo di un protocollo custom, mostrano un popup "Apri Salina App?" con una checkbox "Ricorda la mia scelta per i link salina-app". Se la si spunta, i click successivi apriranno l'app senza chiedere di nuovo.

Se invece il sito gira in modalità kiosk e si vuole evitare del tutto il popup, si può whitelistare il protocollo via policy aziendale Chrome/Edge (richiede diritti di amministratore sul PC):

- Chrome: policy `AutoLaunchProtocolsFromOrigins`
- Edge: stessa policy, prefisso `edge://policy`

Configurazione (registry, HKLM, richiede admin):

```
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\AutoLaunchProtocolsFromOrigins]
"1"="{\"protocol\":\"salina-app\",\"allowed_origins\":[\"https://<dominio-del-sito>\"]}"
```

(per Edge: `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\AutoLaunchProtocolsFromOrigins`, sostituendo `<dominio-del-sito>` con l'origine reale da cui viene servito il sito, es. il dominio GitHub Pages o il dominio custom).

Questo passaggio è opzionale: senza policy, la card funziona comunque, solo con un popup di conferma la prima volta.
