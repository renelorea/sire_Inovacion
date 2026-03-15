# 🎯 Sistema de Incidencias Escolares - Guía de Uso

## ✅ Estado Actual del Sistema

- **Frontend**: ✅ Funcionando en http://localhost:3000
- **Backend**: ✅ Funcionando en http://localhost:5000
- **Base de Datos**: ✅ Conectada a MySQL remoto
- **Autenticación**: ✅ JWT funcionando

## 🔑 Credenciales de Acceso

```
📧 Email: admin@sistema.com
🔒 Contraseña: 123456
```

## 🚀 Cómo usar la aplicación

### 1. Verificar que todo esté funcionando

```bash
# Ejecuta este comando desde la carpeta del proyecto
./check_system.sh
```

### 2. Acceder a la aplicación

1. **Abre tu navegador** y ve a: http://localhost:3000
2. **Haz clic** en "Iniciar Sesión"
3. **Ingresa** las credenciales de arriba
4. **¡Listo!** Ya puedes usar todas las funciones

### 3. Funcionalidades Disponibles

- 📊 **Dashboard**: Vista general del sistema
- 👥 **Usuarios**: Gestión de usuarios del sistema
- 🎓 **Alumnos**: Administración de estudiantes
- 👥 **Grupos**: Manejo de grupos escolares
- 📝 **Tipos de Reporte**: Configuración de tipos de incidencias
- 📋 **Reportes**: Creación y gestión de reportes de incidencias
- 🔧 **Diagnóstico**: Herramientas para verificar el funcionamiento

## 🛠️ Solución de Problemas

### Si no puedes acceder a la aplicación:

1. **Verifica que ambos servidores estén ejecutándose**:
   ```bash
   # Backend (debe estar en la carpeta backend)
   python app.py
   
   # Frontend (debe estar en la carpeta incidencias-frontend)  
   npm start
   ```

2. **Limpia el almacenamiento del navegador**:
   - Ve a http://localhost:3000/diagnosis
   - Haz clic en "Limpiar Almacenamiento"
   - Recarga la página

3. **Verifica la conexión**:
   - Abre las herramientas de desarrollador (F12)
   - Ve a la pestaña "Console"
   - Busca errores en rojo

### Si el login no funciona:

1. **Verifica las credenciales**:
   - Email: admin@sistema.com
   - Contraseña: 123456

2. **Usa la página de diagnóstico**:
   - Ve a http://localhost:3000/diagnosis (sin login)
   - Ejecuta los diagnósticos automáticos

## 📂 Estructura del Proyecto

```
├── backend/                 # Servidor Flask (Python)
│   ├── app.py              # Archivo principal
│   ├── requirements.txt    # Dependencias
│   └── ...
├── incidencias-frontend/   # Aplicación React
│   ├── src/
│   ├── public/
│   └── package.json
└── check_system.sh        # Script de verificación
```

## 🔄 Comandos Útiles

```bash
# Verificar estado completo
./check_system.sh

# Reiniciar backend
cd backend
python app.py

# Reiniciar frontend  
cd incidencias-frontend
npm start

# Ver logs en tiempo real
tail -f backend/app.log  # Si existe
```

## 🆘 Si Nada Funciona

1. **Reinicia todo**:
   ```bash
   # Mata todos los procesos
   pkill -f "python.*app.py"
   pkill -f "npm.*start"
   
   # Reinicia backend
   cd backend
   python app.py &
   
   # Reinicia frontend
   cd ../incidencias-frontend  
   npm start
   ```

2. **Verifica puertos ocupados**:
   ```bash
   lsof -i :3000  # Frontend
   lsof -i :5000  # Backend
   ```

3. **Contacta al desarrollador** con:
   - Capturas de pantalla de errores
   - Logs de la consola del navegador
   - Resultado del comando `./check_system.sh`

---

## 🎉 ¡Disfruta la aplicación!

La aplicación está completamente funcional y lista para usar. Incluye todas las funcionalidades básicas de un sistema de gestión de incidencias escolares con una interfaz moderna y amigable.

**Características destacadas**:
- ✨ Interfaz moderna con Material-UI
- 🔐 Autenticación segura con JWT
- 📱 Diseño responsive
- 🛡️ Validación de formularios
- 🔄 Estado global de la aplicación
- 🚀 Navegación fluida entre páginas