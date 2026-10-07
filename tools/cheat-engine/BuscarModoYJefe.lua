-- Busca candidatos GlobalGameManager y lee modo/jefe. No escribe en el juego.
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
local clase = mono_findClass('', 'GlobalGameManager')
assert(clase and clase ~= 0, 'No se encontro GlobalGameManager')
local offsets = {}
local campoJefe
for _, campo in ipairs(mono_class_enumFields(clase) or {}) do
  if not campo.isStatic then offsets[campo.name] = campo.offset end
  if campo.name == 'currentBossLevel' and campo.isStatic then campoJefe = campo.field end
end
assert(campoJefe and offsets._currentGameMode, 'Faltan campos esperados')
local tabla = mono_class_getVTable(0, clase)
assert(tabla and tabla ~= 0, 'No se encontro la tabla de clase')
print('--- MODO Y JEFE V2 ---')
print(string.format('Offset de modo: %X', offsets._currentGameMode))
local cadena = mono_getStaticFieldValue(tabla, campoJefe)
local jefe = '(no disponible)'
if cadena and cadena ~= 0 then
  local largo = readInteger(cadena+0x10)
  if largo and largo >= 0 and largo <= 100 then
    jefe = readString(cadena+0x14, largo*2, true) or '(ilegible)'
  end
end
print('Jefe actual (campo estatico):', jefe)
local scan = createMemScan()
scan.firstScan(soExactValue, vtQword, rtRounded, string.format('%X', tabla),
  '', 0, 0x7FFFFFFFFFFF, '', fsmAligned, '8', true, true, false, false)
scan.waitTillDone()
local lista = createFoundList(scan)
lista.initialize()
local cantidad = 0
for i = 0, lista.Count-1 do
  local obj = tonumber(lista[i], 16)
  local modo = readInteger(obj+offsets._currentGameMode)
  if modo and modo >= 0 and modo <= 4 then
    cantidad = cantidad+1
    if cantidad <= 40 then
      print(string.format('Candidato=%X | modo=%d', obj, modo))
    end
  end
end
print('Candidatos con modo en rango (maximo 40 mostrados):', cantidad)
lista.destroy()
scan.destroy()
print('--- FIN MODO Y JEFE ---')
