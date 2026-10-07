-- Ejecutar en Lua Engine de Cheat Engine, en esta misma sesion de Furi.
-- Solo consulta metadatos y valores; no modifica campos del juego.
local gm = 0x22EF52869A0
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
local clase, nombre = mono_object_getClass(gm)
assert(clase and clase ~= 0 and nombre == 'GameManager',
  'La direccion ya no corresponde a GameManager; detener esta prueba')
local buscada = mono_findClass('', 'GameManager')
local padre = mono_class_getParent(clase)
assert(padre and padre ~= 0, 'No se encontro la clase base')
print('--- REFERENCIA ---')
print(string.format('Objeto: %X | Clase real: %X | Clase por nombre: %X',
  gm, clase, buscada or 0))
print('Clase base:', mono_class_getName(padre))
local campo
for _, f in ipairs(mono_class_enumFields(padre) or {}) do
  if f.name == '_instance' and f.isStatic then campo = f.field; break end
end
assert(campo, 'No se encontro _instance en la clase base')
for _, dominio in ipairs(mono_enumDomains() or {}) do
  local tabla = mono_class_getVTable(dominio, padre)
  if tabla and tabla ~= 0 then
    local valor = mono_getStaticFieldValue(tabla, campo)
    print(string.format('Dominio: %X | Instancia: %X | Coincide: %s',
      dominio, valor or 0, tostring(valor == gm)))
  else
    print(string.format('Dominio: %X | Sin tabla', dominio))
  end
end
print('--- FIN REFERENCIA ---')
