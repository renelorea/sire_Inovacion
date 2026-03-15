import React, { useEffect, useState } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Alert,
  List,
  ListItem,
  ListItemText,
  Chip,
  Button,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';

const ErrorCheckPage = () => {
  const navigate = useNavigate();
  const [consoleErrors, setConsoleErrors] = useState([]);
  const [consoleWarnings, setConsoleWarnings] = useState([]);

  useEffect(() => {
    // Capturar errores de la consola
    const originalError = console.error;
    const originalWarn = console.warn;
    
    console.error = function(...args) {
      setConsoleErrors(prev => [...prev, args.join(' ')]);
      originalError.apply(console, args);
    };

    console.warn = function(...args) {
      setConsoleWarnings(prev => [...prev, args.join(' ')]);
      originalWarn.apply(console, args);
    };

    return () => {
      console.error = originalError;
      console.warn = originalWarn;
    };
  }, []);

  const clearErrors = () => {
    setConsoleErrors([]);
    setConsoleWarnings([]);
  };

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Paper sx={{ p: 4 }}>
        <Typography variant="h4" gutterBottom>
          🔍 Verificación de Errores de Consola
        </Typography>
        
        <Typography variant="body1" color="text.secondary" sx={{ mb: 3 }}>
          Esta página monitorea los errores y warnings de la consola del navegador en tiempo real.
        </Typography>

        <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
          <Button variant="contained" onClick={() => navigate('/dashboard')}>
            Ir al Dashboard
          </Button>
          <Button variant="outlined" onClick={clearErrors}>
            Limpiar Errores
          </Button>
        </Box>

        <Box sx={{ mb: 3 }}>
          <Alert severity={consoleErrors.length > 0 ? 'error' : 'success'} sx={{ mb: 2 }}>
            <Typography variant="h6">
              Errores de Consola: {consoleErrors.length}
            </Typography>
            {consoleErrors.length === 0 && (
              <Typography>¡No hay errores detectados!</Typography>
            )}
          </Alert>

          {consoleErrors.length > 0 && (
            <Paper variant="outlined" sx={{ p: 2, mb: 2 }}>
              <Typography variant="subtitle1" color="error" gutterBottom>
                Errores Detectados:
              </Typography>
              <List dense>
                {consoleErrors.map((error, index) => (
                  <ListItem key={index}>
                    <ListItemText
                      primary={
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                          <Chip label="ERROR" color="error" size="small" />
                          <Typography variant="body2" color="error">
                            {error}
                          </Typography>
                        </Box>
                      }
                    />
                  </ListItem>
                ))}
              </List>
            </Paper>
          )}
        </Box>

        <Box>
          <Alert severity={consoleWarnings.length > 0 ? 'warning' : 'info'} sx={{ mb: 2 }}>
            <Typography variant="h6">
              Warnings de Consola: {consoleWarnings.length}
            </Typography>
            {consoleWarnings.length === 0 && (
              <Typography>¡No hay warnings detectados!</Typography>
            )}
          </Alert>

          {consoleWarnings.length > 0 && (
            <Paper variant="outlined" sx={{ p: 2 }}>
              <Typography variant="subtitle1" color="warning.main" gutterBottom>
                Warnings Detectados:
              </Typography>
              <List dense>
                {consoleWarnings.map((warning, index) => (
                  <ListItem key={index}>
                    <ListItemText
                      primary={
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                          <Chip label="WARNING" color="warning" size="small" />
                          <Typography variant="body2">
                            {warning}
                          </Typography>
                        </Box>
                      }
                    />
                  </ListItem>
                ))}
              </List>
            </Paper>
          )}
        </Box>

        <Alert severity="info" sx={{ mt: 3 }}>
          <Typography variant="body2">
            <strong>Instrucciones:</strong><br/>
            1. Navega por la aplicación normalmente<br/>
            2. Esta página capturará cualquier error o warning<br/>
            3. Revisa periódicamente para ver si hay problemas<br/>
            4. Usa las herramientas de desarrollador (F12) para más detalles
          </Typography>
        </Alert>
      </Paper>
    </Container>
  );
};

export default ErrorCheckPage;