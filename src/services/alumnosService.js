import api from './api';

export const alumnosService = {
  // Obtener todos los alumnos
  getAlumnos: async () => {
    try {
      const response = await api.get('/alumnos');
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener alumnos' };
    }
  },

  // Obtener alumno por ID
  getAlumnoById: async (id) => {
    try {
      const response = await api.get(`/alumnos/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al obtener alumno' };
    }
  },

  // Crear alumno
  createAlumno: async (alumnoData) => {
    try {
      const response = await api.post('/alumnos', alumnoData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al crear alumno' };
    }
  },

  // Actualizar alumno
  updateAlumno: async (id, alumnoData) => {
    try {
      const response = await api.put(`/alumnos/${id}`, alumnoData);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al actualizar alumno' };
    }
  },

  // Eliminar alumno
  deleteAlumno: async (id) => {
    try {
      const response = await api.delete(`/alumnos/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al eliminar alumno' };
    }
  },

  // Importar alumnos desde Excel
  importarAlumnos: async (file) => {
    try {
      const formData = new FormData();
      formData.append('file', file);
      
      const response = await api.post('/importar-alumnos', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      return response.data;
    } catch (error) {
      throw error.response?.data || { message: 'Error al importar alumnos' };
    }
  },
};