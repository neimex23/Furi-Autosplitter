# Optional inspection

[Español](README.md) | English

Run with Windows PowerShell 5.1 from the repository root, using your own paths:

```powershell
powershell.exe -NoProfile -File .\tools\inspection\InspeccionarASL.ps1 -LiveSplitPath 'C:\LiveSplit'
powershell.exe -NoProfile -File .\tools\inspection\InspeccionarJuego.ps1 -GameAssemblyPath 'C:\Furi\Furi_Data\Managed\Assembly-CSharp.dll' -GameType 'Chrono'
```

The first command displays the installed ASL component's API. The second inspects the specified class in your own game installation. Output can be redirected to a file under `local/`; game dumps are not part of the public repository.
