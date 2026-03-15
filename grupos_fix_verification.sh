#!/bin/bash

echo "🔧 Verificación de Correcciones en Página de Grupos"
echo "=================================================="
echo ""

echo "✅ Errores corregidos en Grupos.js:"
echo "-----------------------------------"
echo "1. ❌ ANTES: 'key={grupo.id}' (campo inexistente)"
echo "   ✅ AHORA: 'key={grupo.id_grupo}' (campo correcto del backend)"
echo ""

echo "2. ❌ ANTES: Renderizando campos inexistentes (nombre, turno, aula, etc.)"
echo "   ✅ AHORA: Renderizando campos reales del backend (grado, ciclo, idtutor, descripcion)"
echo ""

echo "3. ❌ ANTES: Objeto completo pasado como React child"
echo "   ✅ AHORA: Propiedades individuales renderizadas correctamente"
echo ""

echo "🧪 Validaciones automáticas:"
echo "----------------------------"

# Verificar que usamos el campo correcto para key
KEY_CHECK=$(grep -n "key={grupo.id_grupo}" incidencias-frontend/src/pages/Grupos.js)
if [ ! -z "$KEY_CHECK" ]; then
    echo "✅ Key correcto encontrado en línea: $KEY_CHECK"
else
    echo "❌ Key incorrecto o no encontrado"
fi

# Verificar que usamos campos del backend
BACKEND_FIELDS=$(grep -n "grupo.ciclo\|grupo.idtutor\|grupo.descripcion" incidencias-frontend/src/pages/Grupos.js)
if [ ! -z "$BACKEND_FIELDS" ]; then
    echo "✅ Campos del backend encontrados:"
    echo "$BACKEND_FIELDS"
else
    echo "❌ Campos del backend no encontrados"
fi

# Verificar que no hay campos incorrectos
WRONG_FIELDS=$(grep -n "grupo.nombre\|grupo.turno\|grupo.aula\|grupo.profesor_titular" incidencias-frontend/src/pages/Grupos.js || true)
if [ -z "$WRONG_FIELDS" ]; then
    echo "✅ No se encontraron campos incorrectos"
else
    echo "❌ Campos incorrectos encontrados:"
    echo "$WRONG_FIELDS"
fi

echo ""
echo "📋 Estructura de datos esperada del backend:"
echo "-------------------------------------------"
echo "{"
echo "  \"id_grupo\": 1,"
echo "  \"grado\": \"3ro\"," 
echo "  \"ciclo\": \"2025-2026\","
echo "  \"idtutor\": 5,"
echo "  \"descripcion\": \"Grupo de tercer grado\""
echo "}"

echo ""
echo "🌐 URLs para probar:"
echo "-------------------"
echo "Grupos: http://localhost:3000/grupos"
echo "Error Check: http://localhost:3000/error-check"

echo ""
echo "🎯 Para verificar la corrección:"
echo "================================"
echo "1. Ve a http://localhost:3000/grupos"
echo "2. Verifica que la tabla muestre datos sin errores"
echo "3. Abre F12 y verifica que no hay errores de React"
echo "4. Intenta crear/editar un grupo para confirmar funcionalidad"

echo ""
echo "🆘 Si aún hay errores:"
echo "====================="
echo "- Verifica que el backend esté devolviendo la estructura correcta"
echo "- Usa http://localhost:3000/error-check para monitorear errores"
echo "- Revisa la consola del navegador (F12) para más detalles"