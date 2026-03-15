// Formatear fechas
export const formatDate = (date, locale = 'es-ES') => {
  if (!date) return '';
  return new Date(date).toLocaleDateString(locale);
};

export const formatDateTime = (date, locale = 'es-ES') => {
  if (!date) return '';
  return new Date(date).toLocaleString(locale);
};

// Validaciones
export const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

export const isValidPassword = (password, minLength = 6) => {
  return password && password.length >= minLength;
};

// Manejo de errores
export const getErrorMessage = (error) => {
  if (typeof error === 'string') return error;
  if (error?.message) return error.message;
  if (error?.response?.data?.message) return error.response.data.message;
  if (error?.response?.data?.error) return error.response.data.error;
  return 'Ha ocurrido un error inesperado';
};

// Capitalizar texto
export const capitalize = (str) => {
  if (!str) return '';
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
};

// Truncar texto
export const truncateText = (text, maxLength = 100) => {
  if (!text || text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
};

// Generar colores consistentes para elementos
export const stringToColor = (string) => {
  let hash = 0;
  let i;

  for (i = 0; i < string.length; i += 1) {
    hash = string.charCodeAt(i) + ((hash << 5) - hash);
  }

  let color = '#';

  for (i = 0; i < 3; i += 1) {
    const value = (hash >> (i * 8)) & 0xff;
    color += `00${value.toString(16)}`.substr(-2);
  }

  return color;
};

// Formatear números
export const formatNumber = (number, locale = 'es-ES') => {
  if (number === null || number === undefined) return '';
  return new Intl.NumberFormat(locale).format(number);
};

// Debounce para búsquedas
export const debounce = (func, wait) => {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
};

// Constantes para la aplicación
export const CONSTANTS = {
  ROLES: {
    ADMIN: 'admin',
    USUARIO: 'usuario',
    PROFESOR: 'profesor',
  },
  ESTADOS_REPORTE: {
    PENDIENTE: 'pendiente',
    EN_PROCESO: 'en_proceso',
    RESUELTO: 'resuelto',
    CERRADO: 'cerrado',
  },
  GRAVEDADES: {
    BAJA: 'baja',
    MEDIA: 'media',
    ALTA: 'alta',
    CRITICA: 'critica',
  },
};