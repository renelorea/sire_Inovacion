# Sistema de Incidencias Escolares - Frontend

Este es el frontend desarrollado en React.js para el Sistema de Gestión de Incidencias Escolares.

## Características

- **Autenticación JWT**: Login y manejo de sesiones seguras
- **Gestión de Usuarios**: CRUD completo para usuarios del sistema
- **Gestión de Alumnos**: Administración de información de estudiantes
- **Gestión de Grupos**: Organización de grupos y clases
- **Reportes de Incidencias**: Creación y seguimiento de reportes
- **Tipos de Reporte**: Configuración de categorías de incidencias
- **Dashboard**: Panel principal con resumen de actividades
- **Interfaz Responsiva**: Compatible con dispositivos móviles y escritorio

## Tecnologías Utilizadas

- **React.js**: Framework principal
- **Material-UI (MUI)**: Biblioteca de componentes UI
- **React Router**: Navegación entre páginas
- **Axios**: Cliente HTTP para comunicación con la API
- **Context API**: Gestión de estado global

## Estructura del Proyecto

```
src/
├── components/          # Componentes reutilizables
│   ├── Layout.js       # Layout principal de la aplicación
│   ├── Navbar.js       # Barra de navegación superior
│   ├── Sidebar.js      # Menú lateral
│   └── PrivateRoute.js # Componente para rutas protegidas
├── context/            # Contextos de React
│   └── AuthContext.js  # Contexto de autenticación
├── pages/              # Páginas principales
│   ├── Login.js        # Página de inicio de sesión
│   ├── Dashboard.js    # Panel principal
│   ├── Usuarios.js     # Gestión de usuarios
│   ├── Alumnos.js      # Gestión de alumnos
│   ├── Grupos.js       # Gestión de grupos
│   ├── TiposReporte.js # Gestión de tipos de reporte
│   └── Reportes.js     # Gestión de reportes
├── services/           # Servicios para API
│   ├── api.js          # Configuración base de Axios
│   ├── authService.js  # Servicios de autenticación
│   ├── usuariosService.js     # Servicios de usuarios
│   ├── alumnosService.js      # Servicios de alumnos
│   ├── gruposService.js       # Servicios de grupos
│   ├── reportesService.js     # Servicios de reportes
│   └── seguimientoService.js  # Servicios de seguimiento
└── utils/              # Utilidades y helpers
```

## Instalación y Configuración

### Prerrequisitos

- Node.js (versión 14 o superior)
- npm o yarn
- Backend de la API ejecutándose

### Pasos de Instalación

1. **Instalar dependencias**
   ```bash
   npm install
   ```

2. **Configurar variables de entorno**
   
   El archivo `.env` ya está configurado con:
   ```
   REACT_APP_API_URL=http://localhost:5000/api
   ```
   
   Modifica la URL si tu backend está ejecutándose en un puerto diferente.

3. **Iniciar la aplicación**
   ```bash
   npm start
   ```

   La aplicación se abrirá en `http://localhost:3000`

## Scripts Disponibles

- `npm start`: Inicia el servidor de desarrollo
- `npm build`: Construye la aplicación para producción
- `npm test`: Ejecuta las pruebas
- `npm run eject`: Eyecta la configuración de Create React App

## Funcionalidades Principales

### Autenticación
- Login con email y contraseña
- Manejo de tokens JWT
- Rutas protegidas
- Logout automático al expirar el token

### Gestión de Usuarios
- Listar usuarios activos
- Crear nuevos usuarios
- Editar información de usuarios
- Eliminar usuarios
- Cambiar contraseñas
- Resetear contraseñas

### Gestión de Alumnos
- Registro de nuevos alumnos
- Editar información personal
- Organización por matrícula, grado y grupo
- Vista detallada de cada alumno

### Gestión de Reportes
- Crear reportes de incidencias
- Clasificar por tipo y gravedad
- Seguimiento de estados
- Asignación a alumnos específicos
- Filtros y búsquedas

### Dashboard
- Resumen de actividades
- Accesos rápidos a funcionalidades
- Estadísticas básicas
- Enlaces a secciones principales

### Code Splitting

This section has moved here: [https://facebook.github.io/create-react-app/docs/code-splitting](https://facebook.github.io/create-react-app/docs/code-splitting)

### Analyzing the Bundle Size

This section has moved here: [https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size](https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size)

### Making a Progressive Web App

This section has moved here: [https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app](https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app)

### Advanced Configuration

This section has moved here: [https://facebook.github.io/create-react-app/docs/advanced-configuration](https://facebook.github.io/create-react-app/docs/advanced-configuration)

### Deployment

This section has moved here: [https://facebook.github.io/create-react-app/docs/deployment](https://facebook.github.io/create-react-app/docs/deployment)

### `npm run build` fails to minify

This section has moved here: [https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify](https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify)
