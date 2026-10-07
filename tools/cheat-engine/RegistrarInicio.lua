-- Solo lectura. Ejecutar tras ResolverSesion.lua, antes de START.
assert(furiSesion and furiSesion.pid == getOpenedProcessID(),
  'Ejecuta ResolverSesion.lua primero en este proceso')
assert(#furiSesion.globales > 0, 'No hay candidatos globales')
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
local function campos(nombre)
  local clase = mono_findClass('', nombre)
  assert(clase and clase ~= 0, 'Falta clase '..nombre)
  local resultado = {}
  for _, f in ipairs(mono_class_enumFields(clase) or {}) do
    if not f.isStatic then
      resultado[f.name] = f.offset
      local propiedad = f.name:match('^<(.+)>k__BackingField$')
      if propiedad then resultado[propiedad] = f.offset end
    end
  end
  local tabla = mono_class_getVTable(0, clase)
  assert(tabla and tabla ~= 0, 'No se obtuvo tabla de '..nombre)
  return resultado, tabla
end
local g, tablaGlobal = campos('GlobalGameManager')
local d, tablaDatos = campos('GameDataInfo')
assert(g._currentGameMode and g._currentGameData and d._currentLevel
  and d._gameMode and d._gameDifficulty, 'Faltan campos')
local function cadena(p)
  if not p or p == 0 then return '(nula)' end
  local n = readInteger(p+0x10)
  if not n or n < 0 or n > 150 then return '(ilegible)' end
  if n == 0 then return '(vacia)' end
  return readString(p+0x14, n*2, true) or '(ilegible)'
end
local candidatos = {}
for _, obj in ipairs(furiSesion.globales) do candidatos[#candidatos+1] = obj end
local inicio = getTickCount()
local anteriores = {}
local pid = getOpenedProcessID()
furiInicioRegistro = {}
local function muestra()
  assert(getOpenedProcessID() == pid, 'Cambio el proceso adjunto')
  for _, obj in ipairs(candidatos) do
    local texto = string.format('Global=%X | INVALIDO', obj)
    if readPointer(obj) == tablaGlobal then
      local partida = readPointer(obj+g._currentGameData)
      texto = string.format('Global=%X | modo=%s | partida=%X',
        obj, tostring(readInteger(obj+g._currentGameMode)), partida or 0)
      if partida and partida ~= 0 then
        if readPointer(partida) == tablaDatos then
          texto = texto..string.format(' | nivel=%s | modoPartida=%s | dificultad=%s',
            cadena(readPointer(partida+d._currentLevel)),
            tostring(readInteger(partida+d._gameMode)),
            tostring(readInteger(partida+d._gameDifficulty)))
        else
          texto = texto..' | partida sin clase validada'
        end
      end
    end
    if anteriores[obj] ~= texto then
      anteriores[obj] = texto
      local linea = string.format('[%.2fs] %s', (getTickCount()-inicio)/1000, texto)
      furiInicioRegistro[#furiInicioRegistro+1] = linea
      print(linea)
    end
  end
end
print('--- REGISTRO DE INICIO: cada 100 ms, solo cambios ---')
print('No redescubre objetos nuevos: INVALIDO requiere repetir ResolverSesion.lua.')
muestra()
furiMonitor = createTimer(nil, false)
furiMonitor.Interval = 100
furiMonitor.OnTimer = function(t)
  local ok, err = pcall(muestra)
  if not ok then t.Enabled=false; print('MONITOR DETENIDO:', tostring(err)) end
end
furiMonitor.Enabled = true
print('Monitor activo. Para detener: furiMonitor.destroy(); furiMonitor=nil')
