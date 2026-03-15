#!/bin/bash

echo "🔧 Verificación de Keys Duplicadas - Alumnos.js"
echo "==============================================="
echo ""

echo "🔍 Verificando keys duplicadas en formData..."

# Buscar patrones de keys duplicadas
DUPLICATE_CHECK=$(grep -A 15 "setFormData({" incidencias-frontend/src/pages/Alumnos.js | grep -E "nombres|apellido_paterno|apellido_materno" | sort | uniq -d)

if [ -z "$DUPLICATE_CHECK" ]; then
    echo "✅ No se encontraron keys duplicadas"
else
    echo "❌ Keys duplicadas encontradas:"
    echo "$DUPLICATE_CHECK"
fi

echo ""
echo "🔍 Contando ocurrencias de cada field..."

NOMBRES_COUNT=$(grep -c "nombres:" incidencias-frontend/src/pages/Alumnos.js)
APELLIDO_P_COUNT=$(grep -c "apellido_paterno:" incidencias-frontend/src/pages/Alumnos.js)
APELLIDO_M_COUNT=$(grep -c "apellido_materno:" incidencias-frontend/src/pages/Alumnos.js)

echo "📊 Conteo de fields:"
echo "   - nombres: $NOMBRES_COUNT ocurrencias"
echo "   - apellido_paterno: $APELLIDO_P_COUNT ocurrencias"
echo "   - apellido_materno: $APELLIDO_M_COUNT ocurrencias"

if [[ $NOMBRES_COUNT -le 2 && $APELLIDO_P_COUNT -le 2 && $APELLIDO_M_COUNT -le 2 ]]; then
    echo "✅ Conteo de fields normal (máximo 2 por field: initial state + edit state)"
else
    echo "⚠️ Conteo de fields elevado - posibles duplicados"
fi

echo ""
echo "🎯 Estado esperado:"
echo "=================="
echo "Cada field debería aparecer máximo 2 veces:"
echo "1. En el estado inicial del formData"
echo "2. En el handleOpenDialog para edición"
echo ""

echo "📝 Estructura correcta del formData:"
echo "-----------------------------------"
echo "{"
echo "  nombres: '',"
echo "  apellido_paterno: '',"
echo "  apellido_materno: '',"
echo "  matricula: '',"
echo "  id_grupo: '',"
echo "  fecha_nacimiento: '',"
echo "  telefono: '',"
echo "  email: '',"
echo "  sexo: ''"
echo "}"

echo ""
echo "🌐 Para verificar:"
echo "=================="
echo "1. Ve a http://localhost:3000"
echo "2. Verifica que la compilación no muestre warnings"
echo "3. Navega a la página de Alumnos"
echo "4. Prueba crear/editar un alumno"

echo ""
if [ -z "$DUPLICATE_CHECK" ]; then
    echo "🎉 ¡Warning de keys duplicadas resuelto!"
else
    echo "⚠️ Aún hay keys duplicadas que necesitan corrección"
fi