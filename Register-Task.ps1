# Zaregistruje denní plánovanou úlohu, která spustí Mirror-All.ps1 pod aktuálním uživatelem.
# Běží pod tvým účtem, aby fungovalo gh přihlášení z keyringu (Anamax443).
[CmdletBinding()]
param(
    [string]$Time     = '18:30',
    [string]$TaskName = 'AximaGitMirror'
)
$script    = Join-Path $PSScriptRoot 'Mirror-All.ps1'
$action    = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$trigger   = New-ScheduledTaskTrigger -Daily -At $Time
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal `
    -Description 'Zrcadlení Axima-Git -> D:\git -> Anamax443' -Force | Out-Null

Write-Host "Plánovaná úloha '$TaskName' zaregistrována — denně v $Time." -ForegroundColor Green
Write-Host "Ruční spuštění: Start-ScheduledTask -TaskName $TaskName" -ForegroundColor Gray
