# Sdílená konfigurace a pomocné funkce pro zrcadlení:
#   Axima-Git (firemní org)  ->  D:\git (lokální prostředník)  ->  Anamax443 (soukromá záloha)

$script:Org         = 'Axima-Git'                       # zdrojová firemní GitHub organizace
$script:BackupOwner = 'Anamax443'                       # cílový soukromý účet (záloha)
$script:LocalRoot   = 'D:\git'                          # lokální prostředník
$script:LogDir      = Join-Path $PSScriptRoot 'logs'

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    if (-not (Test-Path $script:LogDir)) { New-Item -ItemType Directory -Path $script:LogDir | Out-Null }
    $ts   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$ts] [$Level] $Message"
    $color = switch ($Level) { 'ERROR' { 'Red' } 'WARN' { 'Yellow' } 'OK' { 'Green' } default { 'Gray' } }
    Write-Host $line -ForegroundColor $color
    Add-Content -Path (Join-Path $script:LogDir ("mirror-{0}.log" -f (Get-Date -Format 'yyyy-MM'))) -Value $line
}

function Test-GhAuth {
    gh auth status 1>$null 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'gh CLI není přihlášené. Spusť: gh auth login' }
}

# Vrátí aktivní (nearchivované) repozitáře z org Axima-Git.
function Get-AximaRepos {
    $json = gh repo list $script:Org --limit 500 --json name,url,isArchived 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $json) { throw "Nelze načíst seznam repozitářů z org $script:Org." }
    $json | ConvertFrom-Json | Where-Object { -not $_.isArchived }
}
