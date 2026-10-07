# Contexto para agentes y colaboradores

Este repositorio contiene un autosplitter de LiveSplit para Furi. Antes de cambiar el comportamiento, leer:

1. `docs/CONTEXT.md`: decisiones, estado actual, evidencia, limitaciones y próximos pasos.
2. `docs/DEVELOPMENT.md`: herramientas y comandos de verificación.
3. `CONTRIBUTING.md`: cómo investigar, ampliar y documentar una contribución.

La implementación de referencia es `ASL/Furi.asl`. La versión actual es `0.1.0-beta.1`. El README y LEEME son las instrucciones para jugadores; el contexto de desarrollo se mantiene en `docs/CONTEXT.md`.

## Comportamiento acordado

- Alcance actual: Extras > Carrera / Speedrun, dificultades Furi y Furiosa / Furier.
- Game Time procede del cronómetro acumulado del juego (`Statistics._time`).
- La victoria queda pendiente en resultados; el split se hace cuando está lista la siguiente arena y usa el total heredado por `Chrono._initialTime`.
- El último split es manual hasta obtener evidencia del cierre real de Carrera.
- Historia y Práctica no generan acciones automáticas. El reset automático es opcional y está desactivado por defecto.
- Conservar por defecto estos acuerdos. Al ampliar el alcance, describir explícitamente el nuevo comportamiento y su evidencia.

## Criterios de trabajo

- Mantener la validación de hashes. Una build nueva requiere corroborar sus rutas y pruebas; quitar el filtro no demuestra compatibilidad.
- No convertir direcciones de heap de un registro en punteros permanentes. Tampoco interpretar una lectura inválida, carga o salida del proceso como victoria.
- Distinguir prueba en vivo, registro, caso sintético e hipótesis. No afirmar una carrera completa ni precisión subsegundo a partir de lo comprobado hasta ahora.
- El test de MOTHERSHIP en Práctica usó invencibilidad propia del juego y salto de fases. Sirve como diagnóstico; no valida el cierre de Carrera.
- Si cambia lógica ASL, compilar y ejecutar las verificaciones relevantes descritas en `docs/DEVELOPMENT.md`; indicar cualquier comprobación que no se pudo realizar. Cambios solo de documentación requieren verificar coherencia y enlaces.
- Actualizar `docs/CONTEXT.md` con decisiones nuevas, evidencia obtenida y próximos pasos. Para una versión distribuible, sincronizar versión del ASL, documentos públicos y changelog.
- Mantener `ASL/Furi.asl` como única fuente de la distribución. Generar ZIPs con `tools/Empaquetar.ps1`.
- Conservar registros privados, volcados IL, DLL y layouts personales fuera de los archivos públicos. `local/` y `dist/` están excluidos de Git.

La carpeta local puede contener `local/research/INVESTIGACION.md`, un historial cronológico con hipótesis y descripciones ya superadas. No existe necesariamente en otro clon. El contexto público debe bastar para continuar el proyecto; no usar una frase antigua del historial como estado actual.
