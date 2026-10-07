# Diagnósticos de Cheat Engine

Español | [English](README.en.md)

Herramientas opcionales de investigación en Lua para Cheat Engine con Mono. No son necesarias para usar el ASL. Consultan memoria del juego; algunas realizan escaneos y pueden tardar. Los offsets de ruta corresponden a la build compatible documentada en el proyecto.

Con Cheat Engine adjunto a `Furi.exe`, abrir la ventana Lua y cargar el archivo elegido con `dofile([[ruta completa al archivo.lua]])`, usando la ubicación de este repositorio.

Para continuar la investigación con las rutas actuales:

1. Con una arena cargada, ejecutar `ValidarRutaPartida.lua` para contrastar dominio, clases y campos.
2. Ejecutar `RegistrarRutas.lua` para registrar cambios de modo, partida, GM y Game Time. También puede iniciarse desde el menú; GM inválido durante menú/carga no demuestra que la ruta esté rota.
3. Ejecutar `LeerEstadisticas.lua` para una lectura puntual del tiempo acumulado.

Para investigar splits por fases, ejecutar `RegistrarFases.lua` **con una arena cargada**. Busca referencias a `PawnManager` mediante los campos estáticos de su clase/base y una zona acotada del dominio Mono (primeros `0x40000` bytes), exigiendo un único objeto de la clase. Valida las tablas de `arenaAIPawn` y su `AIPawnController`, y registra `_currentPhaseNumber`, cantidad de fases, modo, dificultad, jefe, GM y tiempo. No escribe memoria ni controla LiveSplit. Necesita que exista `local/research/Registros/`; guarda allí un archivo `fases-<fecha>-<hora>.txt`, incluso si la búsqueda falla, con el detalle de los candidatos. Consulta cada 50 ms y escribe al cambiar fases, objetos o estados, sin registrar todas las variaciones del reloj.

Capturar una fase completada normalmente, muerte/reintento, reinicio de la pelea y victoria final en Carrera y Práctica. Repetir la resolución después de reiniciar Furi. El registro muestra la ubicación del singleton y offsets de campos para investigar una ruta reutilizable; las direcciones de objetos de esa sesión no son punteros de distribución. LAW/Furi ya tiene registros; quedan otras combinaciones por contrastar. El monitor no habilita la opción separada de splits por fases del ASL.

La revisión V3 admite controladores derivados de `AIPawnController` y configuraciones derivadas de `BossFightPhases`, comprobando la jerarquía con Mono y registrando la clase concreta. V2 podía resolver PawnManager y mostrar el controlador pero dejar `phase=nil` al rechazar su clase derivada.

`RegistrarImpactos.lua` investiga el contador de impactos del juego y su integración con Counter de LiveSplit. Ejecutar con una partida cargada. Resuelve `_hits`, `_KO` y `_time` de Statistics mediante Mono, valida clases y registra cambios cada 50 ms en `local/research/Registros/impactos-<fecha>-<hora>.txt`, junto con el total heredado al comienzo del jefe (`startHits`) cuando está disponible. Capturar impactos recibidos, parry, muerte/continuar y transición al siguiente jefe. No cambia memoria ni LiveSplit; el ASL ya incorpora conexión opcional al Counter, pero falta comprobar el vínculo en el layout real del jugador.

Detener cualquier monitor antes de cambiar el proceso adjunto:

```lua
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
```

Los demás archivos conservan etapas anteriores de la búsqueda. `ResolverSesion.lua` guarda candidatos de la sesión; `RegistrarInicio.lua`, `LeerDificultad.lua` y `BuscarReferencias.lua` dependen de esos candidatos. Las herramientas de comparación/anclaje dependen de las referencias obtenidas. Algunas pruebas históricas contienen direcciones de una sesión y requieren adaptación: no reutilizarlas tras reiniciar Furi.

Guardar los nuevos registros en `local/`, que Git ignora. No distribuir los scripts como parte del paquete para jugadores.
