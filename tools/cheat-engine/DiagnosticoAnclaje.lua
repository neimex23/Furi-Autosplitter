-- Solo lectura de metadatos y referencias ya guardadas. No escanea ni escribe el juego.
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
assert(furiReferenciasPID == getOpenedProcessID() and furiReferencias,
  'Faltan referencias del proceso actual')
local clase = mono_findClass('', 'GameManager')
assert(clase and clase ~= 0, 'Falta clase GameManager')
local dominios = mono_enumDomains() or {}
assert(#dominios > 0, 'No se encontraron dominios Mono')
print('--- DIAGNOSTICO ANCLAJE ---')
print('PID:', getOpenedProcessID())
for _, dominio in ipairs(dominios) do
  print(string.format('Dominio Mono=%X', dominio))
end
for i, ref in ipairs(furiReferencias) do
  local obj = readPointer(ref)
  if obj and obj ~= 0 then
    local claseActual, nombre = mono_object_getClass(obj)
    if claseActual == clase and nombre == 'GameManager' then
      print(string.format('Referencia #%d=%X -> GM=%X | estado=%s | sub=%s | final=%s',
        i, ref, obj, tostring(readInteger(obj+0x64)),
        tostring(readInteger(obj+0x70)), tostring(readBytes(obj+0x7B,1))))
      for _, dominio in ipairs(dominios) do
        local delta = ref-dominio
        if delta >= 0 then
          print(string.format('  Ref menos dominio %X = +%X', dominio, delta))
        else
          print(string.format('  Ref menos dominio %X = -%X', dominio, -delta))
        end
      end
    end
  end
end
print('Diferencias numericas solamente: no demuestran una ruta estable.')
print('--- FIN DIAGNOSTICO ANCLAJE ---')
