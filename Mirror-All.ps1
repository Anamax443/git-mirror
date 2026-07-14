# Spustí oba kroky za sebou: KROK 1 (sync z Axima-Git) + KROK 2 (push do Anamax443).
[CmdletBinding()]
param(
    [switch]$NoPull,   # předá se do KROKU 1
    [switch]$Force     # předá se do KROKU 2
)
& (Join-Path $PSScriptRoot 'Sync-FromAxima.ps1') -NoPull:$NoPull
& (Join-Path $PSScriptRoot 'Push-ToAnamax.ps1')  -Force:$Force
