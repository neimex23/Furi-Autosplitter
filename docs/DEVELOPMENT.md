# Desarrollo y verificación

Antes de ampliar el proyecto, leer [CONTEXT.md](CONTEXT.md) para el estado y evidencia actuales, y [CONTRIBUTING.md](../CONTRIBUTING.md) para investigar y entregar cambios.

El archivo de referencia es `ASL/Furi.asl`. LiveSplit puede cargarlo directamente desde el repositorio. No hace falta compilar un ejecutable ni instalar Cheat Engine para usarlo.

## Lecturas y eventos

La beta solo habilita la build cuyos hashes figuran en [LEEME.md](../LEEME.md). La raíz se lee desde `mono-2.0-bdwgc.dll + 0x49AC78`; desde el dominio Mono se resuelven `GameManager` en `+0x1ED08` y `GlobalGameManager` en `+0x1EF48`. Las rutas se contrastaron al reiniciar el proceso. Son específicas de esa build.

Game Time procede de `GameDataInfo._currentStatistics -> Statistics._time`. El ASL conserva el último tiempo válido durante huecos de lectura y evita la extrapolación de LiveSplit. Al quedar lista la siguiente arena, el split usa `Chrono._initialTime`, el total heredado del jefe anterior.

Una victoria queda pendiente hasta cargar otra arena y produce un solo split. Práctica e Historia no generan acciones. El inicio exige una partida nueva de Carrera en LAW; adjuntar durante una pelea o en resultados no inicia el timer. El reset de un intento en curso es opcional. El cierre final sigue siendo manual.

## Comprobar el ASL

Ejecutar desde la raíz con **Windows PowerShell 5.1** (`powershell.exe`), LiveSplit instalado y su componente Scriptable Auto Splitter disponible. Reemplazar la ruta de ejemplo por la instalación propia. No se incluyen sus DLL en el repo.

```powershell
powershell.exe -NoProfile -File .\tests\ValidarASL.ps1 -LiveSplitPath 'C:\LiveSplit'
```

El parser del componente instalado compila todos los bloques ASL. Para reproducir el registro y los casos sintéticos, abrir Furi de la build compatible y ejecutar:

```powershell
powershell.exe -NoProfile -File .\tests\ReproducirRegistro.ps1 -LiveSplitPath 'C:\LiveSplit'
```

Con varios procesos, indicar también `-GameProcessId`. La prueba usa un timer aislado; no cambia el timer abierto en LiveSplit. `init` consulta los módulos del proceso y verifica sus hashes; las muestras posteriores son del registro o sintéticas. La reproducción necesita permisos de lectura del proceso.

`tests/fixtures/chain-strap.txt` contiene observaciones de una sesión, sin archivos del juego. Sus direcciones solo identifican objetos dentro de ese registro; no se usan como punteros del proceso actual. Se comprueban inicio, reset opcional, victoria/transición, duplicados, pausas/cargas, datos inválidos, tiempo heredado y exclusión de Práctica. Estos casos no sustituyen una carrera completa en vivo.

## Crear el paquete de pruebas

```powershell
powershell.exe -NoProfile -File .\tools\Empaquetar.ps1
```

La versión se obtiene de la cabecera de `ASL/Furi.asl`. El script copia el ASL y las cuatro instrucciones públicas, genera `SHA256SUMS.txt` y crea `dist/Furi-Autosplitter-<version>.zip`. Puede regenerarse después de actualizar esos archivos. No empaqueta herramientas, investigación, tests ni binarios externos.

## Investigación

- `tools/cheat-engine/`: diagnósticos Lua; ver su README antes de usarlos.
- `tools/inspection/`: utilidades para inspeccionar el componente ASL y clases de la instalación propia del juego.
- `local/`: notas privadas, registros crudos y volcados IL, excluidos de Git.
- `dist/`: paquetes generados, excluidos de Git; el ZIP puede adjuntarse a una release.

No añadir DLL del juego, partidas guardadas ni layouts con rutas personales al repositorio. Los volcados IL se guardan en `local/`.

Pendientes: carrera completa, jefes restantes, victoria/transición registrada en Furiosa, DLC/personajes, otras builds y cierre automático final. La prueba del jefe final en Práctica con invencibilidad y salto de fases es diagnóstica. El ajuste al total heredado pasó reproducción; falta contrastarlo en vivo en esta revisión.
