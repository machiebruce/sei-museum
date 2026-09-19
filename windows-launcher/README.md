# Pacchetto per il PC Windows del museo (totem)

Questa cartella contiene tutto il necessario per far girare il sito SEI Museum
in locale su Windows, a schermo intero, e per aprire `saline.exe` dalla card
"La vita in Salina" del sito.

## Struttura attesa sul PC Windows

Copia il **contenuto** di questa cartella (`windows-launcher/`) nella stessa
cartella dove metterai anche `dist/` (la build del sito) e `app_deploy/`
(l'app Unreal). Il risultato finale su Windows deve essere:

```
sei-museum-kiosk/              <- cartella a tua scelta
├── dist/                      <- build del sito: risultato di "npm run build"
├── app_deploy/
│   └── WindowsNoEditor/
│       └── saline.exe
├── serve.ps1
├── start-kiosk.bat
├── start-kiosk.vbs            <- avvia il kiosk senza finestre visibili
├── stop-kiosk.bat
├── install-autostart.bat
├── uninstall-autostart.bat
├── register-salina-protocol.bat
├── unregister-salina-protocol.bat
└── README.md                  <- questo file
```

`dist/` non e' inclusa in questo pacchetto: va rigenerata con `npm run build`
(dalla cartella del progetto) e copiata qui ogni volta che il sito viene
aggiornato.

## Perche' serve un server e non basta aprire l'HTML

Il sito usa script "ES module" (`<script type="module">`) su quasi tutte le
pagine (menu, animazioni, video, timer di inattivita'...). I browser
bloccano il caricamento di questi script se la pagina viene aperta come file
locale (`file://...`, doppio click sull'HTML) per motivi di sicurezza: menu e
animazioni sembrerebbero "rotti" o assenti. `serve.ps1` risolve il problema
servendo i file su `http://localhost:8080/`, che il browser tratta come un
sito web normale.

`serve.ps1` usa solo PowerShell, gia' presente su ogni Windows: non serve
installare Node, Python o altro.

Gestisce le richieste in parallelo (pool di thread): una pagina carica
CSS/JS/immagini con piu' richieste contemporanee, e i video pesano
10-20MB. Se il server processasse una richiesta alla volta, tutte le
altre resterebbero in coda dietro al file piu' pesante; se nel frattempo
il browser si stanca di aspettare e chiude la connessione, la scrittura
fallisce con l'errore Windows "il nome di rete specificato non e' piu'
disponibile" — sito lento o pagine che non rispondono, solo sul PC
Windows (Mac/GitHub Pages non hanno questo limite perche' servono le
richieste in parallelo).

## Setup (una tantum, sul PC del museo)

1. Copia qui `app_deploy/WindowsNoEditor/saline.exe` e la `dist/` del sito,
   secondo la struttura sopra.
2. Fai doppio clic su `register-salina-protocol.bat` (registra il link
   `salina-app://` verso `saline.exe` — vedi sotto per i dettagli).
3. Fai doppio clic su `start-kiosk.bat` per provare: apre il browser a
   schermo intero su `http://localhost:8080/`. Premi `Alt+F4` per uscire dal
   kiosk durante i test.
4. Quando sei soddisfatto, fai doppio clic su `install-autostart.bat`: da
   quel momento il totem si avvia da solo a ogni accesso a Windows (utile se
   il PC e' impostato per fare il login automatico all'accensione).

All'avvio automatico non compare nessuna finestra: il collegamento nello
Startup lancia `start-kiosk.vbs`, che a sua volta esegue `start-kiosk.bat` in
modo nascosto, e il server PowerShell parte senza console. Lanciando invece
`start-kiosk.bat` a mano (per i test) la finestra nera resta visibile: e'
normale, usa `start-kiosk.vbs` se vuoi provarlo com'e' all'avvio.

Per fermare tutto manualmente: `stop-kiosk.bat` (chiude il server e il
browser). Per rimuovere l'avvio automatico: `uninstall-autostart.bat`.

### Schermo intero del browser

`start-kiosk.bat` avvia Chrome/Edge con un **profilo dedicato**
(`%LOCALAPPDATA%\SEIMuseumKiosk\browser-profile`). Senza di esso, se sul PC
c'e' gia' una finestra di Chrome/Edge aperta, il comando aprirebbe solo una
scheda in quella finestra e tutti i flag — `--kiosk` compreso — verrebbero
ignorati: era questa la causa piu' comune del "non va a schermo intero".

Su Edge l'URL viene passato subito dopo `--kiosk`, come richiede
`--edge-kiosk-type=fullscreen`; su Chrome si usano `--kiosk
--start-fullscreen`. Il primo avvio del profilo dedicato ripropone una volta
il popup di conferma di `salina-app://`: spunta "Ricorda la mia scelta".

Se cambi PC o porta, l'unica cosa da modificare e' la variabile `PORT` in
cima a `start-kiosk.bat` (e passare `-Port` allo stesso valore se lanci
`serve.ps1` a mano).

## Apertura di saline.exe dalla card "La vita in Salina"

Un browser non puo' lanciare un .exe locale direttamente per motivi di
sicurezza. La card sul sito punta a un link con protocollo custom
`salina-app://launch`, che va registrato una volta sul PC.

1. `register-salina-protocol.bat` deve stare nella cartella che contiene
   `app_deploy` (vedi struttura sopra). Fai doppio clic: non servono
   permessi di amministratore (scrive solo in HKEY_CURRENT_USER).
2. Da questo momento, cliccando la card sul sito, il browser propone di
   aprire "Salina App Protocol" con `saline.exe`.
3. Per rimuovere la registrazione: `unregister-salina-protocol.bat`.

### Nota sul popup di conferma del browser

Chrome/Edge, al primo utilizzo di un protocollo custom, mostrano un popup
"Apri Salina App?" con una checkbox "Ricorda la mia scelta per i link
salina-app". Se la si spunta, i click successivi apriranno l'app senza
chiedere di nuovo.

Per sopprimere del tutto il popup in modalita' kiosk (richiede diritti di
amministratore sul PC), si puo' whitelistare il protocollo via policy
Chrome/Edge:

```
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\AutoLaunchProtocolsFromOrigins]
"1"="{\"protocol\":\"salina-app\",\"allowed_origins\":[\"http://localhost:8080\"]}"
```

(per Edge: `HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\AutoLaunchProtocolsFromOrigins`).
Questo passaggio e' opzionale: senza policy, la card funziona comunque, solo
con un popup di conferma la prima volta.

## Aggiornare il sito in futuro

Ogni volta che il sito cambia:

1. Sul Mac/PC di sviluppo: `npm run build` (genera `dist/`).
2. Copia la nuova `dist/` sul PC del museo, sostituendo quella vecchia.
3. Se il kiosk era gia' avviato, rilancia `stop-kiosk.bat` e poi
   `start-kiosk.bat` (oppure riavvia il PC, se hai attivato l'avvio
   automatico).
