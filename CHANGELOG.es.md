Español | [English](CHANGELOG.md)

# 1.0.0 — 2026-10-07

- Versión preparada desde beta.8, con la firma de Neimex23 y la URL del proyecto dentro del ASL.
- Conserva Carrera/Furi/Furiosa, Práctica opcional, selección de jefes, momento del split en resultados/siguiente arena, fases opcionales, contadores de impactos/KO y reset opcional de Carrera. Sin cambios de lógica de memoria ni tiempos.
- Sincroniza metadatos e instrucciones, añade una guía de alta/actualización en LiveSplit e incluye LICENSE en el ZIP generado.
- Documentación pública completa en español e inglés, con enlaces entre idiomas y plantillas bilingües. El ASL conserva su interfaz en inglés por elección del usuario.
- Se mantienen los límites de cobertura: faltan carreras completas, contraste en vivo del tiempo de victoria final, vínculo Counter en vivo y combinaciones adicionales de jefes/builds. La versión 1.0.0 no certifica esos casos pendientes.

# 0.1.0-beta.8 — 2026-10-07

- Añadida la opción **Track KO in Counter (Furi KO)**, independiente de impactos y splits, usando el total acumulado de KO de Statistics del juego.
- El vínculo Counter acepta Furi Hits/Hits y Furi KO/KO sin distinguir mayúsculas, incluidos dos puntos finales. Se admite un único Counter predeterminado cuando solo una métrica está activada. Dos métricas requieren contadores con nombre.
- Los vínculos ausentes o ambiguos devuelven fallo y registran su estado. Otros contadores no se modifican.
- El jugador reportó que los impactos de beta.7 no se actualizaban en el layout abierto; la causa exacta todavía no está confirmada. Beta.7 exigía una etiqueta exacta e ignoraba silenciosamente la ausencia de coincidencias. Los vínculos ampliados y KO todavía requieren comprobación en el layout real.

# 0.1.0-beta.7 — 2026-10-07

- Opción **Track received hits in Counter (Furi Hits)**, desactivada por defecto. Sincroniza la estadística acumulada de impactos recibidos con un Counter de LiveSplit rotulado exactamente Furi Hits, independientemente de los filtros de splits por jefe/fase.
- Conserva el total aceptado durante muestras inválidas o atrasadas; vuelve a cero con Start/Reset o una nueva sesión aceptada. No modifica contadores ausentes o ambiguos.
- Usa la API SetCount de Counter, sin simular hotkeys. Los cambios manuales al contador vinculado se reemplazan mientras está habilitado; los demás contadores no se modifican.
- El registro LAW → NEMESIS en Carrera/Furi conservó 24 impactos, incluida una muerte previa. El jugador también confirmó splits por fases y ausencia de split al morir. Siguen pendientes la integración Counter en el layout real y otros modos/dificultades.

# 0.1.0-beta.6 — 2026-10-07

- Añadida la opción **Phase splits (Speedrun and Practice)**, desactivada por defecto, respetando las casillas general y por jefe.
- Las fases intermedias dividen ante un avance del contador observado directamente, con el acumulado del reloj del juego. La última fase usa el split de victoria y su momento existentes, sin split adicional.
- Retrocesos, fases repetidas, muestras inválidas y saltos de varias fases no generan splits reconstruidos o duplicados. Práctica sigue requiriendo su propia opción y una sesión nueva para cada intento medido.
- Ruta de memoria y avance de fase registrados para The Chain en dificultad Furi, en Práctica y Carrera, con la misma ruta después de reiniciar Furi. En esta revisión quedaban pendientes la comprobación en vivo de los eventos de fase en LiveSplit, otros jefes y Furiosa.

# 0.1.0-beta.5 — 2026-10-07

- Opciones, ayudas, estado de compatibilidad y mensajes visibles del autosplitter traducidos al inglés; se conservan las claves de settings.
- Práctica pasa a llamarse **Practice Mode (split on boss defeat)** para aclarar que divide al ganar al jefe en el modo Práctica del juego; sin cambios de comportamiento.
- Añadida **Split on victory results (unchecked: next arena ready)**. Desactivada por defecto, conservando splits con tiempo heredado después de cargar la siguiente arena.
- The Star siempre divide en resultados de victoria; Bernard final de Furiosa y Práctica también conservan el split en resultados.
- Ambos momentos respetan la selección de jefes y evitan duplicados. El split en resultados usa el acumulado aceptado del reloj del juego.
- DLC reportado como correcto por el jugador: Bernard y The Flame. También reportó Práctica, exclusión de jefes y reloj funcionando; la cobertura completa de rutas/tiempos sigue siendo parcial.

# 0.1.0-beta.4 — 2026-10-07

- Práctica automática opcional, desactivada por defecto: inicia en la arena lista de una partida nueva y divide en resultados de victoria del jefe seleccionado.
- Usa las mismas casillas por jefe y el tiempo de Statistics de la sesión; Historia sigue excluida y el reset automático permanece solo en Carrera.
- Limpieza de eventos al cambiar de modo, incluso si la partida conserva el mismo puntero.
- Casos sintéticos para ambas dificultades, carga, reloj/pausa, muerte/fases/tiempo inválido, deduplicación y casillas. En esta revisión faltaba prueba en vivo de Práctica normal/Onnamusha.
- Para repetir Práctica, reset manual de LiveSplit y nueva selección desde menú; reinicios dentro de la misma sesión pendientes.

# 0.1.0-beta.3 — 2026-10-07

- Casillas individuales por jefe debajo de la opción general existente. Todas activadas por defecto; la general desactiva todos los splits de jefes.
- Un jefe desmarcado omite su split, conserva el acumulado actual y limpia su victoria pendiente; no modifica las filas de segmentos de LiveSplit.
- Nombres corroborados con la localización del juego. Corrección: HORN es The Beat; BERNARD es Bernard. La condición final de beta.2 no cambia.
- Regresiones sintéticas para las 12 casillas, prioridad de la general, reloj y limpieza de eventos omitidos.
- Reporte del usuario: inicio, reloj y splits intermedios con Onnamusha en Furi y Furiosa. Cierre final aún pendiente de prueba en vivo.

# 0.1.0-beta.2 — 2026-10-07

- Por pedido del usuario, split de victoria final en resultados: Star (MOTHERSHIP) en Furi y Bernard (BERNARD) en Furiosa, según la identificación inspeccionada en el juego. La documentación original decía «Beat» para BERNARD; esa etiqueta se corrigió en beta.3.
- Usa el acumulado válido de Statistics._time; los jefes intermedios conservan el total heredado al cargar la siguiente arena.
- Conserva hashes, exclusión de Historia/Práctica, observación previa del jefe activo y prevención de duplicados.
- Regresiones sintéticas de victoria final, dificultad incorrecta, muerte/fases, datos inválidos, pérdida de foco, duplicados y splits desactivados. Pendiente prueba final en Carrera real.

# 0.1.0-beta.1 — 2026-10-06

Primera beta preparada para compartir y hacer pruebas comunitarias.

- Inicio de Carrera y Game Time leídos desde memoria del juego, sin Cheat Engine.
- Split pendiente de victoria al quedar lista la siguiente arena.
- Tiempo del split tomado del total heredado por el Chrono del nuevo jefe.
- Reset automático opcional, desactivado por defecto.
- Exclusión de Historia y Práctica; limpiar victoria pendiente al abandonar Carrera.
- Validación SHA-256 de la build investigada y estado de compatibilidad visible.
- Eliminada la condición especulativa `gameState == 17`: último split manual.
- Instrucciones español/inglés y plantilla de reporte, sin rutas locales ni archivos del juego.

Ver [LEEME.md](LEEME.md) / [README.md](README.md) para pruebas realizadas y cobertura pendiente.
