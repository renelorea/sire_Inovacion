import React from 'react';
import {
  Box,
  Paper,
  Typography,
  Card,
  CardContent,
  CardActionArea,
} from '@mui/material';
import {
  People,
  School,
  Assignment,
  TrendingUp,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
  const navigate = useNavigate();

  const dashboardItems = [
    {
      title: 'Usuarios',
      icon: <People sx={{ fontSize: 40 }} />,
      description: 'Gestión de usuarios del sistema',
      path: '/usuarios',
      color: '#1976d2'
    },
    {
      title: 'Alumnos',
      icon: <School sx={{ fontSize: 40 }} />,
      description: 'Administrar información de alumnos',
      path: '/alumnos',
      color: '#2e7d32'
    },
    {
      title: 'Reportes',
      icon: <Assignment sx={{ fontSize: 40 }} />,
      description: 'Visualizar y gestionar reportes',
      path: '/reportes',
      color: '#ed6c02'
    },
    {
      title: 'Estadísticas',
      icon: <TrendingUp sx={{ fontSize: 40 }} />,
      description: 'Análisis y métricas del sistema',
      path: '/estadisticas',
      color: '#9c27b0'
    },
  ];

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        Dashboard
      </Typography>
      
      <Typography variant="body1" color="text.secondary" paragraph>
        Bienvenido al Sistema de Gestión de Incidencias Escolares
      </Typography>

      <Box sx={{ mt: 2, display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)', md: 'repeat(4, 1fr)' }, gap: 3 }}>
        {dashboardItems.map((item, index) => (
          <Box key={index}>
            <Card sx={{ height: '100%' }}>
              <CardActionArea 
                onClick={() => navigate(item.path)}
                sx={{ height: '100%' }}
              >
                <CardContent sx={{ textAlign: 'center', p: 3 }}>
                  <Box sx={{ color: item.color, mb: 2 }}>
                    {item.icon}
                  </Box>
                  <Typography variant="h6" component="div" gutterBottom>
                    {item.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {item.description}
                  </Typography>
                </CardContent>
              </CardActionArea>
            </Card>
          </Box>
        ))}
      </Box>

      <Box sx={{ mt: 3, display: 'grid', gridTemplateColumns: { xs: '1fr', md: '2fr 1fr' }, gap: 3 }}>
        <Box>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Resumen de Actividad
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Aquí se mostrarían las estadísticas principales del sistema
            </Typography>
          </Paper>
        </Box>
        
        <Box>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Acciones Rápidas
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Enlaces rápidos a las funciones más utilizadas
            </Typography>
          </Paper>
        </Box>
      </Box>
    </Box>
  );
};

export default Dashboard;