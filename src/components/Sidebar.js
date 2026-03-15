import React from 'react';
import {
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Divider,
} from '@mui/material';
import {
  Dashboard,
  People,
  School,
  Group,
  Assignment,
  Settings,
  BugReport,
} from '@mui/icons-material';
import { useNavigate, useLocation } from 'react-router-dom';

const drawerWidth = 240;

const menuItems = [
  { text: 'Dashboard', icon: <Dashboard />, path: '/dashboard' },
  { text: 'Usuarios', icon: <People />, path: '/usuarios' },
  { text: 'Alumnos', icon: <School />, path: '/alumnos' },
  { text: 'Grupos', icon: <Group />, path: '/grupos' },
  { text: 'Tipos de Reporte', icon: <Settings />, path: '/tipos-reporte' },
  { text: 'Reportes', icon: <Assignment />, path: '/reportes' },
  { text: 'Diagnóstico', icon: <BugReport />, path: '/diagnostics' },
];

const Sidebar = ({ mobileOpen, onDrawerToggle }) => {
  const navigate = useNavigate();
  const location = useLocation();

  const handleNavigation = (path) => {
    navigate(path);
    if (onDrawerToggle) {
      onDrawerToggle();
    }
  };

  const drawer = (
    <div>
      <Toolbar />
      <Divider />
      <List>
        {menuItems.map((item) => (
          <ListItem key={item.text} disablePadding>
            <ListItemButton
              selected={location.pathname === item.path}
              onClick={() => handleNavigation(item.path)}
            >
              <ListItemIcon>
                {item.icon}
              </ListItemIcon>
              <ListItemText primary={item.text} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </div>
  );

  return (
    <Drawer
      variant="permanent"
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        [`& .MuiDrawer-paper`]: { 
          width: drawerWidth, 
          boxSizing: 'border-box' 
        },
      }}
    >
      {drawer}
    </Drawer>
  );
};

export default Sidebar;