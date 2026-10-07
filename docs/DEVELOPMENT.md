# Desarrollo y verificación

Español | [English](DEVELOPMENT.en.md)

Antes de ampliar el proyecto, leer [CONTEXT.md](CONTEXT.md) para el estado y evidencia actuales, y [CONTRIBUTING.md](../CONTRIBUTING.md) para investigar y entregar cambios.

El archivo de referencia es `ASL/Furi.asl`. LiveSplit puede cargarlo directamente desde el repositorio. No hace falta compilar un ejecutable ni instalar Cheat Engine para usarlo.

## Lecturas y eventos

Beta.8 incorpora `koCounter` (Statistics +0x24) y un resolvedor compartido con hits. Reconoce Furi Hits/Hits y Furi KO/KO sin distinguir mayúsculas y con dos puntos finales opcionales. Un único Counter predeterminado puede recibir la única métrica habilitada; ambas requieren nombres separados. Ausencia/ambigüedad no escribe y se registra al cambiar el estado del vínculo. Las opciones son independientes y desactivadas por defecto. Las pruebas con la DLL Counter instalada cubren KO, alias, ambos contadores separados, reset selectivo y fallback predeterminado sin cruces.

Beta.7 añade `hitCounter`, desactivada por defecto. Lee Statistics._hits en +0x28 desde la misma ruta validada del cronómetro y originalmente sincronizaba un único componente Counter con texto exacto Furi Hits mediante la API SetCount (reflexión para mantener Counter opcional). No simula hotkeys ni modifica otros contadores. Conserva máximos en la partida, ignora lecturas inválidas/negativas, y limpia en Start/Reset o partida nueva. Modos aceptados: Carrera y Práctica habilitada; no depende de casillas de splits. El registro Carrera/Furi confirmó muerte/reanudación y Chain → Strap con 24 impactos conservados. La conexión real en el layout y otras combinaciones siguen pendientes.

El harness de hits requiere la DLL Counter instalada (no distribuida): usa su implementación real en un layout/timer aislado para comprobar nombre, total, otros contadores intactos, ambigüedad, opción apagada, muestras inválidas, modos y reset. También comprueba Start/Reset manual con supported=false. No modifica el Counter del LiveSplit abierto.

Beta.6 añade `phaseSplits`, desactivada por defecto. Para Carrera y Práctica habilitada, divide por avance observado de una fase del mismo combate, con Statistics válido y las casillas de jefes. La última fase conserva el split de victoria y su momento. No cuenta regresiones/repeticiones ni reconstruye saltos múltiples o huecos. Ruta de fase: dominio +0x1EAE8 → PawnManager +0x48 → AIPawn +0x1D8 → controlador; índice +0x1B8 y configuración +0xF0 → lista +0x18 → tamaño +0x18. Corroborada en registros LAW/Furi de Práctica y Carrera y en un proceso nuevo; el jugador también reportó splits por fases y ausencia de split al morir sin especificar modo, dificultad o jefe; otras combinaciones siguen pendientes. Ver [CONTEXT.md](CONTEXT.md).

El harness cubre fases en modos 3/4 y dificultades 1/2: avance único, filtros, regresión, gap/NaN, datos inválidos, salto múltiple, Game Time y coordinación con la victoria final. Son muestras sintéticas; `init` verifica módulos/hashes del proceso real.

Desde beta.5, las opciones del ASL están en inglés. Para la 1.0.0 el usuario eligió conservar el ASL en inglés y tener documentación en español e inglés. `splitOnResults` permite elegir resultados de victoria (Statistics acumulado válido) o siguiente arena lista (Chrono._initialTime); por defecto está desactivada y conserva el segundo comportamiento. The Star siempre divide en resultados; también se conservan Práctica y el Bernard final de Furiosa en resultados. Las casillas de jefes se aplican a ambos momentos. Los tests cubren resultados en dificultades 1/2, datos inválidos, muerte/fases, duplicados tras cargar y jefes desmarcados, además de las regresiones del modo siguiente arena.

La versión 1.0.0 conserva el comportamiento de beta.8 y solo habilita la build cuyos hashes figuran en [LEEME.md](../LEEME.md). La raíz se lee desde `mono-2.0-bdwgc.dll + 0x49AC78`; desde el dominio Mono se resuelven `GameManager` en `+0x1ED08` y `GlobalGameManager` en `+0x1EF48`. Las rutas se contrastaron al reiniciar el proceso. Son específicas de esa build.

Game Time procede de `GameDataInfo._currentStatistics -> Statistics._time`. El ASL conserva el último tiempo válido durante huecos de lectura y evita la extrapolación de LiveSplit. Al quedar lista la siguiente arena, el split usa `Chrono._initialTime`, el total heredado del jefe anterior.

Por defecto, la victoria de un jefe intermedio queda pendiente hasta cargar otra arena y produce un solo split. Historia no genera acciones. Práctica requiere activar su opción separada. El inicio exige una partida nueva de Carrera en LAW; adjuntar durante una pelea o en resultados no inicia el timer. El reset de un intento en curso es opcional. El último jefe divide en resultados de victoria: MOTHERSHIP en Furi y BERNARD en Furiosa, usando el acumulado válido de Statistics. El cierre en Carrera real sigue pendiente de comprobación.

Desde beta.3, `bossSplits` conserva la opción general y sus hijas `boss_<ID>` seleccionan cada jefe. Todas vienen activadas. Un evento desmarcado se consume sin split y sin reemplazar Game Time por el límite heredado. Los tests sintéticos comprueban las 12 casillas, la prioridad de la general, el reloj tras omitir, la limpieza del pendiente y la siguiente partida con el jefe habilitado.

## Comprobar el ASL

Desde beta.4, `practiceMode` habilita modo 3 con inicio en la arena lista de una partida nueva y split en resultados de victoria, usando las mismas casillas de jefes y Statistics. Está desactivada por defecto. El reset automático sigue siendo solo de Carrera. Los casos sintéticos cubren ambas dificultades, carga, pausa/huecos, muerte/fases/NaN, pérdida de foco, victoria única, casilla desactivada, adjuntar y cambios de modo. Los reinicios de Práctica dentro de la misma partida no se reconocen automáticamente: reset manual y nueva selección desde el menú.

Ejecutar desde la raíz con **Windows PowerShell 5.1** (`powershell.exe`), LiveSplit instalado y su componente Scriptable Auto Splitter disponible. Reemplazar la ruta de ejemplo por la instalación propia. No se incluyen sus DLL en el repo.

```powershell
powershell.exe -NoProfile -File .\tests\ValidarASL.ps1 -LiveSplitPath 'C:\LiveSplit'
```

El parser del componente instalado compila todos los bloques ASL. Para reproducir el registro y los casos sintéticos, abrir Furi de la build compatible y ejecutar:

```powershell
powershell.exe -NoProfile -File .\tests\ReproducirRegistro.ps1 -LiveSplitPath 'C:\LiveSplit'
```

Con varios procesos, indicar también `-GameProcessId`. La prueba usa un timer aislado; no cambia el timer abierto en LiveSplit. `init` consulta los módulos del proceso y verifica sus hashes; las muestras posteriores son del registro o sintéticas. La reproducción necesita permisos de lectura del proceso.

`tests/fixtures/chain-strap.txt` contiene observaciones de una sesión, sin archivos del juego. Sus direcciones solo identifican objetos dentro de ese registro; no se usan como punteros del proceso actual. Se comprueban inicio, reset opcional, victoria/transición, duplicados, pausas/cargas, datos inválidos, tiempo heredado, exclusión de Práctica y victoria final sintética para ambas dificultades. Estos casos no sustituyen una carrera completa en vivo.

## Crear el paquete distribuible

```powershell
powershell.exe -NoProfile -File .\tools\Empaquetar.ps1
```

La versión se obtiene de la cabecera de `ASL/Furi.asl`. El script copia el ASL, las instrucciones para jugadores y changelogs en inglés/español, la plantilla bilingüe de reporte y LICENSE, genera `SHA256SUMS.txt` y crea `dist/Furi-Autosplitter-<version>.zip`. Puede regenerarse después de actualizar esos archivos. No empaqueta herramientas, investigación, tests ni binarios externos. Ver [PUBLISHING.md](PUBLISHING.md) para releases, alta en LiveSplit y actualizaciones.

## Investigación

- `tools/cheat-engine/`: diagnósticos Lua; ver su README antes de usarlos.
- `tools/inspection/`: utilidades para inspeccionar el componente ASL y clases de la instalación propia del juego.
- `local/`: notas privadas, registros crudos y volcados IL, excluidos de Git.
- `dist/`: paquetes generados, excluidos de Git; el ZIP puede adjuntarse a una release.

No añadir DLL del juego, partidas guardadas ni layouts con rutas personales al repositorio. Los volcados IL se guardan en `local/`.

Pendientes: carrera completa, jefes restantes, victoria/transición registrada en Furiosa, cobertura detallada de DLC/personajes, otras builds y comprobación en vivo del split de victoria final. La prueba del jefe final en Práctica con invencibilidad y salto de fases es diagnóstica. El ajuste al total heredado pasó reproducción; falta contrastarlo en vivo en esta revisión.
