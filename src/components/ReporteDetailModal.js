import React, { useState, useEffect, useCallback } from 'react';
import {
  Dialog,
  DialogContent,
  DialogTitle,
  DialogActions,
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Chip,
  Button,
  TextField,
  MenuItem,
  FormControl,
  InputLabel,
  Select,
  Alert,
  IconButton,
  CircularProgress,
  Paper,
  AppBar,
  Toolbar,
  useTheme,
  useMediaQuery,
  Fab,
  Zoom
} from '@mui/material';
import {
  ArrowBack as ArrowBackIcon,
  CameraAltOutlined as CameraIcon,
  SaveOutlined as SaveIcon,
  CancelOutlined as CancelIcon,
  TimelineOutlined as TimelineIcon,
  RefreshOutlined as RefreshIcon,
  ImageOutlined as ImageIcon,
  KeyboardArrowUp as KeyboardArrowUpIcon,
  Close as CloseIcon,
  Download as DownloadIcon,
  ZoomIn as ZoomInIcon
} from '@mui/icons-material';
import { usuariosService } from '../services/usuariosService';
import { seguimientoService } from '../services/seguimientoService';

const ReporteDetailModal = ({ open, onClose, reporte }) => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const isSmallScreen = useMediaQuery(theme.breakpoints.down('sm'));

  // Estados para el formulario de seguimiento
  const [formData, setFormData] = useState({
    responsable_id: '',
    responsable_nombre: '',
    descripcion: '',
    fecha: new Date().toISOString().split('T')[0],
    estado: 'pendiente',
    imagen: null
  });
  
  const [guardando, setGuardando] = useState(false);
  const [seguimientos, setSeguimientos] = useState([]);
  const [imagenPreview, setImagenPreview] = useState(null);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [showScrollToTop, setShowScrollToTop] = useState(false);
  const [usuarios, setUsuarios] = useState([]);
  const [loadingUsuarios, setLoadingUsuarios] = useState(false);
  const [mostrarSeguimientos, setMostrarSeguimientos] = useState(true);
  const [actualizandoSeguimientos, setActualizandoSeguimientos] = useState(false);
  const [evidenciaModal, setEvidenciaModal] = useState({
    open: false,
    imagen: null,
    titulo: '',
    descripcion: ''
  });
  const [imagenCargando, setImagenCargando] = useState(false);
  const [errorCargaImagen, setErrorCargaImagen] = useState(false);

  const estados = [
    { value: 'pendiente', label: 'Pendiente' },
    { value: 'en_proceso', label: 'En Proceso' },
    { value: 'resuelto', label: 'Resuelto' },
    { value: 'cerrado', label: 'Cerrado' }
  ];


  const cargarSeguimientos = useCallback(async () => {
    if (!reporte?.id && !reporte?.id_reporte) {
      console.warn('No se puede cargar seguimientos: ID de reporte no disponible');
      setSeguimientos([]);
      return;
    }

    try {
      setActualizandoSeguimientos(true);
      const reporteId = reporte?.id || reporte?.id_reporte;
      const data = await seguimientoService.getSeguimientosByReporte(reporteId);
      setSeguimientos(data || []);
      if (actualizandoSeguimientos) {
        setSuccess('Seguimientos actualizados correctamente');
        setTimeout(() => setSuccess(null), 3000);
      }
    } catch (err) {
      console.error('Error cargando seguimientos:', err);
      setError('Error al cargar los seguimientos');
    } finally {
      setActualizandoSeguimientos(false);
    }
  }, [reporte?.id, reporte?.id_reporte, actualizandoSeguimientos]);

  const cargarUsuarios = useCallback(async () => {
    try {
      setLoadingUsuarios(true);
      const response = await usuariosService.getUsuarios();
      setUsuarios(response.data || response || []);
    } catch (err) {
      console.error('Error cargando usuarios:', err);
      setError('Error al cargar la lista de usuarios');
    } finally {
      setLoadingUsuarios(false);
    }
  }, []);

  useEffect(() => {
    if (open && reporte) {
      // Cargar seguimientos del reporte
      cargarSeguimientos();
      // Cargar usuarios para el dropdown
      cargarUsuarios();
      // Reset form
      setFormData({
        responsable_id: '',
        responsable_nombre: '',
        descripcion: '',
        fecha: new Date().toISOString().split('T')[0],
        estado: 'pendiente',
        imagen: null
      });
      setImagenPreview(null);
      setError(null);
      setSuccess(null);
      setShowScrollToTop(false);
      setMostrarSeguimientos(true);
    } else if (!open) {
      // Limpiar seguimientos cuando se cierre el modal
      setSeguimientos([]);
    }
  }, [open, reporte, cargarSeguimientos, cargarUsuarios]);

  useEffect(() => {
    const handleScroll = (e) => {
      if (isMobile && e.target.scrollTop > 300) {
        setShowScrollToTop(true);
      } else {
        setShowScrollToTop(false);
      }
    };

    if (open && isMobile) {
      const dialogContent = document.querySelector('.MuiDialogContent-root');
      if (dialogContent) {
        dialogContent.addEventListener('scroll', handleScroll);
        return () => {
          dialogContent.removeEventListener('scroll', handleScroll);
        };
      }
    }
  }, [open, isMobile]);

  // Validación temprana de props para evitar errores de React
  if (!open) {
    return null;
  }
  
  if (!reporte) {
    return (
      <Dialog open={open} onClose={onClose}>
        <DialogContent>
          <Typography>Error: No se ha proporcionado información del reporte</Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={onClose}>Cerrar</Button>
        </DialogActions>
      </Dialog>
    );
  }

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleToggleSeguimientos = () => {
    setMostrarSeguimientos(!mostrarSeguimientos);
    if (!mostrarSeguimientos && seguimientos.length === 0) {
      cargarSeguimientos();
    }
  };

  const handleActualizarSeguimientos = async () => {
    await cargarSeguimientos();
  };

  const handleVerEvidencia = (evidencia, responsable, fecha) => {
    // En un caso real, aquí se cargaría la imagen desde la API
    // Por ahora simulamos con diferentes tipos de imagen de ejemplo
    let imagenUrl = null;
    
    if (evidencia) {
      // Usar different images from Lorem Picsum para evidencias
      imagenUrl = `https://picsum.photos/600/400?random=${evidencia.length}${Date.now()}`;
    }
    
    setEvidenciaModal({
      open: true,
      imagen: imagenUrl,
      titulo: `Evidencia: ${evidencia || 'Sin nombre'}`,
      descripcion: `Responsable: ${responsable} | Fecha: ${fecha}`
    });
    
    setImagenCargando(true);
    setErrorCargaImagen(false);
  };

  const handleCerrarEvidencia = () => {
    setEvidenciaModal({
      open: false,
      imagen: null,
      titulo: '',
      descripcion: ''
    });
    setImagenCargando(false);
    setErrorCargaImagen(false);
  };

  const handleImagenCargada = () => {
    setImagenCargando(false);
    setErrorCargaImagen(false);
  };

  const handleErrorImagen = () => {
    setImagenCargando(false);
    setErrorCargaImagen(true);
  };

  const handleDescargarEvidencia = () => {
    if (evidenciaModal.imagen) {
      // En un caso real, aquí se descargaría el archivo
      const link = document.createElement('a');
      link.href = evidenciaModal.imagen;
      link.download = 'evidencia-seguimiento.jpg';
      link.click();
    }
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setFormData(prev => ({
        ...prev,
        imagen: file
      }));
      
      const reader = new FileReader();
      reader.onload = (e) => {
        setImagenPreview(e.target.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmitSeguimiento = async (e) => {
    e.preventDefault();
    if (!formData.responsable_id || !formData.descripcion) {
      setError('Responsable y descripción son campos obligatorios');
      return;
    }

    if (!reporte?.id && !reporte?.id_reporte) {
      setError('No se puede guardar el seguimiento: reporte no válido');
      return;
    }

    setGuardando(true);
    setError(null);

    try {
      // Preparar datos para el backend
      let evidencia_archivo = null;
      let evidencia_nombre = null;
      let evidencia_tipo = null;
      if (formData.imagen) {
        // Convertir archivo a base64
        evidencia_nombre = formData.imagen.name;
        evidencia_tipo = formData.imagen.type;
        evidencia_archivo = await new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onload = () => resolve(reader.result.split(',')[1]);
          reader.onerror = reject;
          reader.readAsDataURL(formData.imagen);
        });
      }

      const seguimientoPayload = {
        id_reporte: reporte.id || reporte.id_reporte,
        responsable: formData.responsable_nombre || formData.responsable_id,
        fecha_seguimiento: formData.fecha,
        descripcion: formData.descripcion,
        estado: formData.estado,
        validado: 0,
        evidencia_archivo,
        evidencia_nombre,
        evidencia_tipo
      };

      await seguimientoService.createSeguimiento(seguimientoPayload);
      setSuccess('Seguimiento guardado exitosamente');
      setFormData({
        responsable_id: '',
        responsable_nombre: '',
        descripcion: '',
        fecha: new Date().toISOString().split('T')[0],
        estado: 'pendiente',
        imagen: null
      });
      setImagenPreview(null);
      cargarSeguimientos();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError('Error al guardar el seguimiento');
    } finally {
      setGuardando(false);
    }
  };

  const handleCancelar = () => {
    if (formData.responsable_nombre || formData.descripcion || formData.imagen) {
      if (window.confirm('Se perderán los datos ingresados. ¿Está seguro?')) {
        onClose();
      }
    } else {
      onClose();
    }
  };

  const scrollToTop = () => {
    const dialogContent = document.querySelector('.MuiDialogContent-root');
    if (dialogContent) {
      dialogContent.scrollTo({ top: 0, behavior: 'smooth' });
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

  const getGravedadColor = (gravedad) => {
    switch (gravedad) {
      case 'baja': return 'success';
      case 'media': return 'warning';
      case 'alta': return 'error';
      case 'critica': return 'error';
      default: return 'default';
    }
  };

  if (!reporte) return null;

  return (
    <Dialog 
      open={open} 
      onClose={onClose} 
      maxWidth={isMobile ? false : "lg"}
      fullWidth={!isMobile}
      fullScreen={isMobile}
      sx={{ 
        '& .MuiDialog-paper': isMobile ? {
          margin: 0,
          maxHeight: '100vh',
          borderRadius: 0
        } : {
          borderRadius: 3,
          maxHeight: '90vh',
          margin: 2
        }
      }}
    >
      {/* AppBar con gradiente similar a Flutter */}
      <AppBar 
        position="sticky"
        sx={{
          background: 'linear-gradient(45deg, #2e7d32 30%, #4caf50 90%)',
          boxShadow: '0 3px 5px 2px rgba(76, 175, 80, .3)',
        }}
      >
        <Toolbar variant={isSmallScreen ? "dense" : "regular"}>
          <IconButton
            edge="start"
            color="inherit"
            onClick={handleCancelar}
            sx={{ mr: { xs: 1, sm: 2 } }}
          >
            <ArrowBackIcon />
          </IconButton>
          <Typography 
            variant={isSmallScreen ? "subtitle1" : "h6"} 
            component="div" 
            sx={{ 
              flexGrow: 1,
              fontSize: { xs: '1rem', sm: '1.25rem' }
            }}
          >
            {isSmallScreen ? `Reporte #${reporte?.id_reporte || 'N/A'}` : `Detalle del Reporte #${reporte?.id_reporte || 'N/A'}`}
          </Typography>
        </Toolbar>
      </AppBar>

      <DialogContent sx={{ 
        p: { xs: 1, sm: 2 }, 
        backgroundColor: '#f5f5f5',
        height: isMobile ? 'calc(100vh - 64px)' : 'auto',
        overflowY: 'auto'
      }}>
        <Box sx={{ 
          maxWidth: { xs: '100%', sm: '600px', md: '800px' },
          margin: '0 auto', 
          pb: { xs: 1, sm: 2 }
        }}>
          
          {/* Alerta de éxito */}
          {success && (
            <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess(null)}>
              {success}
            </Alert>
          )}

          {/* Alerta de error */}
          {error && (
            <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
              {error}
            </Alert>
          )}

          {/* Información del reporte */}
          <Card sx={{ mb: { xs: 1.5, sm: 2 }, borderRadius: { xs: 2, sm: 3 }, boxShadow: 3 }}>
            <CardContent sx={{ p: { xs: 1.5, sm: 2 } }}>
              <Typography variant="h6" sx={{ mb: 2, fontWeight: 'bold' }}>
                📋 Información del Reporte
              </Typography>
              <Grid container spacing={{ xs: 1, sm: 2 }}>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary" sx={{ fontSize: { xs: '0.85rem', sm: '0.875rem' } }}>
                    <strong>Folio:</strong> {reporte.folio || 'N/A'}
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2" color="text.secondary" sx={{ fontSize: { xs: '0.85rem', sm: '0.875rem' } }}>
                    <strong>Fecha:</strong> {reporte?.fecha_incidencia || 'N/A'}
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Box display="flex" alignItems="center" gap={1} flexWrap="wrap">
                    <Typography component="span" sx={{ fontSize: { xs: '0.85rem', sm: '0.875rem' } }}>
                      <strong>Estado:</strong>
                    </Typography>
                    <Chip 
                      label={reporte.estatus || 'pendiente'} 
                      color={getEstadoColor(reporte.estatus)}
                      size="small"
                    />
                  </Box>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Box display="flex" alignItems="center" gap={1} flexWrap="wrap">
                    <Typography component="span" sx={{ fontSize: { xs: '0.85rem', sm: '0.875rem' } }}>
                      <strong>Gravedad:</strong>
                    </Typography>
                    <Chip 
                      label={reporte.tipo_gravedad || 'media'} 
                      color={getGravedadColor(reporte.tipo_gravedad)}
                      size="small"
                    />
                  </Box>
                </Grid>
              </Grid>
            </CardContent>
          </Card>

          {/* Información del alumno */}
          <Card sx={{ mb: { xs: 1.5, sm: 2 }, borderRadius: { xs: 2, sm: 3 }, boxShadow: 3 }}>
            <CardContent sx={{ p: { xs: 1.5, sm: 2 } }}>
              <Typography variant={isSmallScreen ? "subtitle1" : "h6"} sx={{ mb: { xs: 1, sm: 2 }, fontWeight: 'bold' }}>
                👨‍🎓 Alumno Involucrado
              </Typography>
              {reporte.alumno ? (
                <Grid container spacing={{ xs: 1, sm: 2 }}>
                  <Grid item xs={12}>
                    <Typography variant="body1" sx={{ fontSize: { xs: '0.9rem', sm: '1rem' } }}>
                      <strong>Nombre:</strong> {reporte?.alumno?.nombre || ''} {reporte?.alumno?.apellido_paterno || ''} {reporte?.alumno?.apellido_materno || ''}
                    </Typography>
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <Typography variant="body2" color="text.secondary" sx={{ fontSize: { xs: '0.85rem', sm: '0.875rem' } }}>
                      <strong>Matrícula:</strong> {reporte?.alumno?.matricula || 'N/A'}
                    </Typography>
                  </Grid>
                  {reporte?.alumno?.grupo && (
                    <Grid item xs={12} sm={6}>
                      <Typography variant="body2" color="text.secondary" sx={{ fontSize: { xs: '0.85rem', sm: '0.875rem' } }}>
                        <strong>Grupo:</strong> {reporte?.alumno?.grupo?.grupo || ''} - {reporte?.alumno?.grupo?.grado || ''}
                      </Typography>
                    </Grid>
                  )}
                </Grid>
              ) : (
                <Typography color="text.secondary">Información del alumno no disponible</Typography>
              )}
            </CardContent>
          </Card>

          {/* Descripción */}
          <Card sx={{ mb: { xs: 1.5, sm: 2 }, borderRadius: { xs: 2, sm: 3 }, boxShadow: 3 }}>
            <CardContent sx={{ p: { xs: 1.5, sm: 2 } }}>
              <Typography variant={isSmallScreen ? "subtitle1" : "h6"} sx={{ mb: { xs: 1, sm: 2 }, fontWeight: 'bold' }}>
                📄 Descripción de los Hechos
              </Typography>
              <Typography 
                variant="body1" 
                sx={{ 
                  whiteSpace: 'pre-wrap', 
                  lineHeight: 1.6,
                  fontSize: { xs: '0.9rem', sm: '1rem' }
                }}
              >
                {reporte?.descripcion_hechos || 'No hay descripción disponible'}
              </Typography>
            </CardContent>
          </Card>

          {/* Formulario de seguimiento */}
          <Card sx={{ mb: { xs: 1.5, sm: 2 }, borderRadius: { xs: 2, sm: 3 }, boxShadow: 3 }}>
            <CardContent sx={{ p: { xs: 1.5, sm: 2 } }}>
              <Typography variant={isSmallScreen ? "subtitle1" : "h6"} sx={{ mb: { xs: 1, sm: 2 }, fontWeight: 'bold' }}>
                ➕ Agregar Seguimiento
              </Typography>
              
              <Box component="form" onSubmit={handleSubmitSeguimiento}>
                <Grid container spacing={{ xs: 2, sm: 3 }}>
                  {/* Campo Responsable */}
                  <Grid item xs={12}>
                    <FormControl 
                      fullWidth 
                      variant="outlined" 
                      size={isSmallScreen ? "small" : "medium"}
                      required
                    >
                      <InputLabel>Responsable *</InputLabel>
                      <Select
                        label="Responsable *"
                        name="responsable"
                        value={formData.responsable_id}
                        onChange={(e) => {
                          const selectedId = e.target.value;
                          const usuarioSeleccionado = usuarios.find(u => 
                            (u?.id_usuario || u?.id) === selectedId
                          );
                          
                          setFormData(prev => ({
                            ...prev,
                            responsable_id: selectedId,
                            responsable_nombre: usuarioSeleccionado 
                              ? `${usuarioSeleccionado?.nombre || ''} ${usuarioSeleccionado?.apellido_paterno || ''} ${usuarioSeleccionado?.apellido_materno || ''}`.trim()
                              : ''
                          }));
                        }}
                        disabled={guardando || loadingUsuarios}
                        MenuProps={{
                          PaperProps: {
                            style: {
                              maxHeight: 200
                            }
                          }
                        }}
                      >
                        {loadingUsuarios ? (
                          <MenuItem disabled>
                            <Box display="flex" alignItems="center" gap={1}>
                              <CircularProgress size={16} />
                              Cargando usuarios...
                            </Box>
                          </MenuItem>
                        ) : usuarios.length === 0 ? (
                          <MenuItem disabled>
                            <Box display="flex" alignItems="center" gap={1}>
                              <Typography variant="body2">
                                No hay usuarios disponibles
                              </Typography>
                              <Button 
                                size="small" 
                                onClick={cargarUsuarios}
                                sx={{ minWidth: 'auto', p: 0.5 }}
                              >
                                <RefreshIcon fontSize="small" />
                              </Button>
                            </Box>
                          </MenuItem>
                        ) : (
                          usuarios.map((usuario) => (
                            <MenuItem 
                              key={usuario?.id_usuario || usuario?.id || Math.random()} 
                              value={usuario?.id_usuario || usuario?.id}
                            >
                              <Box>
                                <Typography variant="body2" sx={{ fontWeight: 500 }}>
                                  {usuario?.nombre || ''} {usuario?.apellido_paterno || ''} {usuario?.apellido_materno || ''}
                                </Typography>
                                <Typography variant="caption" color="text.secondary">
                                  {usuario?.email || 'Sin email'} • {usuario?.rol || 'Sin rol'}
                                </Typography>
                              </Box>
                            </MenuItem>
                          ))
                        )}
                      </Select>
                    </FormControl>
                  </Grid>
                  
                  {/* Fecha y Estado en fila */}
                  <Grid item xs={12} sm={6}>
                    <TextField
                      fullWidth
                      label="Fecha de seguimiento"
                      name="fecha"
                      type="date"
                      value={formData.fecha}
                      onChange={handleInputChange}
                      variant="outlined"
                      disabled={guardando}
                      InputLabelProps={{ shrink: true }}
                      size={isSmallScreen ? "small" : "medium"}
                    />
                  </Grid>
                  
                  <Grid item xs={12} sm={6}>
                    <FormControl fullWidth variant="outlined" size={isSmallScreen ? "small" : "medium"}>
                      <InputLabel>Estado</InputLabel>
                      <Select
                        label="Estado"
                        name="estado"
                        value={formData.estado}
                        onChange={handleInputChange}
                        disabled={guardando}
                      >
                        {estados.map(estado => (
                          <MenuItem key={estado.value} value={estado.value}>
                            {estado.label}
                          </MenuItem>
                        ))}
                      </Select>
                    </FormControl>
                  </Grid>
                  
                  {/* Campo Descripción */}
                  <Grid item xs={12}>
                    <TextField
                      fullWidth
                      label="Descripción del seguimiento *"
                      name="descripcion"
                      value={formData.descripcion}
                      onChange={handleInputChange}
                      variant="outlined"
                      multiline
                      rows={isSmallScreen ? 3 : 4}
                      disabled={guardando}
                      placeholder="Describa las acciones tomadas, observaciones o seguimiento realizado..."
                      size={isSmallScreen ? "small" : "medium"}
                      required
                    />
                  </Grid>
                  
                  {/* Selector de evidencia */}
                  <Grid item xs={12}>
                    <Box 
                      sx={{ 
                        border: '2px dashed #e0e0e0', 
                        borderRadius: 2, 
                        p: { xs: 2, sm: 3 }, 
                        textAlign: 'center',
                        bgcolor: '#fafafa',
                        transition: 'all 0.2s ease',
                        '&:hover': {
                          borderColor: '#bdbdbd',
                          bgcolor: '#f5f5f5'
                        }
                      }}
                    >
                      <input
                        type="file"
                        accept="image/*"
                        onChange={handleImageChange}
                        style={{ display: 'none' }}
                        id="imagen-input"
                        disabled={guardando}
                      />
                      <label htmlFor="imagen-input">
                        <Button
                          variant="outlined"
                          component="span"
                          startIcon={<CameraIcon />}
                          disabled={guardando}
                          size={isSmallScreen ? "small" : "medium"}
                          sx={{
                            borderStyle: 'dashed',
                            '&:hover': {
                              borderStyle: 'solid'
                            }
                          }}
                        >
                          {isSmallScreen ? 'Seleccionar Evidencia' : 'Seleccionar Evidencia (Opcional)'}
                        </Button>
                      </label>
                      
                      {imagenPreview && (
                        <Box sx={{ mt: 2 }}>
                          <Box
                            sx={{
                              display: 'inline-block',
                              border: '1px solid #e0e0e0',
                              borderRadius: 2,
                              p: 1,
                              bgcolor: 'white'
                            }}
                          >
                            <img
                              src={imagenPreview}
                              alt="Preview"
                              style={{ 
                                maxWidth: isSmallScreen ? '120px' : '180px', 
                                maxHeight: isSmallScreen ? '120px' : '180px', 
                                objectFit: 'contain',
                                borderRadius: '4px',
                                display: 'block'
                              }}
                            />
                          </Box>
                          <Typography 
                            variant="caption" 
                            display="block" 
                            sx={{ 
                              mt: 1, 
                              color: 'success.main',
                              fontWeight: 500
                            }}
                          >
                            ✓ Evidencia seleccionada
                          </Typography>
                        </Box>
                      )}
                    </Box>
                  </Grid>
                  
                  {/* Botones de acción */}
                  <Grid item xs={12}>
                    <Box 
                      sx={{
                        display: 'flex',
                        gap: { xs: 1.5, sm: 2 },
                        flexDirection: { xs: 'column', sm: 'row' },
                        alignItems: 'stretch',
                        mt: 1
                      }}
                    >
                      <Button
                        variant="outlined"
                        color="error"
                        startIcon={<CancelIcon />}
                        onClick={handleCancelar}
                        disabled={guardando}
                        size={isSmallScreen ? "medium" : "large"}
                        sx={{ 
                          flex: { sm: 1 },
                          minHeight: '48px'
                        }}
                      >
                        Cancelar
                      </Button>
                      <Button
                        type="submit"
                        variant="contained"
                        color="success"
                        startIcon={guardando ? null : <SaveIcon />}
                        disabled={guardando || (!formData.responsable_id || !formData.descripcion)}
                        size={isSmallScreen ? "medium" : "large"}
                        sx={{ 
                          flex: { sm: 2 },
                          minHeight: '48px',
                          fontWeight: 600
                        }}
                      >
                        {guardando ? (
                          <Box display="flex" alignItems="center" gap={1}>
                            <CircularProgress size={16} sx={{ color: 'white' }} />
                            Guardando...
                          </Box>
                        ) : (
                          isSmallScreen ? 'Guardar Seguimiento' : 'Guardar Seguimiento'
                        )}
                      </Button>
                    </Box>
                  </Grid>
                </Grid>
              </Box>
            </CardContent>
          </Card>

          {/* Gestión de seguimientos */}
          <Card sx={{ mb: { xs: 1.5, sm: 2 }, borderRadius: { xs: 2, sm: 3 }, boxShadow: 3 }}>
            <CardContent sx={{ p: { xs: 1.5, sm: 2 } }}>
              <Typography variant={isSmallScreen ? "subtitle1" : "h6"} sx={{ mb: { xs: 1, sm: 2 }, fontWeight: 'bold' }}>
                📊 Gestión de Seguimientos
              </Typography>
              <Grid container spacing={{ xs: 1, sm: 2 }}>
                <Grid item xs={12} sm={6}>
                  <Button
                    fullWidth
                    variant="contained"
                    color="primary"
                    startIcon={!isSmallScreen && <TimelineIcon />}
                    onClick={handleToggleSeguimientos}
                    size={isSmallScreen ? "small" : "medium"}
                  >
                    {mostrarSeguimientos ? 
                      (isSmallScreen ? 'Ocultar' : 'Ocultar Seguimientos') : 
                      (isSmallScreen ? 'Ver' : 'Ver Seguimientos')
                    }
                  </Button>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Button
                    fullWidth
                    variant="contained"
                    color="success"
                    startIcon={actualizandoSeguimientos ? 
                      <CircularProgress size={16} color="inherit" /> : 
                      (!isSmallScreen && <RefreshIcon />)
                    }
                    onClick={handleActualizarSeguimientos}
                    disabled={actualizandoSeguimientos}
                    size={isSmallScreen ? "small" : "medium"}
                  >
                    {actualizandoSeguimientos ? 'Actualizando...' : 'Actualizar'}
                  </Button>
                </Grid>
              </Grid>
            </CardContent>
          </Card>

          {/* Seguimientos existentes */}
          {mostrarSeguimientos && (
            <Card sx={{ mb: { xs: 1.5, sm: 2 }, borderRadius: { xs: 2, sm: 3 }, boxShadow: 3 }}>
              <CardContent sx={{ p: { xs: 1.5, sm: 2 } }}>
                <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                  <Typography variant={isSmallScreen ? "subtitle1" : "h6"} sx={{ fontWeight: 'bold' }}>
                    📝 Seguimientos - Reporte #{reporte?.id_reporte}
                  </Typography>
                  <Chip 
                    label={`${seguimientos.length} seguimiento${seguimientos.length !== 1 ? 's' : ''}`} 
                    size="small" 
                    color="primary" 
                    variant="outlined"
                  />
                </Box>
                
                {actualizandoSeguimientos ? (
                  <Box display="flex" justifyContent="center" alignItems="center" py={4}>
                    <Box textAlign="center">
                      <CircularProgress size={32} sx={{ mb: 2 }} />
                      <Typography variant="body2" color="text.secondary">
                        Cargando seguimientos...
                      </Typography>
                    </Box>
                  </Box>
                ) : seguimientos.length === 0 ? (
                  <Box textAlign="center" py={4}>
                    <Typography variant="body2" color="text.secondary" gutterBottom>
                      No hay seguimientos registrados para este reporte
                    </Typography>
                    <Button
                      variant="outlined"
                      size="small"
                      startIcon={<RefreshIcon />}
                      onClick={handleActualizarSeguimientos}
                      sx={{ mt: 1 }}
                    >
                      Actualizar
                    </Button>
                  </Box>
                ) : (
                  seguimientos.map((seg) => (
                    <Paper key={seg.id} elevation={1} sx={{ p: { xs: 1.5, sm: 2 }, mb: { xs: 1.5, sm: 2 }, borderRadius: 2 }}>
                      <Grid container spacing={{ xs: 0.5, sm: 1 }}>
                        <Grid item xs={12}>
                          <Typography 
                            variant="subtitle2" 
                            sx={{ 
                              fontWeight: 'bold',
                              fontSize: { xs: '0.9rem', sm: '0.875rem' }
                            }}
                          >
                            Responsable: {seg.responsable}
                          </Typography>
                        </Grid>
                        <Grid item xs={12} sm={6}>
                          <Typography 
                            variant="body2" 
                            color="text.secondary"
                            sx={{ fontSize: { xs: '0.8rem', sm: '0.875rem' } }}
                          >
                            Fecha: {seg.fecha}
                          </Typography>
                        </Grid>
                        <Grid item xs={12} sm={6}>
                          <Chip 
                            label={seg.estado} 
                            color={getEstadoColor(seg.estado)} 
                            size="small"
                            sx={{ fontSize: { xs: '0.7rem', sm: '0.75rem' } }}
                          />
                        </Grid>
                        <Grid item xs={12}>
                          <Typography 
                            variant="body2" 
                            sx={{ 
                              mt: 1,
                              fontSize: { xs: '0.85rem', sm: '0.875rem' }
                            }}
                          >
                            {seg.descripcion}
                          </Typography>
                        </Grid>
                        {seg.evidencia && (
                          <Grid item xs={12}>
                            <Box 
                              sx={{ 
                                mt: 1, 
                                p: { xs: 0.5, sm: 1 }, 
                                backgroundColor: '#e3f2fd', 
                                borderRadius: 1,
                                border: '1px solid #bbdefb',
                                cursor: 'pointer',
                                transition: 'all 0.2s ease',
                                '&:hover': {
                                  backgroundColor: '#bbdefb',
                                  transform: 'translateY(-1px)',
                                  boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
                                }
                              }}
                              onClick={() => handleVerEvidencia(seg.evidencia, seg.responsable, seg.fecha)}
                            >
                              <Box display="flex" alignItems="center" justifyContent="space-between">
                                <Box display="flex" alignItems="center" gap={1}>
                                  <ImageIcon color="primary" fontSize="small" />
                                  <Typography 
                                    variant="caption" 
                                    color="primary"
                                    sx={{ fontSize: { xs: '0.7rem', sm: '0.75rem' } }}
                                  >
                                    Evidencia adjunta
                                  </Typography>
                                </Box>
                                <ZoomInIcon color="primary" fontSize="small" />
                              </Box>
                              <Typography 
                                variant="caption" 
                                color="text.secondary"
                                sx={{ fontSize: '0.65rem', mt: 0.5, display: 'block' }}
                              >
                                Clic para ver evidencia
                              </Typography>
                            </Box>
                          </Grid>
                        )}
                      </Grid>
                    </Paper>
                  ))
                )}
              </CardContent>
            </Card>
          )}
        </Box>
      </DialogContent>      
      {/* FAB para scroll hacia arriba en móvil */}
      <Zoom in={showScrollToTop && isMobile}>
        <Fab
          color="primary"
          size="medium"
          onClick={scrollToTop}
          sx={{
            position: 'fixed',
            bottom: 20,
            right: 20,
            zIndex: 1300
          }}
        >
          <KeyboardArrowUpIcon />
        </Fab>
      </Zoom>
      
      {/* Modal para ver evidencia */}
      <Dialog
        open={evidenciaModal.open}
        onClose={handleCerrarEvidencia}
        maxWidth="md"
        fullWidth
        PaperProps={{
          sx: {
            borderRadius: 3,
            minHeight: { xs: '50vh', sm: '60vh' }
          }
        }}
      >
        <DialogTitle>
          <Box display="flex" alignItems="center" justifyContent="space-between">
            <Typography variant="h6" component="span">
              {evidenciaModal.titulo}
            </Typography>
            <IconButton
              onClick={handleCerrarEvidencia}
              size="small"
              sx={{ color: 'grey.500' }}
            >
              <CloseIcon />
            </IconButton>
          </Box>
          {evidenciaModal.descripcion && (
            <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
              {evidenciaModal.descripcion}
            </Typography>
          )}
        </DialogTitle>
        
        <DialogContent sx={{ p: 0, display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '400px' }}>
          {evidenciaModal.imagen ? (
            <Box
              sx={{
                width: '100%',
                height: { xs: '300px', sm: '400px' },
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                bgcolor: '#f5f5f5',
                position: 'relative'
              }}
            >
              {imagenCargando && (
                <Box
                  sx={{
                    position: 'absolute',
                    top: '50%',
                    left: '50%',
                    transform: 'translate(-50%, -50%)',
                    zIndex: 1
                  }}
                >
                  <CircularProgress size={40} />
                </Box>
              )}
              
              {errorCargaImagen ? (
                <Box textAlign="center" py={4}>
                  <ImageIcon sx={{ fontSize: 64, color: 'grey.300', mb: 2 }} />
                  <Typography variant="body2" color="text.secondary" gutterBottom>
                    Error al cargar la evidencia
                  </Typography>
                  <Button
                    size="small"
                    onClick={() => {
                      setErrorCargaImagen(false);
                      setImagenCargando(true);
                    }}
                  >
                    Intentar de nuevo
                  </Button>
                </Box>
              ) : (
                <img
                  src={evidenciaModal.imagen}
                  alt="Evidencia de seguimiento"
                  onLoad={handleImagenCargada}
                  onError={handleErrorImagen}
                  style={{
                    maxWidth: '100%',
                    maxHeight: '100%',
                    objectFit: 'contain',
                    borderRadius: '8px',
                    display: imagenCargando ? 'none' : 'block'
                  }}
                />
              )}
            </Box>
          ) : (
            <Box textAlign="center" py={4}>
              <ImageIcon sx={{ fontSize: 64, color: 'grey.300', mb: 2 }} />
              <Typography variant="body2" color="text.secondary">
                No hay evidencia disponible
              </Typography>
            </Box>
          )}
        </DialogContent>
        
        <DialogActions sx={{ p: 2, justifyContent: 'space-between' }}>
          <Button
            onClick={handleCerrarEvidencia}
            color="primary"
          >
            Cerrar
          </Button>
          
          <Button
            onClick={handleDescargarEvidencia}
            variant="contained"
            color="primary"
            startIcon={<DownloadIcon />}
            disabled={!evidenciaModal.imagen}
          >
            Descargar
          </Button>
        </DialogActions>
      </Dialog>
    </Dialog>
  );
};

export default ReporteDetailModal;