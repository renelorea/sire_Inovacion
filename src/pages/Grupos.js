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
  Grid,
  Card,
  CardContent,
  List,
  ListItem,
  ListItemText,
  Divider,
} from '@mui/material';
import { Add, Edit, Delete, Visibility, People } from '@mui/icons-material';
import { gruposService } from '../services/gruposService';

const Grupos = () => {
  const [grupos, setGrupos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingGrupo, setEditingGrupo] = useState(null);
  const [formData, setFormData] = useState({
    grado: '',
    ciclo_escolar: '',
    id_tutor: '',
    Descripcion: '',
  });
  const [filters, setFilters] = useState({
    id: '',
    grado: '',
    ciclo: '',
    tutor: '',
    descripcion: '',
  });
  const [filteredGrupos, setFilteredGrupos] = useState([]);
  const [openDetailsDialog, setOpenDetailsDialog] = useState(false);
  const [selectedGrupo, setSelectedGrupo] = useState(null);
  const [grupoAlumnos, setGrupoAlumnos] = useState([]);
  const [loadingDetails, setLoadingDetails] = useState(false);

  useEffect(() => {
    loadGrupos();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [grupos, filters]);

  const applyFilters = () => {
    let filtered = grupos;

    Object.keys(filters).forEach(key => {
      if (filters[key]) {
        filtered = filtered.filter(grupo => {
          switch(key) {
            case 'id':
              return grupo.id_grupo?.toString().includes(filters[key]);
            case 'grado':
              return grupo.grado?.toLowerCase().includes(filters[key].toLowerCase());
            case 'ciclo':
              return grupo.ciclo_escolar?.toLowerCase().includes(filters[key].toLowerCase());
            case 'tutor':
              return grupo.id_tutor?.toString().includes(filters[key]);
            case 'descripcion':
              return grupo.Descripcion?.toLowerCase().includes(filters[key].toLowerCase());
            default:
              return true;
          }
        });
      }
    });

    setFilteredGrupos(filtered);
  };

  const handleFilterChange = (field, value) => {
    setFilters(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const clearFilters = () => {
    setFilters({
      id: '',
      grado: '',
      ciclo: '',
      tutor: '',
      descripcion: '',
    });
  };

  const handleShowDetails = async (grupo) => {
    setSelectedGrupo(grupo);
    setOpenDetailsDialog(true);
    setLoadingDetails(true);
    setGrupoAlumnos([]);

    try {
      const response = await gruposService.getAlumnosByGrupo(grupo.id_grupo);
      // La respuesta del backend es directamente el array de alumnos
      setGrupoAlumnos(Array.isArray(response) ? response : []);
    } catch (error) {
      console.error('Error al cargar alumnos del grupo:', error);
      setError(error.message);
    } finally {
      setLoadingDetails(false);
    }
  };

  const handleCloseDetailsDialog = () => {
    setOpenDetailsDialog(false);
    setSelectedGrupo(null);
    setGrupoAlumnos([]);
  };

  const getEstadisticasAlumnos = () => {
    if (!grupoAlumnos || grupoAlumnos.length === 0) {
      return { total: 0, hombres: 0, mujeres: 0, otros: 0 };
    }

    const stats = grupoAlumnos.reduce((acc, alumno) => {
      acc.total++;
      if (alumno.sexo === 'M') {
        acc.hombres++;
      } else if (alumno.sexo === 'F') {
        acc.mujeres++;
      } else {
        acc.otros++;
      }
      return acc;
    }, { total: 0, hombres: 0, mujeres: 0, otros: 0 });

    return stats;
  };

  const loadGrupos = async () => {
    try {
      setLoading(true);
      const data = await gruposService.getGrupos();
      setGrupos(data.grupos || data);
      setError(null);
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDialog = (grupo = null) => {
    if (grupo) {
      setEditingGrupo(grupo);
      setFormData({
        grado: grupo.grado || '',
        ciclo_escolar: grupo.ciclo || '',
        id_tutor: grupo.idtutor || '',
        Descripcion: grupo.descripcion || '',
      });
    } else {
      setEditingGrupo(null);
      setFormData({
        grado: '',
        ciclo_escolar: '',
        id_tutor: '',
        Descripcion: '',
      });
    }
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setEditingGrupo(null);
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
      if (editingGrupo) {
        await gruposService.updateGrupo(editingGrupo.id_grupo, formData);
      } else {
        await gruposService.createGrupo(formData);
      }
      
      handleCloseDialog();
      loadGrupos();
    } catch (error) {
      setError(error.message);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('¿Está seguro de que desea eliminar este grupo?')) {
      try {
        await gruposService.deleteGrupo(id);
        loadGrupos();
      } catch (error) {
        setError(error.message);
      }
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
          Gestión de Grupos
        </Typography>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => handleOpenDialog()}
        >
          Nuevo Grupo
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
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>ID</Typography>
                  <TextField
                    size="small"
                    placeholder="Filtrar..."
                    value={filters.id}
                    onChange={(e) => handleFilterChange('id', e.target.value)}
                    variant="outlined"
                    sx={{ minWidth: 80 }}
                  />
                </Box>
              </TableCell>
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>Grado</Typography>
                  <TextField
                    size="small"
                    placeholder="Filtrar..."
                    value={filters.grado}
                    onChange={(e) => handleFilterChange('grado', e.target.value)}
                    variant="outlined"
                    sx={{ minWidth: 120 }}
                  />
                </Box>
              </TableCell>
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>Ciclo Escolar</Typography>
                  <TextField
                    size="small"
                    placeholder="Filtrar..."
                    value={filters.ciclo}
                    onChange={(e) => handleFilterChange('ciclo', e.target.value)}
                    variant="outlined"
                    sx={{ minWidth: 140 }}
                  />
                </Box>
              </TableCell>
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>ID Tutor</Typography>
                  <TextField
                    size="small"
                    placeholder="Filtrar..."
                    value={filters.tutor}
                    onChange={(e) => handleFilterChange('tutor', e.target.value)}
                    variant="outlined"
                    sx={{ minWidth: 100 }}
                  />
                </Box>
              </TableCell>
              <TableCell>
                <Box>
                  <Typography variant="subtitle2" gutterBottom>Descripción</Typography>
                  <TextField
                    size="small"
                    placeholder="Filtrar..."
                    value={filters.descripcion}
                    onChange={(e) => handleFilterChange('descripcion', e.target.value)}
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
            {filteredGrupos.map((grupo) => (
              <TableRow key={grupo.id_grupo}>
                <TableCell>{grupo.id_grupo}</TableCell>
                <TableCell>{grupo.grado}</TableCell>
                <TableCell>{grupo.ciclo_escolar}</TableCell>
                <TableCell>{grupo.id_tutor}</TableCell>
                <TableCell>{grupo.Descripcion}</TableCell>
                <TableCell>
                  <IconButton
                    color="info"
                    onClick={() => handleShowDetails(grupo)}
                    title="Ver Detalles"
                  >
                    <Visibility />
                  </IconButton>
                  <IconButton
                    color="primary"
                    onClick={() => handleOpenDialog(grupo)}
                    title="Editar"
                  >
                    <Edit />
                  </IconButton>
                  <IconButton
                    color="error"
                    onClick={() => handleDelete(grupo.id_grupo)}
                    title="Eliminar"
                  >
                    <Delete />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Dialog para crear/editar grupo */}
      <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {editingGrupo ? 'Editar Grupo' : 'Nuevo Grupo'}
        </DialogTitle>
        <DialogContent>
          <Box component="form" onSubmit={handleSubmit}>
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
              name="ciclo_escolar"
              label="Ciclo Escolar"
              value={formData.ciclo_escolar}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              fullWidth
              name="id_tutor"
              label="ID Tutor"
              type="number"
              value={formData.id_tutor}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              fullWidth
              name="Descripcion"
              label="Descripción"
              multiline
              rows={3}
              value={formData.Descripcion}
              onChange={handleChange}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>
            Cancelar
          </Button>
          <Button onClick={handleSubmit} variant="contained">
            {editingGrupo ? 'Actualizar' : 'Crear'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Dialog para ver detalles del grupo */}
      <Dialog open={openDetailsDialog} onClose={handleCloseDetailsDialog} maxWidth="md" fullWidth>
        <DialogTitle>
          <Box display="flex" alignItems="center" gap={1}>
            <People />
            Detalles del Grupo
          </Box>
        </DialogTitle>
        <DialogContent>
          {selectedGrupo && (
            <Box>
              {/* Información básica del grupo */}
              <Card sx={{ mb: 3 }}>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    📋 Información General
                  </Typography>
                  <Grid container spacing={2}>
                    <Grid size={6}>
                      <Typography variant="body2" color="text.secondary">
                        <strong>ID:</strong> {selectedGrupo.id_grupo}
                      </Typography>
                    </Grid>
                    <Grid size={6}>
                      <Typography variant="body2" color="text.secondary">
                        <strong>Grado:</strong> {selectedGrupo.grado || 'N/A'}
                      </Typography>
                    </Grid>
                    <Grid size={6}>
                      <Typography variant="body2" color="text.secondary">
                        <strong>Ciclo Escolar:</strong> {selectedGrupo.ciclo_escolar || 'N/A'}
                      </Typography>
                    </Grid>
                    <Grid size={6}>
                      <Typography variant="body2" color="text.secondary">
                        <strong>ID Tutor:</strong> {selectedGrupo.id_tutor || 'N/A'}
                      </Typography>
                    </Grid>
                    <Grid size={12}>
                      <Typography variant="body2" color="text.secondary">
                        <strong>Descripción:</strong> {selectedGrupo.Descripcion || 'N/A'}
                      </Typography>
                    </Grid>
                  </Grid>
                </CardContent>
              </Card>

              {/* Estadísticas de alumnos */}
              <Card sx={{ mb: 3 }}>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    📊 Estadísticas de Alumnos
                  </Typography>
                  {loadingDetails ? (
                    <Box display="flex" justifyContent="center" p={2}>
                      <CircularProgress />
                    </Box>
                  ) : (
                    <Grid container spacing={2}>
                      {(() => {
                        const stats = getEstadisticasAlumnos();
                        return (
                          <>
                            <Grid size={3}>
                              <Box textAlign="center" p={1} bgcolor="primary.main" color="white" borderRadius={1}>
                                <Typography variant="h5">{stats.total}</Typography>
                                <Typography variant="body2">Total</Typography>
                              </Box>
                            </Grid>
                            <Grid size={3}>
                              <Box textAlign="center" p={1} bgcolor="info.main" color="white" borderRadius={1}>
                                <Typography variant="h5">{stats.hombres}</Typography>
                                <Typography variant="body2">Hombres</Typography>
                              </Box>
                            </Grid>
                            <Grid size={3}>
                              <Box textAlign="center" p={1} bgcolor="secondary.main" color="white" borderRadius={1}>
                                <Typography variant="h5">{stats.mujeres}</Typography>
                                <Typography variant="body2">Mujeres</Typography>
                              </Box>
                            </Grid>
                            <Grid size={3}>
                              <Box textAlign="center" p={1} bgcolor="grey.600" color="white" borderRadius={1}>
                                <Typography variant="h5">{stats.otros}</Typography>
                                <Typography variant="body2">Otros</Typography>
                              </Box>
                            </Grid>
                          </>
                        );
                      })()}
                    </Grid>
                  )}
                </CardContent>
              </Card>

              {/* Lista de alumnos */}
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    👨‍🎓 Lista de Alumnos
                  </Typography>
                  {loadingDetails ? (
                    <Box display="flex" justifyContent="center" p={2}>
                      <CircularProgress />
                    </Box>
                  ) : grupoAlumnos.length === 0 ? (
                    <Typography variant="body2" color="text.secondary" textAlign="center" p={2}>
                      No hay alumnos registrados en este grupo
                    </Typography>
                  ) : (
                    <List>
                      {grupoAlumnos.map((alumno, index) => (
                        <Box key={alumno.id_alumno || index}>
                          <ListItem>
                            <ListItemText
                              primary={`${alumno.nombres} ${alumno.apellido_paterno} ${alumno.apellido_materno}`}
                              secondary={
                                <>
                                  Matrícula: {alumno.matricula || 'N/A'}
                                  <br />
                                  Género: {alumno.sexo === 'M' ? 'Masculino' : alumno.sexo === 'F' ? 'Femenino' : 'Otro'}
                                </>
                              }
                            />
                          </ListItem>
                          {index < grupoAlumnos.length - 1 && <Divider />}
                        </Box>
                      ))}
                    </List>
                  )}
                </CardContent>
              </Card>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDetailsDialog}>
            Cerrar
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Grupos;