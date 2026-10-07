-- Diagnostico de la sesion actual; solo lectura.
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
local function campos(nombre)
  local clase = mono_findClass('', nombre)
  assert(clase and clase ~= 0, 'Falta clase '..nombre)
  local resultado = {}
  for _, f in ipairs(mono_class_enumFields(clase) or {}) do
    if not f.isStatic then resultado[f.name] = f.offset end
  end
  return resultado
end
local global = campos('GlobalGameManager')
local datos = campos('GameDataInfo')
assert(global._currentGameData and global._currentGameMode and datos._currentLevel
  and datos._gameMode and datos._gameDifficulty and datos._currentTime, 'Faltan campos')
local function cadena(p)
  if not p or p == 0 then return '(nula)' end
  local largo = readInteger(p+0x10)
  if not largo or largo < 0 or largo > 150 then return '(ilegible)' end
  return readString(p+0x14, largo*2, true) or '(ilegible)'
end
print('--- DATOS DE PARTIDA ---')
print(string.format('Offsets: datos=%X | nivel=%X | modoPartida=%X | dificultad=%X',
  global._currentGameData, datos._currentLevel, datos._gameMode, datos._gameDifficulty))
for _, gm in ipairs({0x22D7C21B2A0, 0x22D7C21B7E0}) do
  local partida = readPointer(gm+global._currentGameData)
  print(string.format('Global=%X | modo=%s | partida=%X',
    gm, tostring(readInteger(gm+global._currentGameMode)), partida or 0))
  if partida and partida ~= 0 then
    print('Nivel:', cadena(readPointer(partida+datos._currentLevel)))
    print('Modo partida:', readInteger(partida+datos._gameMode))
    print('Dificultad:', readInteger(partida+datos._gameDifficulty))
    print('Tiempo guardado (interpretacion pendiente):', readInteger(partida+datos._currentTime))
  end
end
print('--- FIN DATOS DE PARTIDA ---')
