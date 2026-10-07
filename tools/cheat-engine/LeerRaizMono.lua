-- Solo lectura. Muestra la funcion exportada que devuelve el dominio Mono.
assert(LaunchMonoDataCollector() ~= 0, 'No se pudo activar Mono')
print('--- RAIZ MONO ---')
print('PID:', getOpenedProcessID())
for _, dominio in ipairs(mono_enumDomains() or {}) do
  print(string.format('Dominio actual=%X', dominio))
end
local vistos = {}
local cantidad = 0
for _, simbolo in ipairs({
  'mono-2.0-bdwgc.mono_get_root_domain',
  'mono-2.0-bdwgc.dll.mono_get_root_domain',
  'mono.mono_get_root_domain',
  'mono_get_root_domain'
}) do
  local direccion = getAddressSafe(simbolo)
  if direccion and direccion ~= 0 and not vistos[direccion] then
    vistos[direccion] = true
    cantidad = cantidad+1
    print(string.format('Simbolo=%s | direccion=%X', simbolo, direccion))
    local actual = direccion
    for i = 1, 6 do
      print(disassemble(actual))
      local largo = getInstructionSize(actual)
      if not largo or largo <= 0 then break end
      actual = actual+largo
    end
  end
end
if cantidad == 0 then print('No se resolvio export mono_get_root_domain; revisar simbolos') end
print('--- FIN RAIZ MONO ---')
