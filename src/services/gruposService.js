import api from './api';

export const gruposService = {
  // Obtener todos los grupos
  getGrupos: async () => {
    try {
      const response = await api.get('/grupos');
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener grupos' };
    }
  },

  // Obtener grupo por ID
  getGrupoById: async (id) => {
    try {
      const response = await api.get(`/grupos/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener grupo' };
    }
  },

  // Crear grupo
  createGrupo: async (grupoData) => {
    try {
      const response = await api.post('/grupos', grupoData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al crear grupo' };
    }
  },

  // Actualizar grupo
  updateGrupo: async (id, grupoData) => {
    try {
      const response = await api.put(`/grupos/${id}`, grupoData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al actualizar grupo' };
    }
  },

  // Eliminar grupo
  deleteGrupo: async (id) => {
    try {
      const response = await api.delete(`/grupos/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al eliminar grupo' };
    }
  },

  // Obtener alumnos de un grupo específico
  getAlumnosByGrupo: async (grupoId) => {
    try {
      const response = await api.get(`/grupos/${grupoId}/alumnos`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener alumnos del grupo' };
    }
  },
};