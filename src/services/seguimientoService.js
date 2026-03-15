import api from './api';

export const seguimientoService = {
  // Obtener seguimientos por reporte
  getSeguimientosByReporte: async (reporteId) => {
    try {
      const response = await api.get(`/seguimientos/reporte/${reporteId}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener seguimientos' };
    }
  },

  // Obtener seguimiento por ID
  getSeguimientoById: async (id) => {
    try {
      const response = await api.get(`/seguimientos/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener seguimiento' };
    }
  },

  // Crear seguimiento
  createSeguimiento: async (seguimientoData) => {
    try {
      const response = await api.post('/seguimientos', seguimientoData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al crear seguimiento' };
    }
  },

  // Actualizar seguimiento
  updateSeguimiento: async (id, seguimientoData) => {
    try {
      const response = await api.put(`/seguimientos/${id}`, seguimientoData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al actualizar seguimiento' };
    }
  },

  // Eliminar seguimiento
  deleteSeguimiento: async (id) => {
    try {
      const response = await api.delete(`/seguimientos/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al eliminar seguimiento' };
    }
  },
};