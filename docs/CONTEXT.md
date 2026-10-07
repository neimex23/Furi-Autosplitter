# Contexto y punto de continuación

Español | [English](CONTEXT.en.md)

Actualizado: **2026-10-07**, versión **1.0.0**. Este documento resume el estado vigente para continuar el proyecto sin necesitar la conversación original ni las notas privadas. La fuente ejecutable es [ASL/Furi.asl](../ASL/Furi.asl). Los comandos están en [DEVELOPMENT.md](DEVELOPMENT.md).

## Objetivo y acuerdos

El proyecto comenzó investigando memoria con Cheat Engine y pasó a un ASL que LiveSplit puede usar sin Cheat Engine. El primer alcance es **Extras > Carrera**, Furi y Furiosa, con un segmento por jefe de la ruta elegida por el jugador.

El usuario eligió el cronómetro acumulado del juego como **Game Time** y el split al cargar la siguiente arena. Una revisión inicial dividía al mostrar resultados y contaba tiempo real; ese comportamiento fue reemplazado. Por defecto, para los jefes intermedios el ASL guarda la victoria en resultados, espera la siguiente arena y divide usando el total heredado del jefe anterior. Desde beta.5 se puede elegir dividir en resultados.

La versión actual admite inicio automático y reset opcional de un intento en curso. Por pedido del usuario, desde beta.2 el último jefe divide en resultados de victoria: Star en Furi, Bernard en Furiosa. Los demás conservan por defecto el split en la siguiente arena. La cobertura sigue siendo parcial; aún no hay una carrera completa validada.

## Preparación de 1.0.0

El 2026-10-07 el usuario pidió preparar la versión 1.0 con su firma y explicar el alta en LiveSplit y las actualizaciones. Después actualizó el repositorio a beta.8; esa revisión es la base de 1.0.0. Se añadió `Author: Neimex23` y el enlace del proyecto a la cabecera, y se sincronizaron versión, mensajes y documentación. No cambian rutas, hashes, lógica, claves de opciones ni valores predeterminados de beta.8.

Verificación de 1.0.0: compilación con el componente instalado de LiveSplit 1.8.37 y reproducción completa con `init` real y hashes compatibles del proceso Furi PID 10676. La lectura del proceso requirió salir del sandbox después de un error de acceso. Pasaron el registro Chain → Strap y los casos sintéticos de Carrera, Práctica, 12 casillas, resultados/siguiente arena, finales Furi/Furiosa, fases, Hits/KO con Counter real en layout aislado y exclusión de escritura con build no compatible. No se modificó el juego ni el timer abierto. No hubo una nueva carrera ni prueba del layout real: siguen pendientes el cierre final en vivo, los vínculos Counter del jugador y las demás combinaciones documentadas.

La distribución se genera con `tools/Empaquetar.ps1` y ahora incluye LICENSE. [PUBLISHING.md](PUBLISHING.md) describe la publicación y actualización; [livesplit-registration.xml](livesplit-registration.xml) propone la entrada Furi con URL estable a `main/ASL/Furi.asl`. En la consulta del catálogo oficial no se encontró una entrada exacta para Furi. Esta preparación es local: no se creó release, tag ni PR de alta. El número 1.0.0 no convierte los casos pendientes en pruebas completadas.

El usuario pidió después documentación en español/inglés y eligió explícitamente mantener el ASL en inglés. Las guías públicas tienen versiones enlazadas por idioma; las plantillas de reporte/PR son bilingües. Se conservan identificadores, comandos, nombres de archivo y registros originales. Se mantiene el texto original de LICENSE. Las próximas actualizaciones de documentación deben mantener ambos idiomas coherentes. Esta revisión documental no cambia el comportamiento del ASL ni añade evidencia en vivo.

Verificación de la traducción: enlaces locales y bloques de código completos, mismas secciones en cada par traducido y mismos offsets, fechas, IDs de proceso y valores decimales del contexto ES/EN. El reporte coincide con la plantilla de issue. ZIP regenerado con ambos changelogs; comprobados contenido, hashes del manifiesto, enlaces internos e identidad del ASL distribuido. No se repitieron compilación ni regresiones de lógica: el ASL conserva la revisión ya validada.

## Estado comprobado

| Flujo | Evidencia disponible | Límite de la comprobación |
| --- | --- | --- |
| START de Carrera Furi | Usuario probó inicio en LiveSplit; reproducción desde menú | No se midió el instante de START con precisión subsegundo |
| Reloj, pausa y pérdida de foco | Usuario contrastó HUD/LiveSplit y registros de memoria | HUD redondea a segundos; coincidencia visual no acredita precisión subsegundo |
| Resultados de Chain → Strap | Usuario confirmó reloj detenido, sin split en resultados, un split al cargar Strap y continuidad del tiempo | La revisión pública ajustó después el límite exacto del split a `Chrono._initialTime`; ese ajuste pasó reproducción, pendiente contraste en vivo |
| Muerte y CONTINUAR en Strap | Usuario confirmó que permaneció en el segmento y los relojes parecían correctos | No cubre todos los jefes ni todas las variantes de muerte |
| Reiniciar Carrera desde pausa y nueva Carrera desde menú | Usuario confirmó ambos caminos con reset opcional activado | Probado durante un intento en curso; después de terminar, usar reset manual |
| Furiosa | Usuario confirmó inicio, reinicio, reloj y pausa | Falta victoria/transición registrada en Furiosa |
| Onnamusha en Furi y Furiosa | El 2026-10-07 el usuario reportó que probó ambas dificultades con Onnamusha y «va bien», después de entregar beta.2 | Confirmó inicio, reloj y splits intermedios; no probó el último split. Sin registro o contraste de tiempos aportado para estas pruebas |
| DLC: Bernard y The Flame | El 2026-10-07 el usuario confirmó que ambos funcionan bien y pidió marcar el DLC como correcto | Reporte en vivo del jugador; no especificó modo, dificultad ni eventos/tiempos concretos. No demuestra cierre final de Carrera ni todas las combinaciones |
| Exclusión de Práctica desactivada y limpieza de victoria pendiente | Caso sintético con el componente ASL instalado | El diagnóstico en vivo de Práctica no fue una prueba completa de los eventos de LiveSplit |
| Práctica automática activada | Casos sintéticos en dificultades 1/2; el usuario confirmó en vivo que Práctica funciona, desmarcar el jefe evita el split y el reloj funciona correctamente | No especificó jefe, dificultad, personaje, modificaciones ni tiempos; pendientes otras combinaciones y reinicios dentro de la misma partida |
| MOTHERSHIP en Práctica | Registro de resultados con `ended=1`, subestado 7 y reloj detenido | Usó invencibilidad nativa y salto de fases; no valida victoria normal ni cierre de Carrera |
| Compilación y regresiones | Parser ASL instalado y ejecución de métodos ASL con timer aislado | No sustituyen pruebas de UI, rutas de memoria ni una carrera completa |
| Último split automático | Identificación del final por inspección de EndLevelSpeedrun; regresiones sintéticas para ambas dificultades | Pendiente prueba en vivo de victoria final en Carrera y contraste del tiempo |

**Corrección importante:** un registro que se iba a usar para comprobar Furiosa comenzó con datos de dificultad 2, pero la partida nueva y la victoria capturadas tenían dificultad 1. Esa transición cuenta como Furi. Registrar siempre la dificultad de la partida de la victoria.

## Compatibilidad y rutas

Instalación investigada: **Furi de Steam para Windows**, proceso `Furi.exe`, runtime Mono de 64 bits, LiveSplit **1.8.37**. Los hashes aceptados están en [LEEME.md](../LEEME.md) y en `init` del ASL. Otras builds muestran `UNSUPPORTED BUILD` y sus acciones quedan desactivadas.

La raíz del dominio se obtuvo inspeccionando `mono_get_root_domain`: la exportación leía un puntero global con direccionamiento relativo a RIP. El destino equivale al RVA `0x49AC78` del módulo investigado. Las referencias a GM y Global se contrastaron tras reiniciar procesos; una diferencia numérica entre direcciones, por sí sola, no era suficiente evidencia.

En la tabla siguiente, `P(dirección)` significa leer un puntero de 64 bits; los offsets son hexadecimales.

| Objeto / campo | Ruta o desplazamiento | Tipo usado |
| --- | --- | --- |
| Dominio Mono | `P(mono-2.0-bdwgc.dll + 0x49AC78)` | Puntero |
| GameManager (GM) | `P(dominio + 0x1ED08)` | Puntero |
| GlobalGameManager | `P(dominio + 0x1EF48)` | Puntero |
| Modo global | Global `+0xB8` | int |
| GameDataInfo / partida | `P(Global + 0x40)` | Puntero |
| Nivel | `P(partida + 0x10)`; longitud `+0x10`, UTF-16 `+0x14` en el string | int + bytes |
| Dificultad y modo de partida | partida `+0x40` y `+0x44` | int |
| Statistics | `P(partida + 0x28)` | Puntero |
| Statistics._time | Statistics `+0x20` | float, segundos acumulados |
| Chrono | `P(GM + 0x38)` | Puntero |
| Estado GM | GM `+0x64` | int |
| Subestado previo a pausa / pérdida de foco | GM `+0x68` / `+0x6C` | int |
| Subestado GM | GM `+0x70` | int |
| endGameTriggered | GM `+0x7B` | byte booleano |
| Chrono._initialTime | Chrono `+0x54` | float, total heredado |

El ASL conserva y compara las tablas de tipo de las primeras muestras aceptadas y filtra rangos/valores. No consulta nombres de clases con Mono en cada muestra. Los Lua de validación sí contrastan clases y campos mediante el colector Mono. Los offsets no son un contrato universal del juego.

Los objetos de heap cambian entre procesos y entre arenas. Los escaneos originales devolvían múltiples candidatos, algunos antiguos o inactivos. Cargar la arena puede dejar GM inválido durante un tiempo. Usar las rutas desde el módulo, validar tipos y observar comportamiento; no elegir automáticamente el primer candidato.

## Identificadores y estados útiles

| Valor | Significado investigado |
| --- | --- |
| GameMode 0 / 1 / 2 / 3 / 4 | None / Story / NewGamePlus / Practice / Speedrun |
| Dificultad 1 / 2 | Furi / Furiosa (Furier) |
| Nivel LAW / NEMESIS / MOTHERSHIP / HORN / BERNARD | Chain / Strap / Star / Beat / Bernard |
| GameState 4 | Arena |
| GameSubState 0 / 1 / 2 / 3 | Normal / InGameSequence / WaitingFightEnd / GameOver |
| GameSubState 4 / 5 / 6 | Paused / Loading / RankingView |
| GameSubState 7 / 8 / 9 | EndScreen / NotFocused / Transition |

Cuando `subState == 8`, el ASL usa `preUnfocused` como subestado efectivo. Un registro tomado al cambiar a Cheat Engine suele mostrar pérdida de foco, no el estado visible al jugar. Una pausa puede quedar debajo de ese estado.

Estos IDs ayudan a interpretar registros; las casillas identifican 12 jefes, pero no describen todas las rutas posibles. La deduplicación usa el nombre de nivel dentro del intento. Una modalidad que vuelva al mismo ID de arena requerirá revisar esa decisión.

## Opciones por jefe de beta.3

El usuario pidió una casilla por jefe y conservar la general `bossSplits`. Se mantienen su clave y valor por defecto para conservar layouts existentes. Las casillas hijas están activadas por defecto: Chain/LAW, Strap/NEMESIS, Line/WISE, Scale/SCALE, Hand/FATHER, Song/WING, Burst/MAZE, Edge/CHALLENGER, Beat/HORN, Star/MOTHERSHIP, Flame/AVENGER y Bernard/BERNARD. Las claves son `boss_<ID>`.

Los nombres se corroboraron con las entradas `<ID>_TITLE` de la localización de la instalación compatible y los identificadores de `GlobalGameManager.GetBossNameFromLevel`. Corrección de documentación: beta.2 llamaba Beat a BERNARD; la localización distingue HORN («The Beat») y BERNARD («Bernard»). Se corrige esa etiqueta sin modificar la condición de victoria final inspeccionada en beta.2. Añadir casillas para Flame/Bernard no valida sus rutas en vivo ni amplía los modos aceptados. Los datos extraídos quedan privados en `local/`.

La opción general domina las hijas. Se filtra el jefe completado, no la arena nueva. Un evento omitido se consume y limpia el pendiente, sin generar split ni entregar el tiempo heredado como si hubiera división. El reloj sigue el acumulado actual. Los IDs sin casilla conservan el comportamiento de la general. El jugador configura las casillas antes del intento y adapta sus segmentos a los jefes elegidos; el script no elimina ni salta filas de LiveSplit. Omitir el jefe final también omite el cierre automático.

Verificación de beta.3: compilación con el parser instalado de LiveSplit 1.8.37 y reproducción normal con Furi abierto, `init` real y hashes compatibles. La lectura del proceso requirió ejecutar la prueba fuera del sandbox tras un error de acceso; no se modificó el juego ni el timer abierto. Pasaron el registro Chain → Strap y las regresiones anteriores, además de las 12 casillas (valores por defecto, omisión, continuidad del reloj, consumo del pendiente y siguiente partida habilitada), prioridad de la general y victorias finales sintéticas. La prueba ejecuta eventos con timer aislado y muestras grabadas/sintéticas; no equivale a probar las casillas en la UI ni una carrera completa en vivo.

## Práctica opcional de beta.4

El usuario pidió extender las casillas por jefe a Práctica y eligió inicio y split automáticos. Se añade `practiceMode`, desactivada por defecto. Con ella habilitada se aceptan modo global y modo de partida 3 coincidentes, dificultades 1/2, con los mismos hashes, tablas y rutas validadas. Historia sigue excluida.

Evidencia de inspección: `GlobalGameManager.StartPractice` crea un nuevo GameDataInfo, fija modo 3, nivel, dificultad y Onnamusha. `GameManager` abre EndScreenPractice al terminar en modo 3; `EndScreenPractice.OnEnable` fija subestado 7. El registro diagnóstico de MOTHERSHIP/Práctica ya contiene `ended=1`, EndScreen y tiempo detenido; usó invencibilidad y salto de fases, por lo que no valida victoria normal ni eventos de LiveSplit. Los volcados se conservan en `local/`.

START requiere una partida nueva observada tras establecer referencia y después Arena/Normal, `ended=0`, Chrono y Statistics válido. Adjuntar en una pelea o en resultados no inicia automáticamente. La victoria exige el mismo jefe/GM observado activo y EndScreen/`ended=1`; cualquier jefe marcado divide inmediatamente con el acumulado de esa sesión, sin esperar otra arena. Las casillas y la general se comparten con Carrera. Los modos limpian intenciones y victorias al cambiar, incluso si el puntero de partida coincide; cada modo establece su propio acumulado.

El reset automático existente permanece solo en Carrera. Para repetir Práctica, resetear LiveSplit manualmente y seleccionar una nueva Práctica desde el menú. Reinicios internos que reutilicen GameDataInfo no se reconocen automáticamente y quedan pendientes de investigación. No se reconstruye un intento nuevo a partir de una lectura menor del reloj. Usar un segmento por pelea y configurar las opciones antes del intento.

Verificación de beta.4: compilación con el componente instalado de LiveSplit 1.8.37 y reproducción normal con `init` real sobre Furi compatible abierto (lectura fuera del sandbox). Pasaron el registro Chain → Strap, casos anteriores y Práctica sintética en ambas dificultades: START una vez tras carga, reloj/pausa/huecos, exclusión de muerte/fases/NaN, pérdida de foco, victoria única, casilla desactivada, adjuntar sin START, cambio de modo con mismo puntero sin heredar victoria y ausencia de reset automático de Carrera en Práctica. No se realizó una victoria de Práctica en vivo con esta revisión.

Después de entregar beta.4, el 2026-10-07 el usuario reportó: «funciona el modo practica», «si desmarcas el jefe no splitea» y «el reloj funciona correcto». Se registra como prueba en vivo reportada por el jugador de Práctica, filtrado por jefe y reloj. No aportó jefe, dificultad, personaje, uso de modificaciones, registro ni valores de tiempo; no acredita todas las combinaciones ni precisión subsegundo. El cierre final de Carrera y los reinicios internos de Práctica siguen pendientes.

## Idioma y momento del split de beta.5

El usuario pidió traducir el autosplitter al inglés y poder elegir resultados o siguiente arena, dejando The Star siempre en resultados. Se traducen etiquetas, tooltips, estado de compatibilidad (`UNSUPPORTED BUILD`) y mensajes visibles; se conservan claves para no romper layouts guardados. En esa etapa las instrucciones españolas permanecieron en LEEME y el contexto de desarrollo estaba en español. La 1.0.0 añade versiones inglesas de las guías públicas y conserva el ASL en inglés.

Por pedido posterior del usuario, la etiqueta de `practiceMode` se renombra a **Practice Mode (split on boss defeat)**. La etiqueta y el tooltip aclaran que divide al derrotar al jefe en el modo Práctica del juego, en resultados de victoria. Solo cambia el texto visible; conserva clave, inicio automático, comportamiento y valor desactivado por defecto.

Se añade `splitOnResults`, desactivada por defecto: marcada divide cada victoria de Carrera en EndScreen con Statistics válido y el acumulado aceptado; desmarcada conserva el split al quedar lista la siguiente arena con Chrono._initialTime. No se cambia el seguimiento del reloj. The Star/MOTHERSHIP siempre usa resultados en cualquier dificultad; se conserva también el Bernard final de Furiosa en resultados y Práctica siempre divide en victoria. Las casillas y la general siguen filtrando ambos momentos. Los eventos omitidos y las victorias ya divididas no generan otra división al cargar. Configurar antes del intento.

El usuario confirmó Bernard y The Flame y considera el DLC correcto. Se registra como funcionamiento reportado, junto con el reporte previo de Onnamusha; falta detalle de modo/dificultad y contraste del tiempo. Esta evidencia no se convierte en una carrera completa validada.

Verificación de beta.5: compilación con LiveSplit 1.8.37 y reproducción normal con Furi abierto, init real y hashes compatibles. Pasaron los casos previos de Carrera, Práctica y las 12 casillas; los nuevos casos de resultados para dificultades 1/2 comprueban un split inmediato con tiempo 217.30, continuidad a 217.90 al cargar sin duplicado, exclusión de muerte/fases/NaN y casilla desactivada. También se comprueba que The Star divide en resultados con la opción desmarcada en ambas dificultades. La selección nueva sigue pendiente de prueba en vivo; los casos son sintéticos/registro con timer aislado.

## Cómo se generan los eventos

1. **Inicializar:** verificar hashes y limpiar seguimiento, cachés de tablas, tiempo y eventos pendientes.
2. **Establecer una referencia inicial:** observar menú limpio (`modo=0`, sin partida) o guardar la primera partida vista. Adjuntar a una partida ya cargada no genera START.
3. **Reconocer intento nuevo:** cambia el puntero GameDataInfo o el modo aceptado. Se limpia el seguimiento anterior. En Carrera, si el nivel es LAW, se prepara START; durante una run puede prepararse reset si están habilitados la opción experimental y Reset de LiveSplit. En Práctica habilitada, se prepara START para cualquier jefe y se espera la arena lista.
4. **Leer Game Time:** aceptar Statistics con tabla coherente, tiempo finito y no negativo. Conservar el máximo dentro de la partida frente a lecturas atrasadas. Los huecos conservan el último valor; una partida nueva limpia el acumulado.
5. **Preparar victoria:** observar GM/nivel con `ended=0` en Normal o InGameSequence; luego el mismo GM/nivel con `ended=1` y EndScreen efectivo. No basta cambiar de fase, morir o ver una pantalla final de un objeto que no se había observado activo.
6. **Elegir límite:** en Práctica habilitada, con `splitOnResults` marcada o si es MOTHERSHIP o BERNARD/dificultad 2 en Carrera, preparar split en esa victoria con Statistics válido en la muestra y el acumulado aceptado. Para los demás jefes de Carrera con la opción desmarcada, esperar nivel y GM distintos del pendiente, Arena/Normal, `ended=0`, Chrono disponible, Statistics válido y `Chrono._initialTime` finito entre cero y el tiempo acumulado aceptado.
7. **Dividir una vez:** `gameTime` entrega el total heredado o el acumulado de victoria en el frame del split; `split` registra el nivel en `completed` y limpia la victoria pendiente. Las lecturas posteriores vuelven al acumulado actual. Requiere Split y la opción de splits de jefes habilitados; LiveSplit termina cuando corresponde al último segmento configurado.

Cambiar de modo o entrar en uno excluido limpia la victoria pendiente. `onStart` y `onReset` limpian seguimiento de segmentos; el reset automático de Carrera conserva la intención de START. El script no crea ni reordena los segmentos de LiveSplit.

### Por qué el reloj funciona así

La inspección local mostró que `ScoreManager.Update` copia `GameManager.GameTime` a `Statistics._time`. Leer ese campo evita reconstruir el reloj Unity nativo. Se contrastó un tiempo pausado de **217.30 s** con la fórmula del Chrono.

`isLoading` devuelve siempre `true` para detener la extrapolación interna de LiveSplit mientras el ASL entrega tiempos explícitos. No significa que el juego esté cargando permanentemente ni describe un algoritmo genérico para quitar cargas.

Statistics puede quedar un frame atrasado o incluir primeros frames de la arena nueva. El modo de siguiente arena usa `Chrono._initialTime` como límite del tramo. En un registro V2, el final de Chain y el inicial de Strap eran **211.236328125 s**, mientras Statistics en la primera muestra lista de Strap era **211.23889160156 s**. Los tests también cubren un total heredado de 217.30 frente a Statistics de 217.90.

### Transición que no debe romperse

Se observó `nivel=NEMESIS` mientras seguía presente el GM de Chain con `ended=1`. Después hubo huecos, GM nuevo en Loading y finalmente Normal con Chrono. Por eso cambiar de nivel por sí solo puede dividir demasiado pronto, y combinar nivel nuevo con la señal antigua puede atribuir una victoria al jefe equivocado.

## Victoria final: decisión y límites de beta.2

El 2026-10-07 el usuario pidió dividir al ganar el último jefe, sin esperar el menú siguiente. Compartió una captura de «CONGRATS! SPEEDRUN COMPLETED!» con Star como décimo jefe: evidencia visual del resumen, sin registro de memoria ni validación de eventos ASL.

La inspección local de `EndLevelSpeedrun.Open` identifica explícitamente MOTHERSHIP con dificultad 1 y BERNARD con dificultad 2 para el texto `UI_SPEEDRUN_FINAL`. Esto fundamenta la selección por dificultad de la build compatible; no se fija Star como final universal. Los volcados permanecen privados en `local/`.

La nueva lógica usa la señal ya existente de victoria: mismo GM/nivel previamente observado activo, Arena, `ended=1` y EndScreen efectivo (también debajo de pérdida de foco). Exige Statistics válido en la muestra y entrega su acumulado aceptado, sin usar Chrono._initialTime del último jefe, que solo representa el comienzo de ese tramo. No dispara por muerte, fase, carga, ranking, menú o lectura inválida; mantiene exclusión de Historia/Práctica y deduplicación. No detecta la pantalla de resumen final. El posible retraso de Statistics al llegar a resultados sigue pendiente de contraste en vivo; no se afirma precisión subsegundo.

Verificación de beta.2: `ValidarASL.ps1` pasó con el componente de LiveSplit 1.8.37 instalado. La reproducción normal no pudo completarse: Furi no permaneció abierto tras intentar iniciarlo directamente y desde Steam. Se ejecutó el mismo harness con una copia temporal privada del ASL que sustituye únicamente el descubrimiento de módulos/verificación de hashes de `init`; los hashes de los binarios instalados se comprobaron por separado. Toda la inicialización restante y los bloques de lógica son los de beta.2. Pasaron el registro Chain → Strap, los casos anteriores y los finales sintéticos de ambas dificultades (tiempo 217.30, deduplicación, NaN, muerte/fases, pérdida de foco, modos excluidos, dificultad incorrecta, adjuntar en resultados y splits desactivados). Esto comprueba lógica aislada; no ejercita el `init` real ni las rutas en un proceso vivo. Los archivos auxiliares están en `local/` y no se distribuyen.

La inspección local de Carrera mostró un camino sin siguiente nivel que carga **EndSpeedrunMenu** mediante `GoToSpeedrunFinalScreen`. La hipótesis inicial de usar `GameState == 17` (EndGameRanking) no quedó demostrada para ese camino y fue retirada.

MOTHERSHIP en Práctica produjo EndScreen/`ended=1`; eso confirma una señal de resultados de esa prueba, no el cierre de Carrera. El reloj siguió avanzando durante parte de WaitingFightEnd, a diferencia de otra muestra de Chain. No se atribuyó la diferencia al truco: puede depender del modo, jefe o secuencia.

Para validar este cambio, capturar una victoria final en **Carrera** con modo, dificultad, nivel, tiempo, GM y estados globales antes/durante/después de resultados y del resumen final. Contrastar que el split sea único y coincida con el total del juego. Verificar también Furiosa y DLC/personajes. La prueba modificada en Práctica no valida este comportamiento.

## Splits por fases: beta.6

El usuario pidió añadir splits al completar cada fase en **Carrera y Práctica**, conservando las opciones por jefe existentes. Beta.6 añade `phaseSplits`, desactivada por defecto, con etiqueta **Phase splits (Speedrun and Practice)**. Respeta `bossSplits` y la casilla del jefe. En Práctica requiere además `practiceMode`. Usar un segmento por fase. La última fase se cuenta mediante el split de victoria existente y conserva su momento configurado; no genera dos divisiones por el mismo final.

El usuario registró LAW/Furi en Práctica, PID 25040: contador 0 → 1 y count=4, además de una regresión 1 → 0 cuyo motivo no fue confirmado. Después de reiniciar, PID 10676, registró LAW/Furi en Carrera con la misma ruta, contador 0 → 1 en subestado 1, ended=0, Statistics=36.383136749268. Metadatos corroborados: PawnManager en `P(dominio+0x1EAE8)`, arenaAIPawn +0x48, controller +0x1D8, phase +0x1B8, configuración +0xF0, lista +0x18 y tamaño de lista +0x18. El controlador real fue NPCLawPawnController. No se usan las direcciones de heap del registro en el ASL.

La implementación exige dos muestras válidas del mismo GM/nivel/controlador/configuración con avance exactamente de una fase, contador dentro del tamaño de lista y Statistics válido al dividir. Cachea las tablas de PawnManager/AIPawn y fija las de controlador/configuración por combate, permitiendo distintos controladores por jefe. El primer valor solo establece referencia. Una lectura inválida, carga, pausa, muerte o estado excluido rompe la continuidad; no reconstruye eventos al recuperarse. Conserva el máximo de fase observado para no volver a contar fases repetidas tras una regresión; nueva partida, modo o combate limpia la referencia. Los saltos de varias fases se consumen sin fabricar splits. La lógica no automatiza reinicios internos de Práctica.

El registro valida la ruta y el avance en LAW/Furi en los dos modos, no el evento de LiveSplit ni una pelea completa. Pendientes: prueba del ASL en LiveSplit, otras fases/jefes/Furiosa, último jefe y causa de regresión del registro de Práctica.

Verificación beta.6: parser/compilación con LiveSplit 1.8.37 y reproducción con init real y hashes compatibles de Furi PID 10676. Pasaron todas las regresiones previas y cuatro combinaciones sintéticas Carrera/Práctica × dificultades 1/2: avance único con Statistics, deduplicación, regresión, filtros general/por jefe, reloj continuo, victoria final sin duplicado y mismo momento previo, gap/NaN sin reconstrucción, punteros/contador inválidos y saltos múltiples. Estos casos no sustituyen la prueba de splits en LiveSplit en una pelea real.

Reporte posterior del usuario: «splitea por fases» y no divide al morir. Confirma funcionamiento en vivo de la beta.6 en su prueba; no especificó modo/dificultad/jefe ni contraste de tiempos. Mantener pendientes las otras combinaciones y una pelea/carrera completa.

## Contador de impactos: beta.7

### Revisión beta.8: vínculo flexible y KO

El usuario reportó que beta.7 no sumaba impactos en su Counter y pidió configurar KO. La captura mediante control de Windows confirma beta.7 compatible y `hitCounter` activada en Layout Settings; no se pudo abrir la pestaña Counter con los inputs del helper, por lo que el texto actual de ese contador y la causa exacta siguen sin confirmarse. No se cambiaron sus opciones. Beta.7 exigía `Furi Hits` exacto y devolvía éxito incluso sin coincidencia; esto ocultaba un vínculo ausente.

Beta.8 usa un resolvedor común: acepta `Furi Hits`/`Hits` y `Furi KO`/`KO` sin distinguir mayúsculas ni dos puntos finales. Si hay un único Counter con texto predeterminado `Counter` o vacío y solo una métrica habilitada, lo vincula a esa métrica. Si ambas están habilitadas, exige nombres separados. Varios nombres coincidentes son ambiguos y no se escriben; no se toma arbitrariamente el primer contador. Devuelve false y registra not found/ambiguous; un vínculo válido registra linked al cambiar de estado.

`koCounter` está desactivada por defecto, etiqueta **Track KO in Counter (Furi KO)**. Lee `_KO +0x24` de Statistics, corroborado por metadatos y los registros de muerte y LAW → NEMESIS (KO=1 conservado). Tiene máximo, Start/Reset y partida nueva independientes de hits; comparte exclusión de modos y validación de Statistics. Los contadores desactivados no se escriben ni se limpian. Falta comprobar ambos vínculos en el layout real y KO en otras combinaciones.

Verificación beta.8: compilación con LiveSplit 1.8.37 y regresiones completas con init real/hashes compatibles de Furi PID 10676 pasaron. Counter real en layout aislado comprobó Hits=4/KO=1 separados, KO creciente y conservado ante gap/retroceso, hits desactivados intactos, reset selectivo KO, alias `ko:`, un Counter predeterminado vinculado a una sola métrica y sin escritura cuando ambas son ambiguas. Pasó también el guard de Start/Reset con supported=false. Esta evidencia es sintética/API; no demuestra resuelto el fallo en el layout del usuario. Para probar, aplicar Layout Settings y Layout Editor con OK y comenzar una sesión nueva.

El usuario pidió conectar impactos con el componente Counter de LiveSplit. La instalación local contiene `LiveSplit.Counter.dll`; reflexión identifica `CounterComponent.Counter` e `ICounter.SetCount(Int32)`, además de `Settings.CounterText`. Beta.7 añade `hitCounter`, desactivada por defecto, etiqueta **Track received hits in Counter (Furi Hits)**. Vincula un único Counter con texto exacto `Furi Hits`, sin modificar otros. Si falta o hay varios con ese nombre, no escribe. La reflexión mantiene Counter opcional, sin DLL externa distribuida ni hotkeys simuladas.

Lee `_hits +0x28` por la misma ruta/clase Statistics del reloj. Conserva el máximo válido no negativo de la partida, independiente de filtros de jefes/fases. Sincroniza durante Running/Paused de LiveSplit en Carrera o Práctica habilitada; modos excluidos y muestras inválidas no escriben. Start/Reset ponen en cero el contador vinculado con build compatible; la siguiente lectura puede restaurar el total del intento del juego, por lo que para otra Práctica hay que elegir nueva sesión. Partida nueva limpia el máximo. Cambios manuales al contador vinculado se reemplazan al sincronizar. La opción no convierte Counter en un contador de eventos arbitrarios; el usuario conserva otros Counter para usos manuales.

Verificación beta.7: compilación ASL con LiveSplit 1.8.37; regresiones completas con init real/hashes compatibles PID 10676 pasaron, incluyendo reloj, fases y jefes. El caso nuevo usa Counter/CounterComponent reales de la DLL instalada y layout aislado: SetCount=24, contador ajeno intacto, ambigüedad sin escritura, opción apagada, huecos/negativos/retrocesos, modo excluido, nueva Carrera, Práctica y reset=0. Prueba focalizada adicional de la fuente final confirma que manual Start/Reset no escribe Counter cuando supported=false. Son pruebas sintéticas de lógica/API; falta prueba del layout abierto con impactos reales.

La inspección IL identifica `Statistics._hits`: `OnHit` exige objetivo PlayerPawn e incrementa el contador cuando el impacto no fue parried; no equivale a sumar solamente daño efectivo positivo. Hay que usar y describir el criterio de impactos del juego, no inventar un contador por daño. `Reset` pone hits y KO en cero. En esa etapa faltaba validar offset y acumulación/reinicio entre arenas en vivo; el registro posterior LAW → NEMESIS se describe abajo.

Se preparó `tools/cheat-engine/RegistrarImpactos.lua`, que resuelve los campos por metadatos, valida las clases de las rutas existentes y registra hits, KO, startHits, jefe, partida, modo y estados, sin escribir memoria ni controlar LiveSplit. Guarda registros privados automáticamente. El usuario aportó impactos, muerte/reanudación y siguiente arena descritos abajo; la exclusión de parry procede del IL, sin confirmación explícita del jugador en ese momento. Dar los pasos en el chat y esperar la respuesta cuando hace falta otra prueba.

El usuario ejecutó el diagnóstico en Carrera LAW/Furi, PID 10676. Metadatos: GameData +0x28 → Statistics, `_hits +0x28`, `_KO +0x24`, `_time +0x20`. Un intento nuevo cambió GameData/Statistics y comenzó con hits=0/KO=0. Se registraron incrementos de impactos hasta 15; al morir (confirmado por el usuario), KO pasó 0 → 1 sin cambiar GameData/Statistics ni perder hits=15. Posteriormente hits llegó a 16 con KO=1. El registro siguiente llegó a LAW EndScreen/ended=1 con hits=24, KO=1, tiempo 277.56164550781; NEMESIS conservó el mismo GameData/Statistics y hits=24 a través de huecos y carga hasta arena Normal. Fundamenta enviar el total acumulado, sin sumarlo otra vez por jefe. La ruta de Statistics ya se había contrastado tras reiniciar; el offset nuevo se corroboró por metadatos. Pendientes: conexión en un layout real y contador en Práctica/Furiosa/otros jefes.

La inspección IL de la Assembly-CSharp compatible identifica `AIPawnController._currentPhaseNumber`: `MoveToNextPhase` incrementa el índice mientras quedan fases; al finalizar la última llama a la muerte del jefe sin incrementar el contador. `ResetPhase` pone -1 y `ACheckBossFightPhase.HandleOnGameReset` reinicializa y avanza a la primera fase. Esto fundamenta una señal candidata, pero no valida sus rutas ni su comportamiento en vivo. Se encontró la relación candidata `PawnManager.arenaAIPawn -> AIPawn.aiPawnController -> AIPawnController._currentPhaseNumber`.

Se añadió `tools/cheat-engine/RegistrarFases.lua`, un diagnóstico que resuelve referencias al singleton, valida clases y guarda cambios de fase/estado en `local/research/Registros/`. Sintaxis comprobada con Lua 5.3 de la instalación local de Cheat Engine. El control de Windows no expuso una ventana targetable de Cheat Engine, por lo que el usuario ejecutó los diagnósticos y aportó los registros descritos aquí. El usuario pidió recibir los pasos en el chat y esperar su respuesta cuando hace falta otra prueba, sin dejar trabajo activo mientras la realiza.

## Próximas contribuciones, en orden útil

Los dos párrafos siguientes conservan etapas anteriores del diagnóstico; la evidencia posterior de fases está en la sección beta.6.

El usuario ejecutó V2 en Práctica LAW, dificultad 1, PID 25040. Resolvió una referencia PawnManager en `dominio + 0x1EAE8`; metadatos: `arenaAIPawn +0x48`, `aiPawnController +0x1D8`, `_currentPhaseNumber +0x1B8`, `_bfp +0xF0`, `phases +0x18`. El controlador se leyó como puntero, pero `phase/count` quedaron nil durante todo el registro; el usuario indicó haber ganado una fase. Se observaron subestados 0/1/4/8 con ended=0; no se usan como victoria de fase. Esta sesión no valida el contador ni la ruta tras reiniciar. La inspección de tipos confirma controladores derivados, incluyendo `NPCLawPawnController`. V3 acepta controladores/configuraciones cuya jerarquía Mono contiene la clase esperada, valida su vtable por metadatos y registra el nombre concreto; conserva validación exacta para la búsqueda del singleton. Sintaxis Lua 5.3 comprobada, captura V3 pendiente.

El primer intento en vivo de `RegistrarFases.lua` falló al resolver el singleton: captura del usuario con error en la línea 63, sin lecturas de fase. No permite distinguir cero candidatos de varios. La revisión V2 registra los campos estáticos antes de resolver y busca también referencias con tabla PawnManager en los primeros `0x40000` bytes del dominio; varias referencias al mismo objeto se aceptan, varios objetos distintos se rechazan. Guarda el diagnóstico también si no consigue resolver. Sintaxis Lua 5.3 comprobada; el resultado posterior de V2 se detalla arriba. Este ajuste no cambia el ASL.

1. Contrastar en vivo la revisión pública: un split Chain → Strap con tiempo igual al total heredado, sin adelanto ni primeros frames del nuevo jefe.
2. Registrar victoria y transición en Furiosa comprobando `dificultad=2` en ese intento.
3. Completar Carrera en Furi y Furiosa, observando cada transición y el nuevo split automático de victoria final.
4. Contrastar el tiempo del split final con resultados/resumen y registrar posibles lecturas atrasadas de Statistics.
5. Registrar DLC/personajes y rutas que omitan o repitan arenas; comprobar la deduplicación por nivel.
   Onnamusha ya tiene un reporte favorable de inicio, reloj y splits intermedios en Furi y Furiosa; sigue pendiente probar el cierre final y documentar una carrera completa.
6. Añadir otras builds/plataformas o modalidades mediante rutas y comportamiento documentados, sin ampliar la compatibilidad solo por su nombre comercial.
7. Probar Práctica normal y Onnamusha en vivo; investigar reinicios internos antes de automatizarlos.

## Dónde continuar

- [CONTRIBUTING.md](../CONTRIBUTING.md): procedimiento para cambios y nuevas capacidades.
- [DEVELOPMENT.md](DEVELOPMENT.md): compilar, reproducir y empaquetar.
- [tests/fixtures/README.md](../tests/fixtures/README.md): procedencia y límites del registro público.
- [tools/cheat-engine/README.md](../tools/cheat-engine/README.md): monitor actual y diagnósticos anteriores.
- [REPORTAR-ERROR.md](../REPORTAR-ERROR.md): datos para nuevas pruebas comunitarias.

El historial original y los volcados IL se conservaron en `local/research/`, excluido de Git. Contienen etapas superadas, entre ellas una frase antigua que llama al ASL «inactivo». Esa frase no describe la versión actual. Ningún archivo local es requisito para entender ni ejecutar la versión pública.

Al continuar, actualizar ambas versiones de idioma con el caso observado, la build/dificultad/modo, la revisión probada, el resultado y lo que todavía no se puede concluir. Así el próximo colaborador puede seguir desde evidencia concreta.
