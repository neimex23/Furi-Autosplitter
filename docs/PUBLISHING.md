# Publicar Furi Autosplitter y mantener versiones

Español | [English](PUBLISHING.en.md)

Preparado el 2026-10-07 para **1.0.0**, firmado por **Neimex23**. Esta guía y el [fragmento XML](livesplit-registration.xml) preparan el alta; no significan que ya se haya publicado o aceptado en LiveSplit.

## 1. Publicar la versión en tu repositorio

1. Revisá los cambios, ejecutá compilación y regresiones de [DEVELOPMENT.md](DEVELOPMENT.md) y conservá las limitaciones de [CONTEXT.md](CONTEXT.md) en las notas. La 1.0.0 reúne beta.8; no acredita una carrera completa ni una prueba en vivo del cierre final o del vínculo Counter.
2. Generá el paquete con `powershell.exe -NoProfile -File .\tools\Empaquetar.ps1` desde la raíz.
3. Hacé commit de fuentes, tests y documentos públicos revisados y subilos a `main` en [neimex23/Furi-Autosplitter](https://github.com/neimex23/Furi-Autosplitter). Conservá `local/` y `dist/` fuera de Git.
4. En GitHub, abrí **Releases > Draft a new release**. Creá el tag `v1.0.0` sobre el commit publicado; título sugerido: **Furi Autosplitter 1.0.0 — Neimex23**. Usá la entrada 1.0.0 del changelog como notas y adjuntá `dist/Furi-Autosplitter-1.0.0.zip`. Publicá la release.
5. Verificá sin iniciar sesión que la [URL directa del ASL](https://raw.githubusercontent.com/neimex23/Furi-Autosplitter/main/ASL/Furi.asl) devuelve texto y comienza con `// Furi Autosplitter 1.0.0`. Ese archivo es lo que descargará LiveSplit; el ZIP es para instalación manual. El repositorio y el archivo deben ser públicos.

## 2. Solicitar que aparezca al elegir Furi

LiveSplit indica que el alta se solicita mediante un pull request a su catálogo XML, que sus mantenedores revisan y fusionan. [Procedimiento oficial](https://github.com/LiveSplit/LiveSplit.AutoSplitters#adding-an-auto-splitter).

1. Abrí [LiveSplit.AutoSplitters.xml](https://github.com/LiveSplit/LiveSplit.AutoSplitters/blob/master/LiveSplit.AutoSplitters.xml) y buscá `Furi`. En la consulta del 2026-10-07 no se encontró una entrada exacta; comprobalo otra vez antes de enviar. Si ya existe, proponé una actualización coordinada, sin duplicar el nombre.
2. Usá el botón de editar de GitHub y creá el fork/branch cuando te lo ofrezca.
3. Insertá el contenido completo de [livesplit-registration.xml](livesplit-registration.xml) dentro del elemento raíz `<AutoSplitters>`, como hermano de las otras entradas. Conservá el XML restante. La URL apunta a `main/ASL/Furi.asl`, no al ZIP ni a la página HTML del archivo.
4. Abrí el pull request con título **Add Furi autosplitter**. Describí el alcance, el Game Time del juego, las opciones y las pruebas. Indicá las comprobaciones en vivo aún pendientes; enlazá la release y el contexto público.
5. Esperá la revisión y atendé las observaciones. Publicar tu release no agrega por sí solo el juego al catálogo. La aceptación y sus plazos dependen de LiveSplit.

Después de la aceptación, reiniciá LiveSplit con conexión a Internet, abrí **Edit Splits**, escribí **Furi** en **Game Name** y pulsá **Activate**. Abrí **Settings**, configurá Start/Split y las opciones, elegí **Game Time** y guardá los splits. Quitá el Scriptable Auto Splitter manual del layout si lo usabas antes, para que solo quede una instancia. LiveSplit documenta la activación desde el editor de splits; su catálogo se descarga y también puede usar una copia local si falla la red. [LiveSplit](https://github.com/LiveSplit/LiveSplit), [lector del catálogo](https://github.com/LiveSplit/LiveSplit/blob/master/src/LiveSplit.Core/Model/AutoSplitterFactory.cs).

## 3. Entregar actualizaciones

La propuesta conserva una URL estable al archivo de `main`. Por eso, para distribuir otro ASL se actualiza ese mismo archivo; no hay que registrar de nuevo Furi mientras nombre, ruta y metadatos sigan vigentes. Esto se deriva de que el catálogo guarda una URL de descarga, sin un número de versión del ASL. [Catálogo oficial](https://github.com/LiveSplit/LiveSplit.AutoSplitters/blob/master/LiveSplit.AutoSplitters.xml).

Flujo recomendado para este proyecto:

1. Desarrollá y probá en una rama. Una vez registrado, el ASL de `main` será la fuente de distribución: no subas allí experimentos sin verificar.
2. Usá **1.0.1** para correcciones, **1.1.0** para funciones compatibles y **2.0.0** para cambios que rompan el comportamiento/configuración anterior. Es una convención del proyecto, no un requisito del catálogo.
3. Actualizá cabecera, versión visible y mensajes del ASL, README, LEEME, REPORTAR-ERROR, AGENTS, contexto y changelogs en ambos idiomas. Conservá las claves de opciones existentes cuando sea posible.
4. Ejecutá compilación/regresiones, documentá las pruebas en vivo pertinentes y generá el nuevo ZIP con `Empaquetar.ps1`.
5. Publicá los cambios aprobados en `main` y creá un tag/release nuevo, por ejemplo `v1.0.1`, con su ZIP. No reemplaces silenciosamente un tag anterior.
6. Los usuarios del catálogo obtienen el contenido servido por la misma URL mediante LiveSplit. Para comprobar una actualización, fuera de una run, reiniciá LiveSplit y verificá la versión compatible con Furi abierto; si sigue mostrando la anterior, desactivá/reactivá el autosplitter y revisá conexión/caché. No se promete actualización instantánea de una instancia que ya está ejecutándose.
7. Los usuarios que cargan una copia local mediante **Script Path** deben descargar y reemplazar esa copia manualmente. Un nuevo ZIP o tag no cambia su archivo local.

Solo se necesita otro PR al catálogo si cambia su entrada, por ejemplo la URL, los nombres de juego o la descripción. Si se detecta un fallo, revertí la lógica problemática mediante un nuevo commit y publicá otra versión de corrección, conservando el historial.
