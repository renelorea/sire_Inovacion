import api from './api';

export const usuariosService = {
  // Obtener todos los usuarios
  getUsuarios: async () => {
    try {
      const response = await api.get('/usuarios');
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener usuarios' };
    }
  },

  // Obtener usuario por ID
  getUsuarioById: async (id) => {
    try {
      const response = await api.get(`/usuarios/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener usuario' };
    }
  },

  // Crear usuario
  createUsuario: async (userData) => {
    try {
      const response = await api.post('/usuarios', userData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al crear usuario' };
    }
  },

  // Actualizar usuario
  updateUsuario: async (id, userData) => {
    try {
      const response = await api.put(`/usuarios/${id}`, userData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al actualizar usuario' };
    }
  },

  // Eliminar usuario
  deleteUsuario: async (id) => {
    try {
      const response = await api.delete(`/usuarios/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al eliminar usuario' };
    }
  },

  // Cambiar contraseña
  changePassword: async (correo, passwordData) => {
    try {
      const requestData = {
        correo: correo,
        password_actual: passwordData.contrasena_actual,
        password_nueva: passwordData.nueva_contrasena
      };
      console.log('Datos enviados para cambio de contraseña:', requestData);
      
      const response = await api.put(`/usuarios/cambiar-password`, requestData);
      return response.data;
    } catch (error) {
      console.error('Error al cambiar contraseña:', error.response?.data);
      throw error.response?.data || { message: 'Error al cambiar contraseña' };
    }
  },

  // Resetear contraseña
  resetPassword: async (id) => {
    try {
      const response = await api.post(`/usuarios/${id}/reset-password`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al resetear contraseña' };
    }
  },
};