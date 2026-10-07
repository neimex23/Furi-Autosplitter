# Cómo contribuir

Para entender el estado del proyecto, empezar por [docs/CONTEXT.md](docs/CONTEXT.md). Allí se separan las decisiones vigentes, pruebas en vivo, reproducciones e hipótesis. [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) explica cómo ejecutar las herramientas.

## Reportar o comprobar comportamiento

No se necesita programar ni usar Cheat Engine para probar la beta. Usar [REPORTAR-ERROR.md](REPORTAR-ERROR.md) o la plantilla de issue del repo. Registrar versión del ASL y LiveSplit, build del juego, modo, dificultad, personaje/DLC, opciones habilitadas, pasos y reloj del juego frente a Game Time.

Para una transición, observar resultados y siguiente arena: debe detenerse según el reloj del juego, no dividir en resultados, dividir una vez cuando la arena esté lista y continuar el total acumulado. Indicar si se usó invencibilidad propia del juego, salto de fases o modificaciones.

Comparar **Game Time** en LiveSplit. Real Time puede continuar mientras el cronómetro del juego está detenido. Después de una run terminada, resetear manualmente antes del intento siguiente. Evitar recargar el ASL durante la run que se está midiendo.

## Investigar un evento o una build

1. Definir el caso concreto y el resultado esperado: por ejemplo, cierre de Carrera Furiosa después de su último jefe.
2. Registrar hashes, modo, dificultad y revisión del ASL. Una build con hashes diferentes necesita sus propias rutas validadas.
3. Usar `tools/cheat-engine/ValidarRutaPartida.lua` con una arena cargada y `RegistrarRutas.lua` para el recorrido. Los Lua son herramientas de investigación opcionales; leer su README.
4. Capturar antes, durante y después del evento. Registrar también un caso parecido que no deba dispararlo: carga, muerte, salida al menú, reinicio o Práctica.
5. Contrastar clases y campos, y repetir las rutas en un proceso nuevo. Conservar el registro crudo en `local/`; añadir evidencia pública pertinente sin rutas personales ni volcados del código del juego.

El monitor consulta cada 100 ms y escribe al cambiar el estado descrito. No registra todos los frames ni todas las variaciones del reloj. Las marcas `[Xs]` son tiempo transcurrido desde iniciar el monitor, no Game Time. Para precisión de eventos, complementar con observaciones del juego o captura de video.

Nunca tratar una dirección encontrada en un registro como un puntero reutilizable. Un objeto inválido puede ser parte de una carga o estar obsoleto. Una exportación o diferencia de direcciones es una pista: requiere contraste del destino y del comportamiento.

## Cambiar el ASL

Modificar `ASL/Furi.asl`, que es la única fuente de la distribución. Mantener los flujos comprobados: inicio de Carrera, reloj del juego, split diferido, muerte/CONTINUAR, deduplicación y reset opcional. Los cambios de modalidad o de semántica deben describirse en la propuesta.

Para nuevas capacidades:

| Ampliación | Trabajo necesario |
| --- | --- |
| Cierre automático | Señal observada en Carrera final, tiempo correcto, una sola división y exclusión de menú/carga/reinicio/Práctica |
| Otra build | Hashes, offsets/rutas y tipos corroborados tras reiniciar, regresiones y prueba en vivo; conservar el filtro de compatibilidad |
| DLC/personaje/ruta | IDs y orden efectivo, arenas omitidas o repetidas, continuidad del reloj y deduplicación adecuada |
| Historia o Práctica | Definir START, reset, límite del segmento y Game Time propios; separar la lógica de Carrera y comprobar que no interfiera |
| Otra plataforma | Identificar runtime, arquitectura y acceso a memoria; no asumir que las rutas de Windows sirven |

Añadir casos de regresión que reproduzcan el problema y los falsos positivos relevantes. El harness actual está en `tests/ReproducirRegistro.cs`; utiliza el componente real de LiveSplit con muestras grabadas/sintéticas y un timer aislado. Su `init` necesita Furi compatible abierto. La reproducción valida lógica; las nuevas rutas necesitan pruebas en vivo.

Ejecutar compilación y reproducción siguiendo [DEVELOPMENT.md](docs/DEVELOPMENT.md). Anotar qué comprobaciones pasaron, la instalación usada y cualquier prueba que no se pudo ejecutar. Un cambio solo de documentación puede verificarse con coherencia de contenido y enlaces.

## Entregar una contribución

Describir el problema, el nuevo comportamiento, la evidencia, las verificaciones y la cobertura pendiente. La plantilla de pull request ayuda a dejar ese contexto. Para un cambio de comportamiento, actualizar `docs/CONTEXT.md`; para una release, actualizar versión y documentos públicos, `CHANGELOG.md` y generar el ZIP con `tools/Empaquetar.ps1`.

Conservar la distinción entre «reportado por el jugador», «observado en registro», «caso sintético» e «hipótesis». Documentar datos nuevos sin convertirlos en garantías más amplias que la prueba.

Publicar únicamente fuentes, documentación y registros pertinentes propios. DLL, volcados IL del juego, partidas, layouts personales e investigación privada permanecen en `local/`. Los paquetes generados van en `dist/` y pueden adjuntarse por separado a una release.
