-- Solo lectura. Ruta candidata para esta DLL de Mono, sin direcciones absolutas.
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
local base = getAddressSafe('mono-2.0-bdwgc.dll') or getAddressSafe('mono-2.0-bdwgc')
assert(base and base ~= 0, 'No se pudo resolver modulo Mono')
local raiz = base+0x49AC78
local dominio = readPointer(raiz)
assert(dominio and dominio ~= 0, 'No hay dominio en el offset candidato')
local coincide = false
for _, actual in ipairs(mono_enumDomains() or {}) do
  if actual == dominio then coincide = true end
end
assert(coincide, 'El puntero no coincide con dominios Mono: descartar ruta')
local referencia = dominio+0x1ED08
local gm = readPointer(referencia)
assert(gm and gm ~= 0, 'Sin GameManager (ejecutar en arena)')
local clase = mono_findClass('', 'GameManager')
assert(clase and clase ~= 0, 'Falta clase GameManager')
local tabla = mono_class_getVTable(dominio, clase)
assert(tabla and tabla ~= 0 and readPointer(gm) == tabla, 'Clase GameManager no coincide')
print('--- VALIDAR RUTA DESDE MODULO ---')
print('PID:', getOpenedProcessID())
print(string.format('Mono base=%X | raiz=%X | dominio=%X | ref=%X | GM=%X',
  base, raiz, dominio, referencia, gm))
print(string.format('estado=%s | sub=%s | final=%s',
  tostring(readInteger(gm+0x64)), tostring(readInteger(gm+0x70)),
  tostring(readBytes(gm+0x7B,1))))
print('Dominio y clase coinciden con Mono en este proceso.')
furiRutaModulo = {pid=getOpenedProcessID(), base=base, dominio=dominio, referencia=referencia, gm=gm}
print('--- FIN VALIDAR RUTA ---')
