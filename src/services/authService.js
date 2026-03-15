import api from './api';

export const authService = {
  // Login
  login: async (correo, contraseña) => {
    try {
      const response = await api.post('/login', {
        correo,
        contraseña,
      });
      
      // El backend devuelve access_token, no token
      const token = response.data.access_token || response.data.token;
      if (token) {
        localStorage.setItem('token', token);
        localStorage.setItem('user', JSON.stringify(response.data.usuario));
      }
      
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error en el login' };
    }
  },

  // Logout
  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },

  // Obtener usuario actual
  getCurrentUser: () => {
    const userStr = localStorage.getItem('user');
    if (userStr) {
      try {
        return JSON.parse(userStr);
      } catch (error) {
        localStorage.removeItem('user');
        return null;
      }
    }
    return null;
  },

  // Verificar si el usuario está autenticado
  isAuthenticated: () => {
    return localStorage.getItem('token') !== null;
  },

  // Registrar usuario
  register: async (userData) => {
    try {
      const response = await api.post('/usuarios', userData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error en el registro' };
    }
  },
};