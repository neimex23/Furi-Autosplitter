-- Diagnostico de solo lectura. Resuelve candidatos en el proceso adjunto actual.
-- No reutiliza direcciones de sesiones anteriores ni controla LiveSplit.
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono: adjunta Cheat Engine a Furi')

local function claseYCampos(nombre)
  local clase = mono_findClass('', nombre)
  assert(clase and clase ~= 0, 'Falta clase '..nombre)
  local campos = {}
  for _, f in ipairs(mono_class_enumFields(clase) or {}) do
    if not f.isStatic then
      campos[f.name] = f.offset
      -- Las propiedades automaticas tienen nombres como <endGameTriggered>k__BackingField.
      local propiedad = f.name:match('^<(.+)>k__BackingField$')
      if propiedad then campos[propiedad] = f.offset end
    end
  end
  return clase, campos
end

local function instancias(clase)
  local tabla = mono_class_getVTable(0, clase)
  assert(tabla and tabla ~= 0, 'No se pudo obtener tabla de clase')
  local scan = createMemScan()
  scan.firstScan(soExactValue, vtQword, rtRounded, string.format('%X', tabla),
    '', 0, 0x7FFFFFFFFFFF, '', fsmAligned, '8', true, true, false, false)
  scan.waitTillDone()
  local lista = createFoundList(scan)
  lista.initialize()
  local objetos = {}
  for i = 0, lista.Count-1 do objetos[#objetos+1] = tonumber(lista[i], 16) end
  lista.destroy()
  scan.destroy()
  return objetos
end

local function cadena(p)
  if not p or p == 0 then return '(nula)' end
  local largo = readInteger(p+0x10)
  if not largo or largo < 0 or largo > 150 then return '(ilegible)' end
  if largo == 0 then return '(vacia)' end
  return readString(p+0x14, largo*2, true) or '(ilegible)'
end

local globalClase, global = claseYCampos('GlobalGameManager')
local datosClase, datos = claseYCampos('GameDataInfo')
local gmClase, gmCampos = claseYCampos('GameManager')
assert(global._currentGameData and global._currentGameMode and datos._currentLevel
  and datos._gameMode and datos._gameDifficulty, 'Faltan campos de partida')
local gmCompleto = gmCampos._gameState and gmCampos._gameSubState and gmCampos.endGameTriggered
if not gmCompleto then
  print('GameManager: faltan campos; se leeran los datos globales igualmente.')
  for _, f in ipairs(mono_class_enumFields(gmClase) or {}) do
    print(string.format('  Campo=%s | offset=%s | estatico=%s',
      tostring(f.name), tostring(f.offset), tostring(f.isStatic)))
  end
else
  print(string.format('Offsets GM: estado=%X | sub=%X | final=%X',
    gmCampos._gameState, gmCampos._gameSubState, gmCampos.endGameTriggered))
end

print('--- RESOLVER SESION ACTUAL ---')
furiSesion = {pid=getOpenedProcessID(), globales={}, gameManagers={}}
for _, obj in ipairs(instancias(globalClase)) do
  local modo = readInteger(obj+global._currentGameMode)
  if modo and modo >= 0 and modo <= 4 then
    local partida = readPointer(obj+global._currentGameData)
    furiSesion.globales[#furiSesion.globales+1] = obj
    print(string.format('Global=%X | modo=%d | partida=%X', obj, modo, partida or 0))
    if partida and partida ~= 0 then
      print('  Nivel:', cadena(readPointer(partida+datos._currentLevel)))
      print('  Modo partida:', readInteger(partida+datos._gameMode))
      print('  Dificultad:', readInteger(partida+datos._gameDifficulty))
    end
  end
end
for _, obj in ipairs(gmCompleto and instancias(gmClase) or {}) do
  local estado = readInteger(obj+gmCampos._gameState)
  local sub = readInteger(obj+gmCampos._gameSubState)
  local final = readBytes(obj+gmCampos.endGameTriggered, 1)
  if estado and estado >= 0 and estado <= 17 and sub and sub >= 0 and sub <= 9
    and (final == 0 or final == 1) then
    furiSesion.gameManagers[#furiSesion.gameManagers+1] = obj
    print(string.format('GameManager=%X | estado=%d | sub=%d | final=%d', obj, estado, sub, final))
  end
end
print('PID:', furiSesion.pid)
print('Candidatos globales:', #furiSesion.globales, '| GameManager:', #furiSesion.gameManagers)
print('Son candidatos de memoria; falta contrastar su comportamiento.')
print('--- FIN RESOLVER SESION ---')
