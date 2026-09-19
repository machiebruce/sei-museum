<#
  Server statico minimale per servire la cartella "dist" del sito SEI Museum
  su http://localhost, senza installare nulla (usa solo PowerShell, gia'
  presente su ogni Windows). Necessario perche' il sito usa script ES module
  che i browser rifiutano di caricare se aperti come file:// diretto.

  Gestisce le richieste in parallelo (una pool di thread): una pagina
  moderna carica CSS/JS/immagini con piu' richieste contemporanee, e i
  video sono file da 10-20MB. Un server a singolo thread le processerebbe
  una alla volta, mettendo tutte le altre in coda dietro al file piu'
  pesante; se il browser si stanca di aspettare e chiude la connessione,
  la successiva scrittura sulla risposta fallisce con l'errore Windows
  "il nome di rete specificato non e' piu' disponibile" (era questo il
  problema sul PC del museo: funzionava sul Mac/GitHub Pages, che servono
  le richieste in parallelo, ma non su questo server).
#>
param(
  [int]$Port = 8080,
  [int]$MaxConcurrentRequests = 16
)

$ErrorActionPreference = "Stop"

$root = Join-Path $PSScriptRoot "dist"
if (-not (Test-Path $root)) {
  Write-Host "ERRORE: non trovo la cartella 'dist' accanto a questo script."
  Write-Host "Copia qui il risultato di 'npm run build' (la cartella dist/)."
  exit 1
}
$root = (Resolve-Path $root).Path

# PID file cosi' stop-kiosk.bat puo' fermare esattamente questo processo
$pidFile = Join-Path $PSScriptRoot "serve.pid"
[System.Diagnostics.Process]::GetCurrentProcess().Id | Out-File -FilePath $pidFile -Encoding ascii -Force

$mimeTypes = @{
  ".html" = "text/html; charset=utf-8"; ".htm" = "text/html; charset=utf-8"
  ".css"  = "text/css"; ".js" = "application/javascript"; ".mjs" = "application/javascript"
  ".json" = "application/json"; ".svg" = "image/svg+xml"; ".png" = "image/png"
  ".jpg"  = "image/jpeg"; ".jpeg" = "image/jpeg"; ".webp" = "image/webp"
  ".gif"  = "image/gif"; ".ico" = "image/x-icon"; ".mp4" = "video/mp4"
  ".woff" = "font/woff"; ".woff2" = "font/woff2"; ".ttf" = "font/ttf"
  ".txt"  = "text/plain; charset=utf-8"; ".webmanifest" = "application/manifest+json"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
try {
  $listener.Start()
} catch {
  Write-Host "Impossibile avviare il server sulla porta $Port (gia' in uso?): $_"
  Remove-Item $pidFile -ErrorAction SilentlyContinue
  exit 1
}

Write-Host "Server avviato su http://localhost:$Port/  (cartella servita: $root)"
Write-Host "Premi Ctrl+C per fermarlo."

# Pool di runspace: ogni richiesta viene gestita su un thread separato cosi'
# un file grande (un video) non blocca tutte le altre richieste in arrivo.
$sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$runspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $MaxConcurrentRequests, $sessionState, $Host)
$runspacePool.Open()

# Corpo della gestione di una singola richiesta, eseguito dentro il runspace pool
$handlerScript = {
  param($context, $root, $mimeTypes)

  $request = $context.Request
  $response = $context.Response
  try {
    $urlPath = [System.Uri]::UnescapeDataString($request.Url.AbsolutePath)
    if ([string]::IsNullOrEmpty($urlPath)) { $urlPath = "/" }

    $relPath = $urlPath.TrimStart('/')
    $exactPath = if ($relPath -eq "") { $root } else { Join-Path $root $relPath }

    $servedFile = $null
    $redirectTo = $null

    if (Test-Path $exactPath -PathType Container) {
      # Cartella: come GitHub Pages, richiedi lo slash finale prima di
      # servire index.html, cosi' i percorsi relativi degli asset si
      # risolvono alla profondita' giusta (altrimenti immagini/icone si
      # rompono, esattamente come nel bug gia' risolto sul sito pubblico).
      if ($urlPath.EndsWith("/")) {
        $indexCandidate = Join-Path $exactPath "index.html"
        if (Test-Path $indexCandidate -PathType Leaf) { $servedFile = $indexCandidate }
      } else {
        $redirectTo = $urlPath + "/"
      }
    } elseif (Test-Path $exactPath -PathType Leaf) {
      $servedFile = $exactPath
    } else {
      # URL "pulito" senza estensione (es. /fonti -> fonti.html), come fa
      # GitHub Pages.
      $htmlCandidate = "$exactPath.html"
      if (Test-Path $htmlCandidate -PathType Leaf) {
        $servedFile = $htmlCandidate
      }
    }

    if ($redirectTo) {
      $response.StatusCode = 301
      $response.Headers.Add("Location", $redirectTo)
      return
    }

    if (-not $servedFile) {
      $response.StatusCode = 404
      $bytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $urlPath")
      $response.ContentLength64 = $bytes.Length
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
      return
    }

    # Blocca qualunque path risolto che tenti di uscire da $root (traversal)
    $resolved = (Resolve-Path $servedFile).Path
    if (-not $resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
      $response.StatusCode = 404
      $bytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $urlPath")
      $response.ContentLength64 = $bytes.Length
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
      return
    }

    $ext = [System.IO.Path]::GetExtension($resolved).ToLower()
    $contentType = $mimeTypes[$ext]
    if (-not $contentType) { $contentType = "application/octet-stream" }
    $response.ContentType = $contentType

    # File grandi (video) a blocchi, invece di caricare tutto in RAM e
    # scriverlo in un colpo solo: piu' leggero e permette al browser di
    # iniziare a riprodurre prima che il download sia completo.
    $fileStream = [System.IO.File]::OpenRead($resolved)
    try {
      $response.ContentLength64 = $fileStream.Length
      $fileStream.CopyTo($response.OutputStream)
    } finally {
      $fileStream.Close()
    }
  } catch {
    # Tipicamente il browser ha chiuso la connessione a meta' (pagina
    # cambiata, video interrotto): non e' un errore del server, non
    # serve fermarsi ne' allarmare l'utente in console.
    $msg = $_.Exception.Message
    if ($msg -notmatch "nome di rete|network name|pipe|connection") {
      Write-Host "Errore richiesta: $_"
    }
    try { $response.StatusCode = 500 } catch {}
  } finally {
    try { $response.OutputStream.Close() } catch {}
  }
}

$pending = New-Object System.Collections.Generic.List[object]

while ($listener.IsListening) {
  try {
    $context = $listener.GetContext()
  } catch {
    break
  }

  $ps = [System.Management.Automation.PowerShell]::Create()
  $ps.RunspacePool = $runspacePool
  [void]$ps.AddScript($handlerScript).AddArgument($context).AddArgument($root).AddArgument($mimeTypes)
  $handle = $ps.BeginInvoke()
  $pending.Add(@{ PS = $ps; Handle = $handle })

  # Ripulisci le richieste gia' completate cosi' la lista non cresce all'infinito
  for ($i = $pending.Count - 1; $i -ge 0; $i--) {
    if ($pending[$i].Handle.IsCompleted) {
      try { $pending[$i].PS.EndInvoke($pending[$i].Handle) } catch {}
      $pending[$i].PS.Dispose()
      $pending.RemoveAt($i)
    }
  }
}

foreach ($item in $pending) {
  try { $item.Handle.AsyncWaitHandle.WaitOne(2000) | Out-Null } catch {}
  try { $item.PS.EndInvoke($item.Handle) } catch {}
  $item.PS.Dispose()
}
$runspacePool.Close()
$runspacePool.Dispose()

Remove-Item $pidFile -ErrorAction SilentlyContinue
