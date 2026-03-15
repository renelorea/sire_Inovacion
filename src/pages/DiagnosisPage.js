import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Button,
  Alert,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  CircularProgress,
  Divider,
  TextField,
} from '@mui/material';
import {
  CheckCircle as CheckIcon,
  Error as ErrorIcon,
  Warning as WarningIcon,
  Info as InfoIcon,
} from '@mui/icons-material';
import { authService } from '../services/authService';
import api from '../services/api';

const DiagnosisPage = () => {
  const [diagnostics, setDiagnostics] = useState([]);
  const [loading, setLoading] = useState(false);
  const [testCredentials, setTestCredentials] = useState({
    correo: 'admin@sistema.com',
    contraseña: '123456'
  });

  const runDiagnostics = async () => {
    setLoading(true);
    const results = [];

    // Test 1: API Configuration
    try {
      const apiUrl = process.env.REACT_APP_API_URL;
      if (apiUrl) {
        results.push({
          test: 'Configuración API',
          status: 'success',
          message: `URL configurada: ${apiUrl}`,
          icon: CheckIcon
        });
      } else {
        results.push({
          test: 'Configuración API',
          status: 'error',
          message: 'REACT_APP_API_URL no configurada en .env',
          icon: ErrorIcon
        });
      }
    } catch (error) {
      results.push({
        test: 'Configuración API',
        status: 'error',
        message: 'Error al verificar configuración',
        icon: ErrorIcon
      });
    }

    // Test 2: Backend Connection
    try {
      const response = await fetch(`${process.env.REACT_APP_API_URL}/`);
      if (response.ok || response.status === 404) {
        results.push({
          test: 'Conexión Backend',
          status: 'success',
          message: 'Backend respondiendo correctamente',
          icon: CheckIcon
        });
      } else {
        results.push({
          test: 'Conexión Backend',
          status: 'warning',
          message: `Backend responde con código: ${response.status}`,
          icon: WarningIcon
        });
      }
    } catch (error) {
      results.push({
        test: 'Conexión Backend',
        status: 'error',
        message: `Error de conexión: ${error.message}`,
        icon: ErrorIcon
      });
    }

    // Test 3: CORS Configuration
    try {
      const response = await api.get('/');
      results.push({
        test: 'Configuración CORS',
        status: 'success',
        message: 'CORS configurado correctamente',
        icon: CheckIcon
      });
    } catch (error) {
      if (error.message?.includes('CORS')) {
        results.push({
          test: 'Configuración CORS',
          status: 'error',
          message: 'Error de CORS - verifica configuración del backend',
          icon: ErrorIcon
        });
      } else {
        results.push({
          test: 'Configuración CORS',
          status: 'warning',
          message: 'No se pudo verificar CORS completamente',
          icon: WarningIcon
        });
      }
    }

    // Test 4: Authentication Storage
    const token = localStorage.getItem('token');
    const user = localStorage.getItem('user');
    
    if (token && user) {
      results.push({
        test: 'Estado de Autenticación',
        status: 'success',
        message: 'Usuario autenticado encontrado en localStorage',
        icon: CheckIcon
      });
    } else {
      results.push({
        test: 'Estado de Autenticación',
        status: 'info',
        message: 'No hay sesión activa',
        icon: InfoIcon
      });
    }

    // Test 5: Login Test
    try {
      const loginResult = await authService.login(testCredentials.correo, testCredentials.contraseña);
      if (loginResult.access_token || loginResult.token) {
        results.push({
          test: 'Prueba de Login',
          status: 'success',
          message: 'Login funciona correctamente',
          icon: CheckIcon
        });
      } else {
        results.push({
          test: 'Prueba de Login',
          status: 'error',
          message: 'Login no devolvió token',
          icon: ErrorIcon
        });
      }
    } catch (error) {
      results.push({
        test: 'Prueba de Login',
        status: 'error',
        message: `Error en login: ${error.message || 'Error desconocido'}`,
        icon: ErrorIcon
      });
    }

    setDiagnostics(results);
    setLoading(false);
  };

  const clearStorage = () => {
    localStorage.clear();
    window.location.reload();
  };

  useEffect(() => {
    runDiagnostics();
  }, []);

  const getAlertSeverity = (status) => {
    switch (status) {
      case 'success':
        return 'success';
      case 'warning':
        return 'warning';
      case 'error':
        return 'error';
      default:
        return 'info';
    }
  };

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Paper sx={{ p: 4 }}>
        <Typography variant="h4" gutterBottom>
          🔧 Diagnóstico del Sistema
        </Typography>
        
        <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
          Esta página realiza pruebas automáticas para verificar el funcionamiento del sistema.
        </Typography>

        <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
          <Button 
            variant="contained" 
            onClick={runDiagnostics}
            disabled={loading}
            startIcon={loading && <CircularProgress size={20} />}
          >
            {loading ? 'Ejecutando...' : 'Ejecutar Diagnósticos'}
          </Button>
          
          <Button 
            variant="outlined" 
            color="error"
            onClick={clearStorage}
          >
            Limpiar Almacenamiento
          </Button>
        </Box>

        <Divider sx={{ my: 3 }} />

        {diagnostics.length > 0 && (
          <Box>
            <Typography variant="h6" gutterBottom>
              Resultados:
            </Typography>
            
            <List>
              {diagnostics.map((diagnostic, index) => {
                const IconComponent = diagnostic.icon;
                return (
                  <ListItem key={index}>
                    <ListItemIcon>
                      <IconComponent 
                        color={
                          diagnostic.status === 'success' ? 'success' :
                          diagnostic.status === 'warning' ? 'warning' :
                          diagnostic.status === 'error' ? 'error' : 'info'
                        }
                      />
                    </ListItemIcon>
                    <ListItemText
                      primary={diagnostic.test}
                      secondary={diagnostic.message}
                    />
                  </ListItem>
                );
              })}
            </List>

            <Alert severity="info" sx={{ mt: 3 }}>
              <Typography variant="h6" gutterBottom>
                Información del Sistema:
              </Typography>
              <ul>
                <li><strong>Frontend URL:</strong> {window.location.origin}</li>
                <li><strong>Backend URL:</strong> {process.env.REACT_APP_API_URL}</li>
                <li><strong>Version React:</strong> {React.version}</li>
                <li><strong>Token almacenado:</strong> {localStorage.getItem('token') ? 'Sí' : 'No'}</li>
                <li><strong>Usuario almacenado:</strong> {localStorage.getItem('user') ? 'Sí' : 'No'}</li>
              </ul>
            </Alert>

            <Box sx={{ mt: 3 }}>
              <Typography variant="h6" gutterBottom>
                Credenciales de Prueba:
              </Typography>
              <TextField
                fullWidth
                label="Email"
                value={testCredentials.correo}
                onChange={(e) => setTestCredentials({...testCredentials, correo: e.target.value})}
                sx={{ mb: 2 }}
              />
              <TextField
                fullWidth
                label="Contraseña"
                type="password"
                value={testCredentials.contraseña}
                onChange={(e) => setTestCredentials({...testCredentials, contraseña: e.target.value})}
                sx={{ mb: 2 }}
              />
            </Box>
          </Box>
        )}
      </Paper>
    </Container>
  );
};

export default DiagnosisPage;