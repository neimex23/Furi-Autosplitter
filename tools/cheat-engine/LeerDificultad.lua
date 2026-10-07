-- Diagnostico de solo lectura: campos de dificultad, sin elegir GM por estado.
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
assert(furiSesion and furiSesion.pid == getOpenedProcessID(), 'Falta ResolverSesion actual')
local function revisar(obj, nombreEsperado)
  local clase, nombre = mono_object_getClass(obj)
  if not clase or clase == 0 or nombre ~= nombreEsperado then return end
  print(string.format('Objeto=%X | clase=%s', obj, nombre))
  local encontrados = 0
  for _, f in ipairs(mono_class_enumFields(clase) or {}) do
    local n = f.name:lower()
    if n:find('difficult', 1, true) then
      encontrados = encontrados+1
      print(string.format('  Campo=%s | offset=%X | estatico=%s',
        f.name, f.offset or 0, tostring(f.isStatic)))
      if not f.isStatic and f.offset then
        print('  Lectura int32 (interpretacion pendiente):', readInteger(obj+f.offset))
      end
    elseif n:find('setting', 1, true) or n:find('option', 1, true)
      or n:find('speedrun', 1, true) or n:find('gamedata', 1, true) then
      print(string.format('  Campo relacionado=%s | offset=%X | estatico=%s',
        f.name, f.offset or 0, tostring(f.isStatic)))
    end
  end
  print('  Campos de dificultad encontrados:', encontrados)
end
print('--- DIAGNOSTICO DIFICULTAD ---')
local claseGlobal = mono_findClass('', 'GlobalGameManager')
local modoOffset, datosOffset
for _, f in ipairs(mono_class_enumFields(claseGlobal) or {}) do
  if not f.isStatic and f.name == '_currentGameMode' then modoOffset=f.offset end
  if not f.isStatic and f.name == '_currentGameData' then datosOffset=f.offset end
end
assert(modoOffset and datosOffset, 'Faltan campos globales')
for _, obj in ipairs(furiSesion.globales) do
  local clase = mono_object_getClass(obj)
  if clase == claseGlobal and readInteger(obj+modoOffset) == 4 then
    revisar(obj, 'GlobalGameManager')
    local partida = readPointer(obj+datosOffset)
    if partida and partida ~= 0 then revisar(partida, 'GameDataInfo') end
  end
end
-- La referencia de la prueba anterior identifica el GM actual; los viejos pueden seguir vivos.
if furiReferenciasPID == getOpenedProcessID() and furiReferencias then
  for i, ref in ipairs(furiReferencias) do
    local obj = readPointer(ref)
    if obj and obj ~= 0 then
      local clase, nombre = mono_object_getClass(obj)
      if clase and clase ~= 0 and nombre == 'GameManager' then
        print(string.format('Referencia #%d=%X', i, ref))
        revisar(obj, 'GameManager')
      end
    end
  end
end
print('--- FIN DIAGNOSTICO DIFICULTAD ---')
