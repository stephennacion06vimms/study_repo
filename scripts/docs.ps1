<#
.SYNOPSIS
  One-command launcher for the local docs site (MkDocs Material + PlantUML).
  Creates the venv and installs pinned requirements on first run, or when
  tools/docs/requirements.txt changes, then serves or builds the site.
.PARAMETER Action
  serve  (default) Live preview at http://127.0.0.1:<Port>, opens the browser.
  build  Strict build into site/ (same check as CI).
  open   Strict build, then open site/index.html from disk.
  setup  Only create/update the venv.
.PARAMETER Port
  Local preview port (default 8001, so it can run next to the vimms-engineering site on 8000). The server always binds to 127.0.0.1.
.PARAMETER NoBrowser
  Don't open a browser window.
.EXAMPLE
  .\scripts\docs.ps1
.EXAMPLE
  .\scripts\docs.ps1 build
#>
param(
    [ValidateSet('serve', 'build', 'open', 'setup')]
    [string]$Action = 'serve',
    [ValidateRange(1024, 65535)]
    [int]$Port = 8001,
    [switch]$NoBrowser
)

$ErrorActionPreference = 'Stop'

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$venv = Join-Path $repo 'tools\docs\.venv'
$python = Join-Path $venv 'Scripts\python.exe'
$requirements = Join-Path $repo 'tools\docs\requirements.txt'
$stamp = Join-Path $venv '.requirements.sha256'

function Install-DocsVenv {
    if (-not (Test-Path $python)) {
        if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
            throw 'Python launcher "py" not found. Install Python 3.13 from python.org.'
        }
        Write-Host 'Creating tools\docs\.venv (Python 3.13)...'
        & py -3.13 -m venv $venv
        if ($LASTEXITCODE -ne 0) { throw 'venv creation failed. Is Python 3.13 installed? (py -0p)' }
    }

    # Reinstall only when the pinned requirements change.
    $hash = (Get-FileHash $requirements -Algorithm SHA256).Hash
    $current = if (Test-Path $stamp) { (Get-Content $stamp -Raw).Trim() } else { '' }
    if ($hash -ne $current) {
        Write-Host 'Installing pinned docs requirements...'
        & $python -m pip install --disable-pip-version-check -q -r $requirements
        if ($LASTEXITCODE -ne 0) { throw 'pip install failed.' }
        Set-Content -Path $stamp -Value $hash -NoNewline
    }
}

function Test-Java {
    # PlantUML diagrams need Java 11+; pages still build without it only if no diagrams change.
    if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
        Write-Warning 'Java not found on PATH. PlantUML diagrams need Java 11 or newer.'
    }
}

Push-Location $repo
try {
    Install-DocsVenv
    if ($Action -eq 'setup') { Write-Host 'Docs toolchain ready.'; return }
    Test-Java

    switch ($Action) {
        'serve' {
            $url = "http://127.0.0.1:$Port/"
            if (-not $NoBrowser) {
                # Open the browser once the server answers (up to ~60 s for the first PlantUML render).
                Start-Job -ScriptBlock {
                    param($u)
                    for ($i = 0; $i -lt 120; $i++) {
                        try { Invoke-WebRequest $u -UseBasicParsing -TimeoutSec 1 | Out-Null; Start-Process $u; return }
                        catch { Start-Sleep -Milliseconds 500 }
                    }
                } -ArgumentList $url | Out-Null
            }
            Write-Host "Serving $url (local only, no authentication). Ctrl+C to stop."
            & $python -m mkdocs serve --dev-addr "127.0.0.1:$Port"
        }
        { $_ -in 'build', 'open' } {
            & $python -m mkdocs build --strict
            if ($LASTEXITCODE -ne 0) { throw 'mkdocs build failed (see errors above).' }
            if ($Action -eq 'open' -and -not $NoBrowser) {
                Start-Process (Join-Path $repo 'site\index.html')
            }
        }
    }
}
finally {
    Pop-Location
}
