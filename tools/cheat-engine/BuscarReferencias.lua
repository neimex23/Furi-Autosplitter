-- Solo busca referencias en memoria. No modifica el juego.
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
assert(furiSesion and furiSesion.pid == getOpenedProcessID(),
  'Ejecuta ResolverSesion.lua primero en el proceso actual')
local claseBuscada = mono_findClass('', 'GameManager')
assert(claseBuscada and claseBuscada ~= 0, 'Falta clase GameManager')
local estadoOffset
for _, f in ipairs(mono_class_enumFields(claseBuscada) or {}) do
  if f.name == '_gameState' and not f.isStatic then estadoOffset = f.offset end
end
assert(estadoOffset, 'Falta campo _gameState')
local gm
for _, candidato in ipairs(furiSesion.gameManagers) do
  local claseActual, nombreActual = mono_object_getClass(candidato)
  if claseActual == claseBuscada and nombreActual == 'GameManager'
    and readInteger(candidato+estadoOffset) == 4 then
    assert(not gm, 'Hay varios candidatos de arena: no elegir automaticamente')
    gm = candidato
  end
end
assert(gm, 'No hay candidato de arena valido: repite ResolverSesion.lua en el jefe')
local clase, nombre = mono_object_getClass(gm)
assert(clase and nombre == 'GameManager', 'La direccion ya cambio: detener prueba')
print('--- BUSQUEDA DE REFERENCIAS ---')
print(string.format('GameManager de arena candidato: %X', gm))
local scan = createMemScan()
scan.firstScan(soExactValue, vtQword, rtRounded,
  string.format('%X', gm), '', 0, 0x7FFFFFFFFFFF,
  '', fsmAligned, '8', true, true, false, false)
scan.waitTillDone()
local lista = createFoundList(scan)
lista.initialize()
furiReferencias = {}
furiClaseGameManager = clase
furiGameManagerReferenciaOrigen = gm
furiReferenciasPID = getOpenedProcessID()
print('Referencias encontradas:', lista.Count)
for i = 0, math.min(lista.Count, 200) - 1 do
  local direccion = tonumber(lista[i], 16)
  furiReferencias[#furiReferencias + 1] = direccion
  if i < 40 then print(string.format('Referencia %d: %X', i + 1, direccion)) end
end
if lista.Count > 40 then print('Se muestran solo las primeras 40') end
lista.destroy()
scan.destroy()
print('--- FIN REFERENCIAS ---')
