import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Button,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Alert,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  MenuItem,
  CircularProgress
} from '@mui/material';
import { Add, Edit, Delete, Visibility } from '@mui/icons-material';
import { reportesService, tiposReporteService } from '../services/reportesService';
import { alumnosService } from '../services/alumnosService';
import ReporteDetailModal from '../components/ReporteDetailModal';

const Reportes = () => {

  const handleOpenDialog = (reporte = null) => {
    if (reporte) {
      setEditingReporte(reporte);
      setFormData({
        alumno_id: reporte.alumno_id || '',
        tipo_reporte_id: reporte.tipo_reporte_id || '',
        descripcion: reporte.descripcion || reporte.descripcion_hechos || '',
        fecha_incidente: reporte.fecha_incidente || reporte.fecha_incidencia || '',
        gravedad: reporte.gravedad || reporte.tipo_gravedad || 'media',
        estado: reporte.estado || reporte.estatus || 'pendiente',
      });
    } else {
      setEditingReporte(null);
      setFormData({
        alumno_id: '',
        tipo_reporte_id: '',
        descripcion: '',
        fecha_incidente: '',
        gravedad: 'media',
        estado: 'pendiente',
      });
    }
    setOpenDialog(true);
  };

  // Estados principales
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [reportes, setReportes] = useState([]);
  const [alumnos, setAlumnos] = useState([]);
  const [tiposReporte, setTiposReporte] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingReporte, setEditingReporte] = useState(null);
  const [formData, setFormData] = useState({
    alumno_id: '',
    tipo_reporte_id: '',
    descripcion: '',
    fecha_incidente: '',
    gravedad: 'media',
    estado: 'pendiente',
  });
  const [openDetailsDialog, setOpenDetailsDialog] = useState(false);
  const [selectedReporte, setSelectedReporte] = useState(null);
  const severidades = [
    { value: 'baja', label: 'Baja' },
    { value: 'media', label: 'Media' },
    { value: 'alta', label: 'Alta' },
    { value: 'critica', label: 'Crítica' },
  ];
  const estados = [
    { value: 'pendiente', label: 'Pendiente' },
    { value: 'en_proceso', label: 'En Proceso' },
    { value: 'resuelto', label: 'Resuelto' },
    { value: 'cerrado', label: 'Cerrado' },
  ];

  // Cargar datos iniciales
  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [reportesRes, alumnosRes, tiposReporteRes] = await Promise.all([
        reportesService.getReportesFiltrados ? reportesService.getReportesFiltrados({}) : reportesService.getReportes(),
        alumnosService.getAlumnos ? alumnosService.getAlumnos() : [],
        tiposReporteService.getTiposReporte ? tiposReporteService.getTiposReporte() : [],
      ]);
      setReportes(reportesRes || []);
      setAlumnos(alumnosRes || []);
      setTiposReporte(tiposReporteRes || []);
    } catch (err) {
      setError('Error al cargar los datos');
    } finally {
      setLoading(false);
    }
  };


  const handleCloseDialog = () => {
    setOpenDialog(false);
    setEditingReporte(null);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingReporte) {
        await reportesService.updateReporte(editingReporte.id, formData);
      } else {
        await reportesService.createReporte(formData);
      }
      
      handleCloseDialog();
      loadData();
    } catch (error) {
      setError(error.message);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('¿Está seguro de que desea eliminar este reporte?')) {
      try {
        await reportesService.deleteReporte(id);
        loadData();
      } catch (error) {
        setError(error.message);
      }
    }
  };

  const handleShowDetails = (reporte) => {
    setSelectedReporte(reporte);
    setOpenDetailsDialog(true);
  };

  const handleCloseDetailsDialog = () => {
    setOpenDetailsDialog(false);
    setSelectedReporte(null);
  };

  const getGravedadColor = (gravedad) => {
    switch (gravedad) {
      case 'baja': return 'success';
      case 'media': return 'warning';
      case 'alta': return 'error';
      case 'critica': return 'error';
      default: return 'default';
    }
  };

  const getEstadoColor = (estado) => {
    switch (estado) {
      case 'pendiente': return 'warning';
      case 'en_proceso': return 'info';
      case 'resuelto': return 'success';
      case 'cerrado': return 'default';
      default: return 'default';
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="300px">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4">
          Gestión de Reportes
        </Typography>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => handleOpenDialog()}
        >
          Nuevo Reporte
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>Alumno</TableCell>
              <TableCell>Tipo</TableCell>
              <TableCell>Descripción</TableCell>
              <TableCell>Fecha</TableCell>
              <TableCell>Gravedad</TableCell>
              <TableCell>Estado</TableCell>
              <TableCell>Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {reportes.length === 0 ? (
              <TableRow>
                <TableCell colSpan={8} align="center" sx={{ py: 3 }}>
                  <Typography color="text.secondary">
                    No hay reportes registrados
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              reportes.map((reporte) => (
                <TableRow key={reporte.id_reporte}>
                  <TableCell>{reporte.id_reporte}</TableCell>
                  <TableCell>
                    {reporte.alumno ? 
                      `${reporte.alumno.nombre} ${reporte.alumno.apellido_paterno} ${reporte.alumno.apellido_materno}` 
                      : 'N/A'}
                  </TableCell>
                  <TableCell>
                    {reporte.tipo_nombre || 'N/A'}
                  </TableCell>
                  <TableCell>
                    {reporte.descripcion_hechos?.substring(0, 50)}...
                  </TableCell>
                  <TableCell>{reporte.fecha_incidencia}</TableCell>
                  <TableCell>
                    <Chip 
                      label={reporte.gravedad || reporte.tipo_gravedad || 'media'} 
                      color={getGravedadColor(reporte.gravedad || reporte.tipo_gravedad)}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <Chip 
                      label={reporte.estatus || 'pendiente'} 
                      color={getEstadoColor(reporte.estatus)}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <IconButton 
                      color="info"
                      onClick={() => handleShowDetails(reporte)}
                      title="Ver Detalles"
                    >
                      <Visibility />
                    </IconButton>
                    <IconButton
                      color="primary"
                      onClick={() => handleOpenDialog(reporte)}
                      title="Editar"
                    >
                      <Edit />
                    </IconButton>
                    <IconButton
                      color="error"
                      onClick={() => handleDelete(reporte.id_reporte)}
                      title="Eliminar"
                    >
                      <Delete />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Dialog para crear/editar reporte */}
      <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>
          {editingReporte ? 'Editar Reporte' : 'Nuevo Reporte'}
        </DialogTitle>
        <DialogContent>
          <Box component="form" onSubmit={handleSubmit}>
            <TextField
              margin="normal"
              required
              fullWidth
              name="alumno_id"
              label="Alumno"
              select
              value={formData.alumno_id}
              onChange={handleChange}
            >
              {alumnos.map((alumno) => (
                <MenuItem key={alumno.id} value={alumno.id}>
                  {alumno.nombres} {alumno.apellido_paterno} ({alumno.matricula})
                </MenuItem>
              ))}
            </TextField>
            
            <TextField
              margin="normal"
              required
              fullWidth
              name="tipo_reporte_id"
              label="Tipo de Reporte"
              select
              value={formData.tipo_reporte_id}
              onChange={handleChange}
            >
              {tiposReporte.map((tipo) => (
                <MenuItem key={tipo.id} value={tipo.id}>
                  {tipo.nombre}
                </MenuItem>
              ))}
            </TextField>
            
            <TextField
              margin="normal"
              required
              fullWidth
              name="descripcion"
              label="Descripción"
              multiline
              rows={4}
              value={formData.descripcion}
              onChange={handleChange}
            />
            
            <TextField
              margin="normal"
              required
              fullWidth
              name="fecha_incidente"
              label="Fecha del Incidente"
              type="datetime-local"
              InputLabelProps={{ shrink: true }}
              value={formData.fecha_incidente}
              onChange={handleChange}
            />
            
            <TextField
              margin="normal"
              required
              fullWidth
              name="gravedad"
              label="Gravedad"
              select
              value={formData.gravedad}
              onChange={handleChange}
            >
              {severidades.map((option) => (
                <MenuItem key={option.value} value={option.value}>
                  {option.label}
                </MenuItem>
              ))}
            </TextField>
            
            <TextField
              margin="normal"
              required
              fullWidth
              name="estado"
              label="Estado"
              select
              value={formData.estado}
              onChange={handleChange}
            >
              {estados.map((option) => (
                <MenuItem key={option.value} value={option.value}>
                  {option.label}
                </MenuItem>
              ))}
            </TextField>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>
            Cancelar
          </Button>
          <Button onClick={handleSubmit} variant="contained">
            {editingReporte ? 'Actualizar' : 'Crear'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Dialog para ver detalles del reporte - Estilo Flutter */}
      <ReporteDetailModal 
        open={openDetailsDialog} 
        onClose={handleCloseDetailsDialog} 
        reporte={selectedReporte} 
      />
    </Box>
  );
};

export default Reportes;