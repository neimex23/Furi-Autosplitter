# Registro de prueba: Chain → Strap

`chain-strap.txt` es un registro de memoria obtenido durante una sesión de investigación el **2026-10-06**, en **Extras > Carrera**, dificultad **Furi (1)**. Se copió del registro original al organizar el repositorio.

Incluye intentos nuevos, pausas/pérdida de foco, un reinicio y la victoria de Chain seguida de la carga de Strap. En el intento de la victoria, el puntero de partida permanece estable mientras el nivel cambia de LAW a NEMESIS. Durante parte de la transición, el GM anterior conserva la señal de victoria; luego aparecen huecos, el GM nuevo, Loading y Normal con Chrono.

Es una salida del monitor anterior a V2, que no contiene `Statistics._time` en todas las muestras. El parser de `tests/ReproducirRegistro.cs` reconstruye algunas muestras de tiempo con los campos del Chrono pausado o su inicial. Las comprobaciones precisas del límite del split, datos inválidos y continuidad también usan casos sintéticos separados. No tratar todos los tiempos del replay como mediciones directas del reloj durante combate.

La marca `[Xs]` mide segundos desde iniciar el monitor, no el cronómetro del juego. El monitor muestreaba cada 100 ms y escribía cambios de estado. El registro puede omitir eventos entre muestras y no acredita precisión subsegundo.

Las direcciones hexadecimales son identificadores de objetos de aquella sesión. El harness las usa para simular cambios de identidad, no para leer esas direcciones del Furi actual. Las tablas de tipo se simulan en el parser; este registro no valida por sí solo las rutas actuales del bloque `state`.

La reproducción espera, con reset opcional desactivado, **1 inicio, 0 resets y 1 split**; con reset habilitado, **2 inicios, 1 reset y 1 split**. Los demás casos sintéticos se describen en el código y en [docs/CONTEXT.md](../../docs/CONTEXT.md).

Para añadir un registro, documentar fecha, revisión del ASL, build/hashes, modo, dificultad, origen, intervención del jugador y eventos esperados. Conservar los datos originales pertinentes y señalar cualquier anonimización o reconstrucción. Excluir rutas personales, partidas y archivos del juego.
