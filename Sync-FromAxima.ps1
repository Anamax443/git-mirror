# KROK 1 — Synchronizace lokálního gitu (D:\git) s firemní org Axima-Git.
#   - repo, které lokálně chybí  -> naklonuje
#   - repo, které lokálně je     -> fetch --all --prune --tags a (pokud je strom čistý) ff-only pull
# Nikdy nepřepisuje neuložené lokální změny.
[CmdletBinding()]
param(
    [switch]$NoPull   # jen fetch, neprovádět ff-only pull pracovní větve
)

. (Join-Path $PSScriptRoot 'mirror.config.ps1')
Test-GhAuth

Write-Log "=== KROK 1: Sync z org $script:Org do $script:LocalRoot ==="
$repos = Get-AximaRepos
Write-Log "Nalezeno $($repos.Count) aktivních repozitářů."

foreach ($r in $repos) {
    $path = Join-Path $script:LocalRoot $r.name
    try {
        if (-not (Test-Path (Join-Path $path '.git'))) {
            Write-Log "Klonuji $($r.name) ..."
            git clone $r.url $path 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) { throw 'git clone selhal' }
            Write-Log "Naklonováno: $($r.name)" 'OK'
            continue
        }

        git -C $path fetch --all --prune --tags 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'git fetch selhal' }

        if (-not $NoPull) {
            $dirty  = git -C $path status --porcelain
            $branch = (git -C $path rev-parse --abbrev-ref HEAD).Trim()
            if ([string]::IsNullOrWhiteSpace($dirty) -and $branch -ne 'HEAD') {
                git -C $path pull --ff-only 2>&1 | Out-Null
                if ($LASTEXITCODE -ne 0) { Write-Log "$($r.name): ff-only pull nešel (rozešlé větve) — ponechán jen fetch." 'WARN' }
            } elseif ($dirty) {
                Write-Log "$($r.name): neuložené lokální změny — provádím jen fetch." 'WARN'
            }
        }
        Write-Log "Aktualizováno: $($r.name)" 'OK'
    } catch {
        Write-Log "$($r.name): $($_.Exception.Message)" 'ERROR'
    }
}
Write-Log "=== KROK 1 hotovo ==="
