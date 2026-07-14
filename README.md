# git-mirror — zrcadlení Axima-Git → Anamax443

Robot, který drží projekty z firemní GitHub org **Axima-Git** i na tvém soukromém účtu **Anamax443**.
Lokální `D:\git` je prostředník:

```
Axima-Git  ──(KROK 1: sync)──►  D:\git  ──(KROK 2: push)──►  Anamax443
```

## Předpoklady
- `gh` CLI přihlášené účtem s přístupem do org Axima-Git i s právem zápisu na Anamax443
  (`gh auth status`).
- `git` v PATH.

## Použití

```powershell
# KROK 1 — stáhnout/aktualizovat firemní repos do D:\git
.\Sync-FromAxima.ps1            # klon chybějících + fetch & ff-only pull existujících
.\Sync-FromAxima.ps1 -NoPull    # jen fetch, bez posunu pracovní větve

# KROK 2 — pushnout je do soukromého Anamax443 (chybějící repos vytvoří jako PRIVATE)
.\Push-ToAnamax.ps1
.\Push-ToAnamax.ps1 -Force      # pushne i do cíle bez značky "mirror-of" (opatrně)

# Oba kroky najednou
.\Mirror-All.ps1
```

## Automatizace (denně)

```powershell
.\Register-Task.ps1                       # denně 18:30
.\Register-Task.ps1 -Time 07:00           # jiný čas
Start-ScheduledTask -TaskName AximaGitMirror   # ruční spuštění úlohy
```

## Bezpečnostní pojistky
- KROK 1 nikdy nepřepíše neuložené lokální změny (u „špinavého" stromu jen `fetch`).
- KROK 2 vytváří cílové repos jako **PRIVATE** a značí je v popisu `mirror-of Axima-Git/<name>`.
  Do existujícího repa bez této značky **nepushne** (ochrana proti přepsání cizího projektu) —
  přebít lze jen `-Force`.
- Push je nedestruktivní (`--all --tags`), na cíli nemaže žádné refy.

## Logy
`logs\mirror-RRRR-MM.log` (měsíční soubor).
