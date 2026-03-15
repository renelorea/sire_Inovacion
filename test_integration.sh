#!/bin/bash

echo "🧪 Probando la integración Frontend-Backend..."
echo ""

# Verificar backend
echo "1️⃣ Verificando Backend (Puerto 5000):"
echo "----------------------------------------"

# Probar login
echo "🔑 Probando login con admin@sistema.com..."
LOGIN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"correo":"admin@sistema.com","contraseña":"123456"}' http://localhost:5000/api/login)

if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    echo "✅ Login exitoso!"
    echo "📄 Respuesta del backend: $LOGIN_RESPONSE"
    
    # Extraer token
    TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    echo "🎫 Token obtenido: ${TOKEN:0:50}..."
    
    # Probar endpoint protegido
    echo ""
    echo "2️⃣ Probando endpoint protegido (/api/usuarios):"
    echo "------------------------------------------------"
    
    USUARIOS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:5000/api/usuarios)
    
    if echo "$USUARIOS_RESPONSE" | grep -q "usuarios\|error"; then
        echo "✅ Endpoint de usuarios respondiendo!"
        echo "📄 Respuesta: $(echo $USUARIOS_RESPONSE | head -c 200)..."
    else
        echo "❌ Error en endpoint de usuarios"
        echo "📄 Respuesta: $USUARIOS_RESPONSE"
    fi
    
else
    echo "❌ Login falló!"
    echo "📄 Respuesta del backend: $LOGIN_RESPONSE"
fi

echo ""
echo "3️⃣ Verificando Frontend (Puerto 3000):"
echo "---------------------------------------"

FRONTEND_RESPONSE=$(curl -s http://localhost:3000)
if echo "$FRONTEND_RESPONSE" | grep -q "html"; then
    echo "✅ Frontend React ejecutándose correctamente!"
else
    echo "❌ Frontend no está respondiendo"
fi

echo ""
echo "🎯 Instrucciones para usar la aplicación:"
echo "=========================================="
echo "1. 🌐 Abre http://localhost:3000 en tu navegador"
echo "2. 🔑 Usa estas credenciales:"
echo "   📧 Email: admin@sistema.com"
echo "   🔒 Contraseña: 123456"
echo "3. ✨ ¡Disfruta la aplicación!"
echo ""

echo "🔧 Si tienes problemas:"
echo "----------------------"
echo "- Verifica que ambos servidores estén ejecutándose"
echo "- Abre las herramientas de desarrollador del navegador (F12)"
echo "- Busca errores en la consola"
echo "- Verifica que la URL en .env sea http://localhost:5000/api"