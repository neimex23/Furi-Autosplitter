-- Solo lectura. Prueba rutas candidatas desde Mono en un proceso nuevo.
if furiMonitor then furiMonitor.destroy(); furiMonitor=nil end
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
local base = getAddressSafe('mono-2.0-bdwgc.dll') or getAddressSafe('mono-2.0-bdwgc')
assert(base and base ~= 0, 'No se encontro modulo Mono')
local dominio = readPointer(base+0x49AC78)
local coincide = false
for _, actual in ipairs(mono_enumDomains() or {}) do
  if actual == dominio then coincide=true end
end
assert(coincide, 'El offset de raiz no coincide con dominio Mono')
local function validar(obj, nombre)
  assert(obj and obj ~= 0, 'Sin objeto '..nombre..': ejecutar en Carrera cargada')
  local clase = mono_findClass('', nombre)
  assert(clase and clase ~= 0, 'Falta clase '..nombre)
  local tabla = mono_class_getVTable(dominio, clase)
  assert(tabla and tabla ~= 0 and readPointer(obj) == tabla, 'No coincide clase '..nombre)
  local campos = {}
  for _, f in ipairs(mono_class_enumFields(clase) or {}) do
    if not f.isStatic then
      campos[f.name]=f.offset
      local propiedad=f.name:match('^<(.+)>k__BackingField$')
      if propiedad then campos[propiedad]=f.offset end
    end
  end
  return campos
end
local gm = readPointer(dominio+0x1ED08)
local m = validar(gm,'GameManager')
local global = readPointer(dominio+0x1EF48)
local g = validar(global,'GlobalGameManager')
assert(g._currentGameData and g._currentGameMode, 'Faltan campos globales')
local partida = readPointer(global+g._currentGameData)
local d = validar(partida,'GameDataInfo')
assert(d._currentLevel and d._gameMode and d._gameDifficulty, 'Faltan campos de partida')
assert(m._gameState and m._gameSubState and m.endGameTriggered, 'Faltan campos GM')
print('--- VALIDAR RUTAS GM Y PARTIDA ---')
print('PID:', getOpenedProcessID())
print(string.format('Mono base=%X | dominio=%X',base,dominio))
print(string.format('GM=%X | estado=%s | sub=%s | final=%s',gm,
  tostring(readInteger(gm+m._gameState)),tostring(readInteger(gm+m._gameSubState)),
  tostring(readBytes(gm+m.endGameTriggered,1))))
print(string.format('Global=%X | modo=%s | partida=%X',global,
  tostring(readInteger(global+g._currentGameMode)),partida))
print('Modo partida:',readInteger(partida+d._gameMode))
print('Dificultad:',readInteger(partida+d._gameDifficulty))
local p=readPointer(partida+d._currentLevel)
local n=p and p ~= 0 and readInteger(p+0x10)
if n and n >= 0 and n <= 150 then
  print('Nivel:', n == 0 and '(vacio)' or readString(p+0x14,n*2,true))
else
  print('Nivel: ilegible')
end
print('Las tres clases y el dominio coinciden con Mono.')
print('--- FIN VALIDAR RUTAS ---')
