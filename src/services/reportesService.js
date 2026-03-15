import api from './api';

export const reportesService = {
  // Obtener todos los reportes
  getReportes: async () => {
    try {
      const response = await api.get('/reportes');
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener reportes' };
    }
  },

  // Obtener reportes filtrados (búsqueda avanzada)
  getReportesFiltrados: async (filtros = {}) => {
    try {
      // Construir query string a partir de los filtros
      const params = new URLSearchParams();
      Object.entries(filtros).forEach(([key, value]) => {
        if (value !== undefined && value !== null && value !== '') {
          params.append(key, value);
        }
      });
      const response = await api.get(`/reportes/reporte?${params.toString()}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener reportes filtrados' };
    }
  },

  // Obtener reporte por ID
  getReporteById: async (id) => {
    try {
      const response = await api.get(`/reportes/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener reporte' };
    }
  },

  // Crear reporte
  createReporte: async (reporteData) => {
    try {
      const response = await api.post('/reportes', reporteData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al crear reporte' };
    }
  },

  // Actualizar reporte
  updateReporte: async (id, reporteData) => {
    try {
      const response = await api.put(`/reportes/${id}`, reporteData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al actualizar reporte' };
    }
  },

  // Eliminar reporte
  deleteReporte: async (id) => {
    try {
      const response = await api.delete(`/reportes/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al eliminar reporte' };
    }
  },
};

export const tiposReporteService = {
  // Obtener todos los tipos de reporte
  getTiposReporte: async () => {
    try {
      const response = await api.get('/tipos-reporte');
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener tipos de reporte' };
    }
  },

  // Obtener tipo de reporte por ID
  getTipoReporteById: async (id) => {
    try {
      const response = await api.get(`/tipos-reporte/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener tipo de reporte' };
    }
  },

  // Crear tipo de reporte
  createTipoReporte: async (tipoData) => {
    try {
      const response = await api.post('/tipos-reporte', tipoData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al crear tipo de reporte' };
    }
  },

  // Actualizar tipo de reporte
  updateTipoReporte: async (id, tipoData) => {
    try {
      const response = await api.put(`/tipos-reporte/${id}`, tipoData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al actualizar tipo de reporte' };
    }
  },

  // Eliminar tipo de reporte
  deleteTipoReporte: async (id) => {
    try {
      const response = await api.delete(`/tipos-reporte/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al eliminar tipo de reporte' };
    }
  },
};