# Contexto y punto de continuación

Actualizado: **2026-10-06**, versión **0.1.0-beta.1**. Este documento resume el estado vigente para continuar el proyecto sin necesitar la conversación original ni las notas privadas. La fuente ejecutable es [ASL/Furi.asl](../ASL/Furi.asl). Los comandos están en [DEVELOPMENT.md](DEVELOPMENT.md).

## Objetivo y acuerdos

El proyecto comenzó investigando memoria con Cheat Engine y pasó a un ASL que LiveSplit puede usar sin Cheat Engine. El primer alcance es **Extras > Carrera**, Furi y Furiosa, con un segmento por jefe de la ruta elegida por el jugador.

El usuario eligió el cronómetro acumulado del juego como **Game Time** y el split al cargar la siguiente arena. Una revisión inicial dividía al mostrar resultados y contaba tiempo real; ese comportamiento fue reemplazado. El ASL actual guarda la victoria en resultados, espera la siguiente arena y divide usando el total heredado del jefe anterior.

La beta admite inicio automático y reset opcional de un intento en curso. El último split se hace manualmente. La distribución está preparada para pruebas comunitarias, con cobertura parcial; aún no hay una carrera completa validada.

## Estado comprobado

| Flujo | Evidencia disponible | Límite de la comprobación |
| --- | --- | --- |
| START de Carrera Furi | Usuario probó inicio en LiveSplit; reproducción desde menú | No se midió el instante de START con precisión subsegundo |
| Reloj, pausa y pérdida de foco | Usuario contrastó HUD/LiveSplit y registros de memoria | HUD redondea a segundos; coincidencia visual no acredita precisión subsegundo |
| Resultados de Chain → Strap | Usuario confirmó reloj detenido, sin split en resultados, un split al cargar Strap y continuidad del tiempo | La revisión pública ajustó después el límite exacto del split a `Chrono._initialTime`; ese ajuste pasó reproducción, pendiente contraste en vivo |
| Muerte y CONTINUAR en Strap | Usuario confirmó que permaneció en el segmento y los relojes parecían correctos | No cubre todos los jefes ni todas las variantes de muerte |
| Reiniciar Carrera desde pausa y nueva Carrera desde menú | Usuario confirmó ambos caminos con reset opcional activado | Probado durante un intento en curso; después de terminar, usar reset manual |
| Furiosa | Usuario confirmó inicio, reinicio, reloj y pausa | Falta victoria/transición registrada en Furiosa |
| Exclusión de Práctica y limpieza de victoria pendiente | Caso sintético con el componente ASL instalado | El diagnóstico en vivo de Práctica no fue una prueba completa de los eventos de LiveSplit |
| MOTHERSHIP en Práctica | Registro de resultados con `ended=1`, subestado 7 y reloj detenido | Usó invencibilidad nativa y salto de fases; no valida victoria normal ni cierre de Carrera |
| Compilación y regresiones | Parser ASL instalado y ejecución de métodos ASL con timer aislado | No sustituyen pruebas de UI, rutas de memoria ni una carrera completa |
| Último split automático | Sin validación | Sigue manual |

**Corrección importante:** un registro que se iba a usar para comprobar Furiosa comenzó con datos de dificultad 2, pero la partida nueva y la victoria capturadas tenían dificultad 1. Esa transición cuenta como Furi. Registrar siempre la dificultad de la partida de la victoria.

## Compatibilidad y rutas

Instalación investigada: **Furi de Steam para Windows**, proceso `Furi.exe`, runtime Mono de 64 bits, LiveSplit **1.8.37**. Los hashes aceptados están en [LEEME.md](../LEEME.md) y en `init` del ASL. Otras builds muestran `BUILD NO COMPATIBLE` y sus acciones quedan desactivadas.

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
| Nivel LAW / NEMESIS / MOTHERSHIP | Chain / Strap / Star |
| GameState 4 | Arena |
| GameSubState 0 / 1 / 2 / 3 | Normal / InGameSequence / WaitingFightEnd / GameOver |
| GameSubState 4 / 5 / 6 | Paused / Loading / RankingView |
| GameSubState 7 / 8 / 9 | EndScreen / NotFocused / Transition |

Cuando `subState == 8`, el ASL usa `preUnfocused` como subestado efectivo. Un registro tomado al cambiar a Cheat Engine suele mostrar pérdida de foco, no el estado visible al jugar. Una pausa puede quedar debajo de ese estado.

Estos IDs ayudan a interpretar registros; la beta no contiene una lista exhaustiva de jefes o rutas. La deduplicación usa el nombre de nivel dentro del intento. Una modalidad que vuelva al mismo ID de arena requerirá revisar esa decisión.

## Cómo se generan los eventos

1. **Inicializar:** verificar hashes y limpiar seguimiento, cachés de tablas, tiempo y eventos pendientes.
2. **Establecer una referencia inicial:** observar menú limpio (`modo=0`, sin partida) o guardar la primera partida vista. Adjuntar a una partida ya cargada no genera START.
3. **Reconocer intento nuevo:** cambia el puntero GameDataInfo en Carrera válida. Se limpia el seguimiento anterior. Si el nivel es LAW, se prepara START; durante una run puede prepararse reset si están habilitados la opción experimental y Reset de LiveSplit.
4. **Leer Game Time:** aceptar Statistics con tabla coherente, tiempo finito y no negativo. Conservar el máximo dentro de la partida frente a lecturas atrasadas. Los huecos conservan el último valor; una partida nueva limpia el acumulado.
5. **Preparar victoria:** observar GM/nivel con `ended=0` en Normal o InGameSequence; luego el mismo GM/nivel con `ended=1` y EndScreen efectivo. No basta cambiar de fase, morir o ver una pantalla final de un objeto que no se había observado activo.
6. **Esperar siguiente arena:** exigir nivel y GM distintos del pendiente, Arena/Normal, `ended=0`, Chrono disponible, Statistics válido en esa muestra y `Chrono._initialTime` finito entre cero y el tiempo acumulado aceptado.
7. **Dividir una vez:** `gameTime` entrega el total heredado en el frame del split; `split` registra el nivel en `completed` y limpia la victoria pendiente. Las lecturas posteriores vuelven al acumulado actual.

Salir de Carrera limpia la victoria pendiente. `onStart` y `onReset` limpian seguimiento de segmentos; el reset automático conserva la intención de START. El script no crea ni reordena los segmentos de LiveSplit.

### Por qué el reloj funciona así

La inspección local mostró que `ScoreManager.Update` copia `GameManager.GameTime` a `Statistics._time`. Leer ese campo evita reconstruir el reloj Unity nativo. Se contrastó un tiempo pausado de **217.30 s** con la fórmula del Chrono.

`isLoading` devuelve siempre `true` para detener la extrapolación interna de LiveSplit mientras el ASL entrega tiempos explícitos. No significa que el juego esté cargando permanentemente ni describe un algoritmo genérico para quitar cargas.

Statistics puede quedar un frame atrasado o incluir primeros frames de la arena nueva. La beta usa `Chrono._initialTime` como límite exacto del tramo. En un registro V2, el final de Chain y el inicial de Strap eran **211.236328125 s**, mientras Statistics en la primera muestra lista de Strap era **211.23889160156 s**. Los tests también cubren un total heredado de 217.30 frente a Statistics de 217.90.

### Transición que no debe romperse

Se observó `nivel=NEMESIS` mientras seguía presente el GM de Chain con `ended=1`. Después hubo huecos, GM nuevo en Loading y finalmente Normal con Chrono. Por eso cambiar de nivel por sí solo puede dividir demasiado pronto, y combinar nivel nuevo con la señal antigua puede atribuir una victoria al jefe equivocado.

## Cierre final: investigación pendiente

La inspección local de Carrera mostró un camino sin siguiente nivel que carga **EndSpeedrunMenu** mediante `GoToSpeedrunFinalScreen`. La hipótesis inicial de usar `GameState == 17` (EndGameRanking) no quedó demostrada para ese camino y fue retirada.

MOTHERSHIP en Práctica produjo EndScreen/`ended=1`; eso confirma una señal de resultados de esa prueba, no el cierre de Carrera. El reloj siguió avanzando durante parte de WaitingFightEnd, a diferencia de otra muestra de Chain. No se atribuyó la diferencia al truco: puede depender del modo, jefe o secuencia.

Para implementar cierre automático, capturar una victoria final en **Carrera** con modo, dificultad, nivel, tiempo, GM y estados globales antes/durante/después de los resultados y de la pantalla final. Distinguirlo de salir al menú, cargar, reiniciar, perder el proceso y jugar Práctica. Verificar rutas de Furiosa y DLC antes de fijar un ID como último jefe universal.

## Próximas contribuciones, en orden útil

1. Contrastar en vivo la revisión pública: un split Chain → Strap con tiempo igual al total heredado, sin adelanto ni primeros frames del nuevo jefe.
2. Registrar victoria y transición en Furiosa comprobando `dificultad=2` en ese intento.
3. Completar Carrera en Furi y Furiosa, observando cada transición y el cierre final. Mantener el último split manual durante estas pruebas.
4. Investigar e implementar cierre final con evidencia y regresiones de falsos positivos.
5. Registrar DLC/personajes y rutas que omitan o repitan arenas; comprobar la deduplicación por nivel.
6. Añadir otras builds/plataformas o modalidades mediante rutas y comportamiento documentados, sin ampliar la compatibilidad solo por su nombre comercial.

## Dónde continuar

- [CONTRIBUTING.md](../CONTRIBUTING.md): procedimiento para cambios y nuevas capacidades.
- [DEVELOPMENT.md](DEVELOPMENT.md): compilar, reproducir y empaquetar.
- [tests/fixtures/README.md](../tests/fixtures/README.md): procedencia y límites del registro público.
- [tools/cheat-engine/README.md](../tools/cheat-engine/README.md): monitor actual y diagnósticos anteriores.
- [REPORTAR-ERROR.md](../REPORTAR-ERROR.md): datos para nuevas pruebas comunitarias.

El historial original y los volcados IL se conservaron en `local/research/`, excluido de Git. Contienen etapas superadas, entre ellas una frase antigua que llama al ASL «inactivo». Esa frase no describe la beta actual. Ningún archivo local es requisito para entender ni ejecutar la versión pública.

Al continuar, actualizar este documento con el caso observado, la build/dificultad/modo, la revisión probada, el resultado y lo que todavía no se puede concluir. Así el próximo colaborador puede seguir desde evidencia concreta.
