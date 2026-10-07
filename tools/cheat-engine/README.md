# Diagnósticos de Cheat Engine

Herramientas opcionales de investigación en Lua para Cheat Engine con Mono. No son necesarias para usar el ASL. Consultan memoria del juego; algunas realizan escaneos y pueden tardar. Los offsets de ruta corresponden a la build de la beta.

Con Cheat Engine adjunto a `Furi.exe`, abrir la ventana Lua y cargar el archivo elegido con `dofile([[ruta completa al archivo.lua]])`, usando la ubicación de este repositorio.

Para continuar la investigación con las rutas actuales:

1. Con una arena cargada, ejecutar `ValidarRutaPartida.lua` para contrastar dominio, clases y campos.
2. Ejecutar `RegistrarRutas.lua` para registrar cambios de modo, partida, GM y Game Time. También puede iniciarse desde el menú; GM inválido durante menú/carga no demuestra que la ruta esté rota.
3. Ejecutar `LeerEstadisticas.lua` para una lectura puntual del tiempo acumulado.

Detener cualquier monitor antes de cambiar el proceso adjunto:

```lua
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
```

Los demás archivos conservan etapas anteriores de la búsqueda. `ResolverSesion.lua` guarda candidatos de la sesión; `RegistrarInicio.lua`, `LeerDificultad.lua` y `BuscarReferencias.lua` dependen de esos candidatos. Las herramientas de comparación/anclaje dependen de las referencias obtenidas. Algunas pruebas históricas contienen direcciones de una sesión y requieren adaptación: no reutilizarlas tras reiniciar Furi.

Guardar los nuevos registros en `local/`, que Git ignora. No distribuir los scripts como parte de la beta para jugadores.
