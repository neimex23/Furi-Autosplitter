# Furi Autosplitter — 1.0.0

Español | [English](README.md)

Por **Neimex23**. Versión 1.0.0 para **LiveSplit para Windows**, modo **Extras > Carrera**, dificultades **Furi y Furiosa**, con Práctica opcional. No requiere Cheat Engine, Lua ni modificar el juego.

Esta versión reúne las funciones de beta.8. El número 1.0.0 no amplía la cobertura comprobada; las pruebas pendientes se detallan abajo.

**El último jefe divide automáticamente en resultados de victoria:** Star en Furi, Bernard en Furiosa. Usa el tiempo acumulado del juego sin esperar otra arena ni el resumen final. Este cambio todavía necesita prueba en vivo en Carrera.

## Instalación

1. Extraé el ZIP de la versión o descargá este repositorio en una carpeta permanente. No ejecutes el ASL desde el ZIP.
2. Abrí LiveSplit y cargá tus splits, con un segmento por jefe de la ruta que vas a jugar, incluido el último. El ASL no crea ni reordena los segmentos.
3. En **Edit Layout**, agregá **Control > Scriptable Auto Splitter**. En **Layout Settings**, seleccioná ese componente y elegí `Furi.asl` como **Script Path** (está dentro de `ASL/` si descargaste el repositorio). Si ya tenés ese componente, cambiá su ruta; usá solo un autosplitter para Furi.
4. Activá **Start** y **Split**. Dejá el reset automático desactivado para la primera prueba.
5. Elegí **Compare Against > Game Time** en el menú de LiveSplit y guardá el layout.
6. Abrí Furi y esperá a que el componente muestre `1.0.0 - compatible`. Con LiveSplit en cero, entrá a **Extras > Carrera** y pulsá **START**.

La interfaz del autosplitter, sus opciones y ayudas están en inglés. La documentación está disponible en español e inglés.

## Comportamiento

- Inicia al detectar una partida nueva de Carrera en el primer jefe. Cargar el ASL a mitad de una pelea o en resultados no inicia el timer: volvé al menú e iniciá una Carrera nueva.
- Game Time lee el tiempo acumulado del propio juego. Sigue sus pausas, resultados y cargas; no es un cronómetro de tiempo real con una estimación de las cargas.
- **Momento del split:** marcá **Split on victory results (unchecked: next arena ready)** para dividir en resultados de victoria con el acumulado del juego. Desmarcala para esperar a la siguiente arena lista y usar el total heredado. Por defecto viene desmarcada. Elegí antes de iniciar el intento.
- **The Star solo puede dividir en resultados de victoria**, independientemente de esa opción, porque no hay siguiente arena. El Bernard final de Furiosa y todas las victorias de Práctica también mantienen el split en resultados.
- En muerte/CONTINUAR mantiene el segmento. Historia no dispara acciones automáticas. Práctica está excluida salvo que actives su opción separada.
- Los splits de fases intermedias son opcionales y están desactivados por defecto.
- **Reset opcional:** activá **Reset** y `Reset LiveSplit when starting another Speedrun (experimental)`. Se probó al reiniciar desde pausa y al iniciar otra Carrera desde el menú, durante un intento en curso. Después de terminar una run, reseteá LiveSplit manualmente antes del siguiente intento.
- **Último jefe:** un split al mostrar resultados de victoria (Star en Furi, Bernard en Furiosa), con el tiempo acumulado del juego. El timer termina si ese era tu último segmento.
- **Elegir jefes:** en las opciones del autosplitter, mantené **Boss splits** activado y marcá debajo los jefes que quieras dividir. Todas las casillas vienen activadas; la general permite desactivar todos los splits de jefes. Desmarcar un jefe omite su split automático y el Game Time sigue acumulándose. Adaptá tus segmentos de LiveSplit a los jefes seleccionados: el ASL no salta ni elimina filas. Configuralo antes de iniciar el intento.

## Contadores de impactos y KO (opcionales)

1. Añadí **Counter** al layout. Para impactos, poné **Furi Hits** o **Hits** como texto. Para KO, añadí otro Counter con texto **Furi KO** o **KO**. Acepta mayúsculas/minúsculas y dos puntos al final.
2. Activá **Track received hits in Counter (Furi Hits)** y/o **Track KO in Counter (Furi KO)**. Ambas están desactivadas por defecto. En Práctica, activá también su opción de modo.
3. Si usás solo una métrica, también funciona un único Counter predeterminado (texto **Counter** o vacío). Para impactos y KO juntos, usá dos contadores con sus nombres.

Los contadores muestran los totales acumulados de impactos y KO del juego. Conservan máximos durante lecturas inválidas y vuelven a cero con Start/Reset de LiveSplit o una partida nueva aceptada. Los impactos se conservan tras morir/CONTINUAR y al pasar de jefe. Usa el criterio del juego, no una suma de daño; el juego excluye impactos con parry. Funciona independientemente de las casillas de splits por jefe/fase. Las ediciones manuales de los contadores vinculados se reemplazan mientras el seguimiento está activado; otros contadores no se modifican. Si falta un contador o hay varios nombres coincidentes, no escribe. El log informa linked, not found o ambiguous para cada vínculo.

El registro cubre Chain → Strap en Carrera/Furi: mantuvo 24 impactos durante resultados y carga, con una muerte previa. Falta probar la conexión Counter en vivo y las demás combinaciones.

## Splits por fases (opcional)

Activá **Phase splits (Speedrun and Practice)** para dividir cuando el jefe avanza a la fase siguiente. Mantené activados **Boss splits** y la casilla del jefe; para Práctica, activá también **Practice Mode (split on boss defeat)**. Configurá un segmento de LiveSplit por fase. La última fase usa el split de victoria existente, respetando resultados/siguiente arena; no añade otro split al final. Práctica y The Star terminan en resultados de victoria.

Está desactivada por defecto. Muerte, retroceso del contador y repetición de fases ya contadas no generan otro split. No se reconstruyen avances durante lecturas inválidas ni saltos de varias fases. Para otro intento de Práctica, reseteá LiveSplit y seleccioná una sesión nueva desde el menú. Configurá las opciones antes del intento.

Los registros de memoria confirman el contador de The Chain en dificultad Furi, en Práctica y Carrera, con la misma ruta después de reiniciar Furi. El usuario también reportó splits por fases funcionando y ausencia de split al morir, sin especificar modo, dificultad o jefe. Siguen pendientes las demás combinaciones y una pelea/carrera completa.

## Práctica (opcional, experimental)

Activá **Practice Mode (split on boss defeat)** en las opciones del autosplitter, junto con **Start**, **Split**, la general de jefes y la casilla del jefe que vas a jugar. Esta opción hace el split al derrotar al jefe en el modo Práctica del juego, en los resultados de victoria. Usá un segmento para esa pelea, o uno por fase si activás los splits de fase. Reseteá LiveSplit antes de elegir una nueva Práctica desde el menú del juego.

El timer inicia cuando la arena de esa partida nueva está lista y el reloj es válido. Divide en resultados de victoria para cualquier jefe marcado, usando el tiempo de esa sesión. Cargar el ASL durante una pelea o en resultados no inicia automáticamente. Historia sigue excluida. El reset opcional de Carrera no resetea Práctica. Los reinicios dentro de la misma sesión no se reconocen automáticamente; para otro intento medido, elegí una nueva Práctica desde el menú.

La lógica de Práctica pasó pruebas sintéticas. El 2026-10-07 el usuario también confirmó que Práctica funciona, desmarcar el jefe evita su split y el reloj funciona correctamente. No especificó jefe, dificultad ni personaje. El registro anterior de Star en Práctica modificada solo aporta diagnóstico de memoria/EndScreen; siguen pendientes otras combinaciones y los reinicios dentro de la sesión.

## Compatibilidad y alcance

Probado con LiveSplit **1.8.37** y una instalación de Furi para Windows de Steam. No se probó Linux/Proton, consola ni otras ediciones/builds. El ASL comprueba los dos binarios usados durante la investigación:

| Archivo dentro de Furi | SHA-256 compatible |
| --- | --- |
| `MonoBleedingEdge/EmbedRuntime/mono-2.0-bdwgc.dll` | `47B2F85724C9473182DF93BB5EC11ADCEB07633E00899CFF7138F40349542DFF` |
| `Furi_Data/Managed/Assembly-CSharp.dll` | `303FAA314E027A44746B8D4400506118F419115F345F163AFAA74DED3FEA8465` |

Si aparece **UNSUPPORTED BUILD**, las acciones quedan desactivadas. Reportá la build y los hashes; no quites esa comprobación para forzar offsets de otra versión. El mensaje puede verse en la versión del script mientras está conectado al juego.

**Probado en vivo:** inicio, reloj y pausa, resultados de Chain, split al cargar Strap, continuidad del reloj, muerte/CONTINUAR en Strap y reinicios en Furi. En Furiosa se confirmaron inicio, reinicio y reloj/pausa. Se compila y se reproducen registros con el componente ASL instalado, incluyendo duplicados, cargas, datos inválidos y exclusión de Práctica.

**Pendiente:** una carrera completa, todos los jefes intermedios, victoria/transición registrada en Furiosa, cobertura detallada de combinaciones DLC/personaje y comprobación en vivo del nuevo split de victoria final. La prueba de MOTHERSHIP en Práctica con el modo invencible del juego y salto de fases es solo diagnóstica.

No interpretar esta versión como una validación completa de todos esos casos.

**Reporte del usuario (2026-10-07):** Onnamusha funcionó bien en Furi y Furiosa después de entregar beta.2. El usuario confirmó inicio, reloj y splits intermedios; no probó el último split.

**DLC: reportado como correcto.** El 2026-10-07 el usuario confirmó que Bernard y The Flame funcionan bien. Es evidencia en vivo reportada por el jugador; no especificó modo, dificultad ni comprobaciones exactas del tiempo.

## Qué probar y cómo reportarlo

Primero probá START, unos segundos de pelea y pausa. Con las opciones predeterminadas, verificá resultados intermedios sin split, paso al siguiente jefe con un solo split y continuidad del Game Time. Si elegiste dividir en resultados o por fases, verificá esos eventos según la configuración. Después seguí la ruta y anotá cualquier segmento omitido o duplicado. No hace falta Cheat Engine para probar esta versión.

Usá `REPORTAR-ERROR.md` para registrar dificultad, jefe, versión, pasos, comportamiento y tiempos. Podés responder en español o inglés. Indicá si usaste invencibilidad, salto de fases, trainer o modificaciones. Una captura de resultados y LiveSplit, o un video breve del fallo, ayuda a comparar.

Si no inicia: revisá la versión compatible, Start activado, proceso `Furi.exe`, modo Carrera y que el ASL estuviera cargado antes de START. Si LiveSplit sigue contando al pausar Furi, revisá **Compare Against > Game Time**. No recargues ni edites el ASL durante un intento que quieras medir: se pierde el estado de seguimiento del script.

Este paquete no incluye ejecutables, DLL del juego, herramientas de Cheat Engine, datos guardados ni rutas de la PC usada para desarrollarlo. Compartí el ZIP completo para conservar las instrucciones y limitaciones.

## Repositorio

Para continuar o ampliar el proyecto, empezá por [el contexto y la evidencia actuales](docs/CONTEXT.md) y [la guía de contribución](CONTRIBUTING.md). [AGENTS.md](AGENTS.md) ofrece el mismo punto de entrada a agentes de programación. Estos documentos explican el comportamiento acordado de tiempos/splits, rutas de memoria, escenarios probados, supuestos pendientes y próximas investigaciones. Cada guía enlaza su versión en inglés.

- [ASL/Furi.asl](ASL/Furi.asl): el autosplitter; fuente usada para generar los ZIPs.
- [README.md](README.md): instalación y hashes de compatibilidad en inglés.
- [CHANGELOG.es.md](CHANGELOG.es.md): historial de versiones.
- [REPORTAR-ERROR.md](REPORTAR-ERROR.md): plantilla de reporte, también disponible al abrir un issue de GitHub.
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md): arquitectura, verificación y comandos de empaquetado.
- [docs/PUBLISHING.md](docs/PUBLISHING.md): publicar una versión, registrarla en LiveSplit y distribuir actualizaciones.
- `tests/`: compilación, reproducción de registros/casos sintéticos y registro Chain → Strap.
- `tools/`: diagnósticos opcionales de Cheat Engine, utilidades de inspección y empaquetado.

Los ZIPs generados van en `dist/`. La investigación local y los volcados IL del juego van en `local/`. Ambas carpetas están excluidas de Git.
