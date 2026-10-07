# Inspección opcional

Ejecutar con Windows PowerShell 5.1 desde la raíz del repo, usando las rutas propias:

```powershell
powershell.exe -NoProfile -File .\tools\inspection\InspeccionarASL.ps1 -LiveSplitPath 'C:\LiveSplit'
powershell.exe -NoProfile -File .\tools\inspection\InspeccionarJuego.ps1 -GameAssemblyPath 'C:\Furi\Furi_Data\Managed\Assembly-CSharp.dll' -GameType 'Chrono'
```

El primer comando muestra la API del componente ASL instalado. El segundo inspecciona la clase indicada en la instalación propia del juego. Su salida puede redirigirse a un archivo dentro de `local/`; los volcados del juego no forman parte del repositorio público.
