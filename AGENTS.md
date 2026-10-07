# Contexto para agentes y colaboradores

Español | [English](AGENTS.en.md)

Este repositorio contiene un autosplitter de LiveSplit para Furi. Antes de cambiar el comportamiento, leer:

1. `docs/CONTEXT.md`: decisiones, estado actual, evidencia, limitaciones y próximos pasos.
2. `docs/DEVELOPMENT.md`: herramientas y comandos de verificación.
3. `CONTRIBUTING.md`: cómo investigar, ampliar y documentar una contribución.

La implementación de referencia es `ASL/Furi.asl`. La versión actual es `1.0.0`. El README y LEEME son las instrucciones para jugadores; el contexto de desarrollo se mantiene en `docs/CONTEXT.md`.

## Comportamiento acordado

- Alcance actual: Extras > Carrera / Speedrun y Práctica opcional, dificultades Furi y Furiosa / Furier.
- Game Time procede del cronómetro acumulado del juego (`Statistics._time`).
- `hitCounter` y `koCounter` son opciones independientes desactivadas por defecto. Sincronizan Statistics._hits/_KO con Counter rotulados Furi Hits/Hits y Furi KO/KO, sin distinguir mayúsculas. Un único Counter predeterminado se admite si solo hay una métrica habilitada. Conservan máximos ante huecos/lecturas atrasadas y limpian en Start/Reset/nueva partida. No dependen de las casillas de splits. Otros contadores no se modifican.
- `phaseSplits` es opcional, desactivada por defecto, para Carrera y Práctica habilitada. Respeta las casillas de jefes; fases intermedias por avance del contador y última fase por el split de victoria existente. Ruta y avance observados en LAW/Furi en ambos modos y tras reiniciar. El jugador reportó splits por fases funcionando y ausencia de split al morir sin especificar la combinación; otros jefes/Furiosa y cobertura en vivo más amplia siguen pendientes.
- Por defecto la victoria queda pendiente en resultados y divide con `Chrono._initialTime` al quedar lista la siguiente arena. `splitOnResults` permite dividir en resultados con Statistics acumulado válido.
- Por pedido del usuario, el último jefe divide en resultados de victoria: MOTHERSHIP en cualquier dificultad, BERNARD en Furiosa (2), usando Statistics._time. Identificación corroborada por inspección del juego; pendiente prueba en vivo de Carrera final.
- Historia no genera acciones automáticas. Práctica está desactivada por defecto; al habilitarla, inicia en la arena lista de una partida nueva y divide en resultados de victoria del jefe seleccionado. El reset automático sigue siendo solo de Carrera, opcional y desactivado por defecto.
- Mantener la opción general de splits y las casillas por jefe, todas activadas por defecto. Omitir un jefe consume su evento sin alterar el reloj acumulado ni saltar filas del layout.
- The Star siempre divide en resultados, independientemente de la opción de timing. Las etiquetas, ayudas y mensajes del ASL permanecen en inglés por elección del usuario; la documentación está en español e inglés. Conservar las claves de settings existentes.
- Conservar por defecto estos acuerdos. Al ampliar el alcance, describir explícitamente el nuevo comportamiento y su evidencia.

## Criterios de trabajo

- Mantener la validación de hashes. Una build nueva requiere corroborar sus rutas y pruebas; quitar el filtro no demuestra compatibilidad.
- No convertir direcciones de heap de un registro en punteros permanentes. Tampoco interpretar una lectura inválida, carga o salida del proceso como victoria.
- Distinguir prueba en vivo, registro, caso sintético e hipótesis. No afirmar una carrera completa ni precisión subsegundo a partir de lo comprobado hasta ahora.
- El test de MOTHERSHIP en Práctica usó invencibilidad propia del juego y salto de fases. Sirve como diagnóstico; no valida el cierre de Carrera.
- Si cambia lógica ASL, compilar y ejecutar las verificaciones relevantes descritas en `docs/DEVELOPMENT.md`; indicar cualquier comprobación que no se pudo realizar. Cambios solo de documentación requieren verificar coherencia y enlaces.
- Actualizar ambas versiones de idioma de `docs/CONTEXT.md` con decisiones nuevas, evidencia obtenida y próximos pasos. Para una versión distribuible, sincronizar versión del ASL, documentos públicos y changelogs.
- Mantener `ASL/Furi.asl` como única fuente de la distribución. Generar ZIPs con `tools/Empaquetar.ps1`.
- Conservar registros privados, volcados IL, DLL y layouts personales fuera de los archivos públicos. `local/` y `dist/` están excluidos de Git.

La carpeta local puede contener `local/research/INVESTIGACION.md`, un historial cronológico con hipótesis y descripciones ya superadas. No existe necesariamente en otro clon. El contexto público debe bastar para continuar el proyecto; no usar una frase antigua del historial como estado actual.
