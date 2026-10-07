# Furi Autosplitter — 0.1.0-beta.1

Beta para pruebas comunitarias en **LiveSplit para Windows**, modo **Extras > Carrera**, dificultades **Furi y Furiosa**. No requiere Cheat Engine, Lua ni modificar el juego.

**El último split de Carrera es MANUAL en esta beta.** Al terminar el último jefe, comprobá que el reloj esté detenido en resultados y usá tu tecla de split. Todavía no está validada la detección de la pantalla final de Carrera.

## Instalación

1. Extraé el ZIP de la beta o descargá este repositorio en una carpeta permanente. No ejecutes el ASL desde el ZIP.
2. Abrí LiveSplit y cargá tus splits, con un segmento por jefe de la ruta que vas a jugar, incluido el último. El ASL no crea ni reordena los segmentos.
3. En **Edit Layout**, agregá **Control > Scriptable Auto Splitter**. En **Layout Settings**, seleccioná ese componente y elegí `Furi.asl` como **Script Path** (está dentro de `ASL/` si descargaste el repositorio). Si ya tenés ese componente, cambiá su ruta; usá solo un autosplitter para Furi.
4. Activá **Start** y **Split**. Dejá el reset automático desactivado para la primera prueba.
5. Elegí **Compare Against > Game Time** en el menú de LiveSplit y guardá el layout.
6. Abrí Furi y esperá a que el componente muestre `0.1.0-beta.1 - compatible`. Con LiveSplit en cero, entrá a **Extras > Carrera** y pulsá **START**.

La configuración de instalación usa los nombres de la interfaz en inglés. Las dos opciones propias del ASL están en español.

## Comportamiento

- Inicia al detectar una partida nueva de Carrera en el primer jefe. Cargar el ASL a mitad de una pelea o en resultados no inicia el timer: volvé al menú e iniciá una Carrera nueva.
- Game Time lee el tiempo acumulado del propio juego. Sigue sus pausas, resultados y cargas; no es un cronómetro de tiempo real con una estimación de las cargas.
- Guarda la victoria y hace **un split cuando la siguiente arena queda lista**. No divide al aparecer los resultados ni por cambiar de fase. Usa el total que el nuevo jefe hereda del anterior como tiempo del split.
- En muerte/CONTINUAR mantiene el segmento. Historia y Práctica no disparan acciones automáticas.
- **Reset opcional:** activá **Reset** y `Reiniciar LiveSplit al iniciar otra Carrera (experimental)`. Se probó al reiniciar desde pausa y al iniciar otra Carrera desde el menú, durante un intento en curso. Después de terminar una run, reseteá LiveSplit manualmente antes del siguiente intento.
- **Último jefe:** split manual. Una vez hecho, el timer termina si ese era tu último segmento.

## Compatibilidad y alcance

Probado con LiveSplit **1.8.37** y una instalación de Furi para Windows de Steam. No se probó Linux/Proton, consola ni otras ediciones/builds. El ASL comprueba los dos binarios usados durante la investigación:

| Archivo dentro de Furi | SHA-256 compatible |
| --- | --- |
| `MonoBleedingEdge/EmbedRuntime/mono-2.0-bdwgc.dll` | `47B2F85724C9473182DF93BB5EC11ADCEB07633E00899CFF7138F40349542DFF` |
| `Furi_Data/Managed/Assembly-CSharp.dll` | `303FAA314E027A44746B8D4400506118F419115F345F163AFAA74DED3FEA8465` |

Si aparece **BUILD NO COMPATIBLE**, las acciones quedan desactivadas. Reportá la build y los hashes; no quites esa comprobación para forzar offsets de otra versión. El mensaje puede verse en la versión del script mientras está conectado al juego.

**Probado en vivo:** inicio, reloj y pausa, resultados de Chain, split al cargar Strap, continuidad del reloj, muerte/CONTINUAR en Strap y reinicios en Furi. En Furiosa se confirmaron inicio, reinicio y reloj/pausa. Se compila y se reproducen registros con el componente ASL instalado, incluyendo duplicados, cargas, datos inválidos y exclusión de Práctica.

**Pendiente:** una carrera completa, todos los jefes intermedios, victoria/transición registrada en Furiosa, DLC/personajes adicionales y cierre automático del último jefe. La prueba de MOTHERSHIP en Práctica con el modo invencible del juego y salto de fases es solo diagnóstica.

## Qué probar y cómo reportarlo

Primero probá START, unos segundos de pelea y pausa. Después verificá resultados sin split, paso al siguiente jefe con un solo split y continuidad del Game Time. Si eso funciona, seguí la ruta y anotá cualquier segmento omitido o duplicado. No hace falta Cheat Engine para probar esta beta.

Usá `REPORTAR-ERROR.md` para registrar dificultad, jefe, versión, pasos, comportamiento y tiempos. Indicá si usaste invencibilidad, salto de fases, trainer o modificaciones. Una captura de resultados y LiveSplit, o un video breve del fallo, ayuda a comparar.

Si no inicia: revisá la versión compatible, Start activado, proceso `Furi.exe`, modo Carrera y que el ASL estuviera cargado antes de START. Si LiveSplit sigue contando al pausar Furi, revisá **Compare Against > Game Time**. No recargues ni edites el ASL durante un intento que quieras medir: se pierde el estado de seguimiento del script.

Este paquete no incluye ejecutables, DLL del juego, herramientas de Cheat Engine, datos guardados ni rutas de la PC usada para desarrollarlo. Compartí el ZIP completo para conservar las instrucciones y limitaciones.
