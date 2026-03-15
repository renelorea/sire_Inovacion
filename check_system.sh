#!/bin/bash

echo "🧪 Prueba Completa del Sistema de Incidencias Escolares"
echo "======================================================"
echo ""

# Verificar que ambos servidores estén ejecutándose
echo "🔍 Verificando servidores..."
echo ""

# Backend
BACKEND_STATUS=$(curl -s -w "%{http_code}" http://localhost:5000/api/ -o /dev/null)
if [ "$BACKEND_STATUS" = "000" ]; then
    echo "❌ Backend no está ejecutándose en el puerto 5000"
    echo "💡 Ejecuta: cd backend && python app.py"
    echo ""
else
    echo "✅ Backend ejecutándose en puerto 5000"
fi

# Frontend
FRONTEND_STATUS=$(curl -s -w "%{http_code}" http://localhost:3000 -o /dev/null)
if [ "$FRONTEND_STATUS" = "000" ]; then
    echo "❌ Frontend no está ejecutándose en el puerto 3000"
    echo "💡 Ejecuta: cd incidencias-frontend && npm start"
    echo ""
else
    echo "✅ Frontend ejecutándose en puerto 3000"
fi

if [ "$BACKEND_STATUS" != "000" ] && [ "$FRONTEND_STATUS" != "000" ]; then
    echo ""
    echo "🎉 ¡Ambos servidores están funcionando!"
    echo ""
    echo "🔑 Credenciales de prueba:"
    echo "------------------------"
    echo "📧 Email: admin@sistema.com"
    echo "🔒 Contraseña: 123456"
    echo ""
    echo "🌐 URL de la aplicación: http://localhost:3000"
    echo ""
    echo "✨ ¡Abre tu navegador y prueba la aplicación!"
    
    # Probar login para confirmar
    echo ""
    echo "🧪 Probando login desde el backend..."
    LOGIN_TEST=$(curl -s -X POST -H "Content-Type: application/json" -d '{"correo":"admin@sistema.com","contraseña":"123456"}' http://localhost:5000/api/login)
    
    if echo "$LOGIN_TEST" | grep -q "access_token"; then
        echo "✅ Login de backend funcionando correctamente!"
        echo ""
        echo "📝 Pasos para usar la aplicación:"
        echo "1. Abre http://localhost:3000 en tu navegador"
        echo "2. Haz clic en 'Iniciar Sesión'"
        echo "3. Ingresa las credenciales de arriba"
        echo "4. Explora las diferentes secciones (Usuarios, Estudiantes, Grupos, Reportes)"
    else
        echo "❌ Error en el login del backend"
        echo "📄 Respuesta: $LOGIN_TEST"
    fi
else
    echo "⚠️ Asegúrate de que ambos servidores estén ejecutándose"
fi

echo ""
echo "🆘 Si encuentras problemas:"
echo "============================"
echo "1. Verifica que no haya errores en la consola del navegador (F12)"
echo "2. Asegúrate de que el backend esté ejecutándose sin errores"
echo "3. Confirma que el frontend compile correctamente"
echo "4. Revisa que no haya conflictos de puertos"