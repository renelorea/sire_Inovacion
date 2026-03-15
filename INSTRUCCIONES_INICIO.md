# Instrucciones de Inicio - Sistema de Incidencias Escolares

## Backend (Python Flask)

1. **Navegar al directorio del backend**
   ```bash
   cd "/Users/reneloreaayala/Documents/Maestria/Segundo Semestre/Ingenieria de Software/Proyecto/backend"
   ```

2. **Activar entorno virtual** (si tienes uno configurado)
   ```bash
   source venv/bin/activate  # En macOS/Linux
   # o
   venv\Scripts\activate     # En Windows
   ```

3. **Instalar dependencias**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configurar base de datos**
   - Asegúrate de que MySQL esté ejecutándose
   - Configura las credenciales en `config.py`

5. **Iniciar el servidor backend**
   ```bash
   python app.py
   ```
   
   El backend se ejecutará en `http://localhost:5000`

## Frontend (React.js)

1. **Navegar al directorio del frontend**
   ```bash
   cd "/Users/reneloreaayala/Documents/Maestria/Segundo Semestre/Ingenieria de Software/Proyecto/incidencias-frontend"
   ```

2. **Instalar dependencias** (solo la primera vez)
   ```bash
   npm install
   ```

3. **Verificar configuración**
   - El archivo `.env` debe tener `REACT_APP_API_URL=http://localhost:5000/api`
   - Si el backend usa un puerto diferente, actualizar la URL

4. **Iniciar el servidor frontend**
   ```bash
   npm start
   ```
   
   El frontend se abrirá automáticamente en `http://localhost:3000`

## Orden de Inicio Recomendado

1. **Primero**: Iniciar el backend (Flask)
2. **Segundo**: Iniciar el frontend (React)
3. **Tercero**: Acceder a `http://localhost:3000` en el navegador

## Credenciales de Acceso

Las credenciales dependerán de los usuarios que tengas configurados en la base de datos. Un ejemplo típico sería:

- **Email**: admin@sistema.com
- **Contraseña**: 123456

## Verificación del Sistema

1. **Backend funcionando**:
   - Visita `http://localhost:5000/apidocs` para ver la documentación Swagger
   - Deberías ver la interfaz de documentación de la API

2. **Frontend funcionando**:
   - Visita `http://localhost:3000`
   - Deberías ver la página de login
   - Puedes iniciar sesión con las credenciales configuradas

3. **Conexión API funcionando**:
   - Al hacer login exitoso, deberías llegar al dashboard
   - Las secciones de usuarios, alumnos, grupos y reportes deben cargar datos

## Solución de Problemas Comunes

### Backend no inicia
- Verificar que todas las dependencias estén instaladas
- Revisar la configuración de la base de datos
- Verificar que el puerto 5000 no esté ocupado

### Frontend no conecta con Backend
- Verificar que el backend esté ejecutándose
- Revisar la URL en el archivo `.env`
- Verificar en las herramientas de desarrollo del navegador si hay errores de CORS

### Errores de autenticación
- Verificar que los usuarios estén creados en la base de datos
- Revisar la configuración JWT en el backend
- Limpiar localStorage del navegador si hay tokens corruptos

## Funcionalidades Disponibles

Una vez que ambos servicios estén ejecutándose, podrás:

1. **Iniciar sesión** con credenciales válidas
2. **Gestionar usuarios** (crear, editar, eliminar)
3. **Administrar alumnos** (registro, edición, organización)
4. **Crear grupos** y asignar estudiantes
5. **Configurar tipos de reporte** para incidencias
6. **Crear y gestionar reportes** de incidencias
7. **Visualizar dashboard** con resumen de actividades

## Desarrollo

Para desarrollo, puedes:

- Modificar el frontend en `src/` y los cambios se reflejarán automáticamente
- Modificar el backend y reiniciar el servidor Flask para ver los cambios
- Usar las herramientas de desarrollo del navegador para debugging

## Puertos Utilizados

- **Backend**: 5000 (Flask)
- **Frontend**: 3000 (React Development Server)
- **Base de datos**: 3306 (MySQL - puerto por defecto)

¡El sistema está listo para usar!