-- Ejecutar DESPUES de cambiar de escena o reiniciar carrera.
-- No volver a ejecutar BuscarReferencias.lua antes de comparar.
-- Solo lee los lugares guardados durante la busqueda anterior.
assert(furiReferencias and #furiReferencias > 0,
  'No estan las referencias guardadas; no cierres Lua Engine')
assert(furiClaseGameManager, 'Falta la clase guardada')
assert(furiReferenciasPID == getOpenedProcessID(), 'Las referencias son de otro proceso')
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
local tablas = {}
for _, dominio in ipairs(mono_enumDomains() or {}) do
  local tabla = mono_class_getVTable(dominio, furiClaseGameManager)
  if tabla and tabla ~= 0 then tablas[tabla] = true end
end
assert(next(tablas), 'No se pudo obtener la tabla de GameManager')
print('--- COMPARACION TRAS CAMBIO DE ESCENA ---')
for i, referencia in ipairs(furiReferencias) do
  local objeto = readPointer(referencia)
  if objeto and objeto ~= 0 then
    local tabla = readPointer(objeto)
    if tabla and tablas[tabla] then
      print(string.format(
        '#%d ref=%X -> GM=%X | estado=%s | previo=%s | actual=%s | final=%s | anterior=%s',
        i, referencia, objeto,
        tostring(readInteger(objeto + 0x64)),
        tostring(readInteger(objeto + 0x6C)),
        tostring(readInteger(objeto + 0x70)),
        tostring(readBytes(objeto + 0x7B, 1)),
        tostring(objeto == furiGameManagerReferenciaOrigen)))
    else
      print(string.format('#%d: ya no apunta a un candidato GameManager', i))
    end
  else
    print(string.format('#%d: vacia o ilegible', i))
  end
end
print('--- FIN COMPARACION ---')
