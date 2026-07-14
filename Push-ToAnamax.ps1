# KROK 2 — Push lokálních repos (původem z Axima-Git) do soukromého účtu Anamax443 jako záloha.
#   - cílový repo neexistuje -> vytvoří ho jako PRIVATE se značkou "mirror-of Axima-Git/<name>"
#   - cílový repo existuje    -> pushne jen když nese tuto značku (jinak přeskočí, ať nepřepíše cizí repo);
#                                 -Force značku ignoruje.
#   - push --all + --tags (nedestruktivní, nemaže na cíli refy).
[CmdletBinding()]
param(
    [switch]$Force   # pushnout i do cílového repa bez značky mirror-of (na vlastní riziko)
)

. (Join-Path $PSScriptRoot 'mirror.config.ps1')
Test-GhAuth

Write-Log "=== KROK 2: Push do $script:BackupOwner ==="
$repos      = Get-AximaRepos
$remoteName = 'anamax'

foreach ($r in $repos) {
    $path   = Join-Path $script:LocalRoot $r.name
    $target = "$script:BackupOwner/$($r.name)"
    $marker = "mirror-of $script:Org/$($r.name)"
    try {
        if (-not (Test-Path (Join-Path $path '.git'))) {
            Write-Log "$($r.name): lokálně chybí — spusť nejdřív KROK 1. Přeskočeno." 'WARN'; continue
        }

        # Existuje cílový repo?
        $info = gh repo view $target --json name,description 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $info) {
            Write-Log "Vytvářím soukromý repo $target ..."
            gh repo create $target --private --description $marker 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) { throw 'gh repo create selhal' }
        } else {
            $desc = ($info | ConvertFrom-Json).description
            if (($desc -notlike "*$marker*") -and -not $Force) {
                Write-Log "$target existuje a není označen jako zrcadlo — přeskočeno (spusť s -Force pro přepis)." 'WARN'; continue
            }
        }

        # Zajisti remote 'anamax'
        $url      = "https://github.com/$target.git"
        $existing = git -C $path remote get-url $remoteName 2>$null
        if ($LASTEXITCODE -ne 0) {
            git -C $path remote add $remoteName $url 2>&1 | Out-Null
        } elseif ($existing.Trim() -ne $url) {
            git -C $path remote set-url $remoteName $url 2>&1 | Out-Null
        }

        # Push všech větví a tagů
        git -C $path push $remoteName --all  2>&1 | Out-Null; $a = $LASTEXITCODE
        git -C $path push $remoteName --tags 2>&1 | Out-Null; $t = $LASTEXITCODE
        if ($a -eq 0 -and $t -eq 0) { Write-Log "Zazálohováno: $($r.name) -> $target" 'OK' }
        else { throw "git push selhal (branches=$a, tags=$t)" }
    } catch {
        Write-Log "$($r.name): $($_.Exception.Message)" 'ERROR'
    }
}
Write-Log "=== KROK 2 hotovo ==="
