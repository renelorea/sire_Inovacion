import React from 'react';
import { Container, Navbar, Nav, NavDropdown } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';

const BootstrapLayout = ({ children }) => {
  const { logout, user } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="min-vh-100 bg-light">
      <Navbar className="navbar-green" variant="dark" expand="lg">
        <Container>
          <Navbar.Brand className="fw-bold">
            🌿 Sistema de Incidencias Escolares
          </Navbar.Brand>
          <Navbar.Toggle aria-controls="basic-navbar-nav" />
          <Navbar.Collapse id="basic-navbar-nav">
            <Nav className="me-auto">
              <LinkContainer to="/dashboard">
                <Nav.Link>🏠 Dashboard</Nav.Link>
              </LinkContainer>
              <LinkContainer to="/usuarios">
                <Nav.Link>👥 Usuarios</Nav.Link>
              </LinkContainer>
              <LinkContainer to="/alumnos">
                <Nav.Link>🎓 Alumnos</Nav.Link>
              </LinkContainer>
              <LinkContainer to="/grupos">
                <Nav.Link>👥 Grupos</Nav.Link>
              </LinkContainer>
              <NavDropdown title="📊 Reportes" id="reportes-dropdown">
                <LinkContainer to="/tipos-reporte">
                  <NavDropdown.Item>⚙️ Tipos de Reporte</NavDropdown.Item>
                </LinkContainer>
                <LinkContainer to="/reportes">
                  <NavDropdown.Item>📋 Gestión de Reportes</NavDropdown.Item>
                </LinkContainer>
              </NavDropdown>
              <NavDropdown title="🔧 Sistema" id="sistema-dropdown">
                <LinkContainer to="/diagnostics">
                  <NavDropdown.Item>🔍 Diagnóstico</NavDropdown.Item>
                </LinkContainer>
                <LinkContainer to="/error-check">
                  <NavDropdown.Item>❗ Verificar Errores</NavDropdown.Item>
                </LinkContainer>
              </NavDropdown>
            </Nav>
            <Nav>
              <NavDropdown title={`👤 ${user?.nombres || 'Usuario'}`} id="user-dropdown" align="end">
                <NavDropdown.ItemText>
                  <small className="text-muted">
                    {user?.email || 'usuario@sistema.com'}
                  </small>
                </NavDropdown.ItemText>
                <NavDropdown.Divider />
                <NavDropdown.Item onClick={handleLogout}>
                  🚪 Cerrar Sesión
                </NavDropdown.Item>
              </NavDropdown>
            </Nav>
          </Navbar.Collapse>
        </Container>
      </Navbar>

      <Container fluid>
        <div className="row">
          <div className="col-12">
            {children}
          </div>
        </div>
      </Container>
    </div>
  );
};

export default BootstrapLayout;