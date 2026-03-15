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
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  CircularProgress,
  Input,
  Stack,
} from '@mui/material';
import { Add, Edit, Delete, CloudUpload } from '@mui/icons-material';
import { alumnosService } from '../services/alumnosService';

const Alumnos = () => {
  const [alumnos, setAlumnos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingAlumno, setEditingAlumno] = useState(null);
  const [formData, setFormData] = useState({
    nombres: '',
    apellido_paterno: '',
    apellido_materno: '',
    matricula: '',
    id_grupo: '',
    fecha_nacimiento: '',
    telefono: '',
    email: '',
    sexo: '',
  });
  const [openUploadDialog, setOpenUploadDialog] = useState(false);
  const [selectedFile, setSelectedFile] = useState(null);
  const [uploadLoading, setUploadLoading] = useState(false);
  const [filters, setFilters] = useState({
    matricula: '',
    nombres: '',
    apellidos: '',
    grupo: '',
  });
  const [filteredAlumnos, setFilteredAlumnos] = useState([]);

  useEffect(() => {
    loadAlumnos();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [alumnos, filters]);

  const applyFilters = () => {
    let filtered = alumnos;

    Object.keys(filters).forEach(key => {
      if (filters[key]) {
        filtered = filtered.filter(alumno => {
          switch(key) {
            case 'matricula':
              return alumno.matricula?.toLowerCase().includes(filters[key].toLowerCase());
            case 'nombres':
              return alumno.nombres?.toLowerCase().includes(filters[key].toLowerCase());
            case 'apellidos':
              const fullName = `${alumno.apellido_paterno} ${alumno.apellido_materno}`.toLowerCase();
              return fullName.includes(filters[key].toLowerCase());
            case 'grupo':
              return alumno.grupo?.descripcion?.toLowerCase().includes(filters[key].toLowerCase());
            default:
              return true;
          }
        });
      }
    });

    setFilteredAlumnos(filtered);
  };

  const handleFilterChange = (field, value) => {
    setFilters(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const clearFilters = () => {
    setFilters({
      matricula: '',
      nombres: '',
      apellidos: '',
      grupo: '',
    });
  };

  const loadAlumnos = async () => {
    try {
      setLoading(true);
      const data = await alumnosService.getAlumnos();
      setAlumnos(data.alumnos || data);
      setError(null);
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDialog = (alumno = null) => {
    if (alumno) {
      setEditingAlumno(alumno);
      setFormData({
        nombres: alumno.nombres || '',
        apellido_paterno: alumno.apellido_paterno || '',
        apellido_materno: alumno.apellido_materno || '',
        matricula: alumno.matricula || '',
        id_grupo: alumno.grupo?.id_grupo || '',
        fecha_nacimiento: alumno.fecha_nacimiento || '',
        telefono: alumno.telefono || '',
        email: alumno.email || '',
        sexo: alumno.sexo || '',
      });
    } else {
      setEditingAlumno(null);
      setFormData({
        nombres: '',
        apellido_paterno: '',
        apellido_materno: '',
        matricula: '',
        id_grupo: '',
        fecha_nacimiento: '',
        telefono: '',
        email: '',
        sexo: '',
      });
    }
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setEditingAlumno(null);
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
      if (editingAlumno) {
        await alumnosService.updateAlumno(editingAlumno.id_alumno, formData);
      } else {
        await alumnosService.createAlumno(formData);
      }
      
      handleCloseDialog();
      loadAlumnos();
    } catch (error) {
      setError(error.message);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('¿Está seguro de que desea eliminar este alumno?')) {
      try {
        await alumnosService.deleteAlumno(id);
        loadAlumnos();
      } catch (error) {
        setError(error.message);
      }
    }
  };

  const handleOpenUploadDialog = () => {
    setOpenUploadDialog(true);
    setSelectedFile(null);
    setError(null);
  };

  const handleCloseUploadDialog = () => {
    setOpenUploadDialog(false);
    setSelectedFile(null);
  };

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (file) {
      const validTypes = [
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      ];
      
      if (validTypes.includes(file.type)) {
        setSelectedFile(file);
        setError(null);
      } else {
        setError('Por favor seleccione un archivo Excel válido (.xls o .xlsx)');
        setSelectedFile(null);
      }
    }
  };

  const handleUploadFile = async () => {
    if (!selectedFile) {
      setError('Por favor seleccione un archivo');
      return;
    }

    try {
      setUploadLoading(true);
      setError(null);
      
      const result = await alumnosService.importarAlumnos(selectedFile);
      
      alert(`Carga completada. Se insertaron ${result.inserted} de ${result.total} registros.`);
      handleCloseUploadDialog();
      loadAlumnos();
    } catch (error) {
      setError(error.message || 'Error al procesar el archivo');
    } finally {
      setUploadLoading(false);
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
          Gestión de Alumnos
        </Typography>
        <Stack direction="row" spacing={2}>
          <Button
            variant="outlined"
            startIcon={<CloudUpload />}
            onClick={handleOpenUploadDialog}
          >
            Carga Masiva (Excel)
          </Button>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={() => handleOpenDialog()}
          >
            Nuevo Alumno
          </Button>
        </Stack>
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
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>Matrícula</Typography>
                  <TextField
                    size="small"
                    placeholder="Filtrar..."
                    value={filters.matricula}
                    onChange={(e) => handleFilterChange('matricula', e.target.value)}
                    variant="outlined"
                    sx={{ minWidth: 120 }}
                  />
                </Box>
              </TableCell>
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>Nombres</Typography>
                  <TextField
                    size="small"
                    placeholder="Filtrar..."
                    value={filters.nombres}
                    onChange={(e) => handleFilterChange('nombres', e.target.value)}
                    variant="outlined"
                    sx={{ minWidth: 120 }}
                  />
                </Box>
              </TableCell>
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>Apellidos</Typography>
                  <TextField
                    size="small"
                    placeholder="Filtrar..."
                    value={filters.apellidos}
                    onChange={(e) => handleFilterChange('apellidos', e.target.value)}
                    variant="outlined"
                    sx={{ minWidth: 120 }}
                  />
                </Box>
              </TableCell>
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>Grupo</Typography>
                  <TextField
                    size="small"
                    placeholder="Filtrar..."
                    value={filters.grupo}
                    onChange={(e) => handleFilterChange('grupo', e.target.value)}
                    variant="outlined"
                    sx={{ minWidth: 150 }}
                  />
                </Box>
              </TableCell>
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>Acciones</Typography>
                  <Button size="small" onClick={clearFilters} variant="outlined">
                    Limpiar
                  </Button>
                </Box>
              </TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredAlumnos.map((alumno) => (
              <TableRow key={alumno.id_alumno}>
                <TableCell>{alumno.matricula}</TableCell>
                <TableCell>{alumno.nombres}</TableCell>
                <TableCell>
                  {alumno.apellido_paterno} {alumno.apellido_materno}
                </TableCell>
                <TableCell>{alumno.grupo?.descripcion || 'N/A'}</TableCell>
                <TableCell>
                  <IconButton
                    color="primary"
                    onClick={() => handleOpenDialog(alumno)}
                  >
                    <Edit />
                  </IconButton>
                  <IconButton
                    color="error"
                    onClick={() => handleDelete(alumno.id_alumno)}
                  >
                    <Delete />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Dialog para crear/editar alumno */}
      <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="md" fullWidth>
        <DialogTitle>
          {editingAlumno ? 'Editar Alumno' : 'Nuevo Alumno'}
        </DialogTitle>
        <DialogContent>
          <Box component="form" onSubmit={handleSubmit}>
            <TextField
              margin="normal"
              required
              fullWidth
              name="matricula"
              label="Matrícula"
              value={formData.matricula}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="nombres"
              label="Nombres"
              value={formData.nombres}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="apellido_paterno"
              label="Apellido Paterno"
              value={formData.apellido_paterno}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              fullWidth
              name="apellido_materno"
              label="Apellido Materno"
              value={formData.apellido_materno}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="grado"
              label="Grado"
              value={formData.grado}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="grupo"
              label="Grupo"
              value={formData.grupo}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              fullWidth
              name="fecha_nacimiento"
              label="Fecha de Nacimiento"
              type="date"
              InputLabelProps={{ shrink: true }}
              value={formData.fecha_nacimiento}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              fullWidth
              name="telefono"
              label="Teléfono"
              value={formData.telefono}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              fullWidth
              name="email"
              label="Email"
              type="email"
              value={formData.email}
              onChange={handleChange}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>
            Cancelar
          </Button>
          <Button onClick={handleSubmit} variant="contained">
            {editingAlumno ? 'Actualizar' : 'Crear'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Dialog para carga masiva de alumnos */}
      <Dialog open={openUploadDialog} onClose={handleCloseUploadDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          Carga Masiva de Alumnos
        </DialogTitle>
        <DialogContent>
          <Box sx={{ mt: 2 }}>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              Seleccione un archivo Excel (.xls o .xlsx) con la información de los alumnos.
            </Typography>
            
            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              <strong>Formato esperado:</strong> Las columnas del archivo deben incluir: 
              Nombre, Apaterno, Amaterno, Matricula, Grupo (ID), Fecha_nacimiento, Sexo (M/F/O)
            </Typography>

            <Input
              type="file"
              accept=".xls,.xlsx"
              onChange={handleFileChange}
              sx={{ width: '100%', mb: 2 }}
            />
            
            {selectedFile && (
              <Typography variant="body2" color="primary" sx={{ mb: 2 }}>
                Archivo seleccionado: {selectedFile.name}
              </Typography>
            )}
            
            {error && (
              <Alert severity="error" sx={{ mb: 2 }}>
                {error}
              </Alert>
            )}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseUploadDialog} disabled={uploadLoading}>
            Cancelar
          </Button>
          <Button 
            onClick={handleUploadFile} 
            variant="contained" 
            disabled={!selectedFile || uploadLoading}
            startIcon={uploadLoading ? <CircularProgress size={20} /> : <CloudUpload />}
          >
            {uploadLoading ? 'Procesando...' : 'Cargar Archivo'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Alumnos;