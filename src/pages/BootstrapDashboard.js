import React from 'react';
import { Container, Row, Col, Card, Button } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';

const BootstrapDashboard = () => {
  const navigate = useNavigate();

  const dashboardItems = [
    {
      title: 'Usuarios',
      description: 'Gestión de usuarios del sistema',
      icon: '👥',
      path: '/usuarios',
      color: 'primary',
      stats: 'Administrar cuentas'
    },
    {
      title: 'Alumnos',
      description: 'Administración de estudiantes',
      icon: '🎓',
      path: '/alumnos',
      color: 'success',
      stats: 'Gestionar alumnos'
    },
    {
      title: 'Grupos',
      description: 'Manejo de grupos escolares',
      icon: '👥',
      path: '/grupos',
      color: 'info',
      stats: 'Organizar grupos'
    },
    {
      title: 'Reportes',
      description: 'Gestión de incidencias',
      icon: '📋',
      path: '/reportes',
      color: 'warning',
      stats: 'Ver incidencias'
    }
  ];

  const systemItems = [
    {
      title: 'Tipos de Reporte',
      description: 'Configuración de categorías',
      icon: '⚙️',
      path: '/tipos-reporte',
      color: 'secondary'
    },
    {
      title: 'Diagnóstico',
      description: 'Verificar funcionamiento',
      icon: '🔍',
      path: '/diagnostics',
      color: 'dark'
    }
  ];

  return (
    <div className="dashboard-background">
      <div className="dashboard-content">
        <Container>
          <Row className="mb-4">
            <Col>
              <div className="bg-gradient-green text-white p-4 rounded shadow-sm">
                <h1 className="display-5 mb-2">
                  CECYTEM CUAUTITLAN
                </h1>
                <p className="lead mb-0">
                  Bienvenido al Sistema de Gestión de Incidencias Escolares
                </p>
              </div>
            </Col>
          </Row>

      <Row className="mb-4">
        <Col>
          <h3 className="mb-3" style={{color: 'var(--primary-green)'}}>📈 Módulos Principales</h3>
        </Col>
      </Row>

      <Row className="g-4 mb-5">
        {dashboardItems.map((item, index) => (
          <Col key={index} xs={12} sm={6} lg={3}>
            <Card className={`h-100 shadow-sm border-0 dashboard-card ${index % 2 === 0 ? 'card-green' : 'card-gray'}`}>
              <Card.Body className="text-center p-4">
                <div className={`mb-3 card-icon ${index % 2 === 0 ? 'card-icon-green' : 'card-icon-gray'}`}>
                  {item.icon}
                </div>
                <Card.Title className="h5 mb-2">
                  {item.title}
                </Card.Title>
                <Card.Text className="text-muted mb-3">
                  {item.description}
                </Card.Text>
                <div className="mb-3">
                  <small className={`badge ${index % 2 === 0 ? 'badge-green' : 'badge-gray'} px-3 py-2`}>
                    {item.stats}
                  </small>
                </div>
                <Button 
                  className={index % 2 === 0 ? 'btn-green' : 'btn-gray'}
                  onClick={() => navigate(item.path)}
                >
                  Acceder
                </Button>
              </Card.Body>
            </Card>
          </Col>
        ))}
      </Row>

      <Row className="mb-4">
        <Col>
          <h3 className="mb-3" style={{color: 'var(--secondary-gray)'}}>🔧 Herramientas del Sistema</h3>
        </Col>
      </Row>

      <Row className="g-4 mb-5">
        <Col md={8}>
          <Card className="shadow-sm border-0">
            <Card.Body className="p-4">
              <h5 className="card-title mb-3">
                📈 Resumen de Actividad
              </h5>
              <p className="text-muted mb-3">
                Aquí se mostrarían las estadísticas principales del sistema, 
                gráficos de actividad reciente y métricas importantes.
              </p>
              <div className="row text-center">
                <div className="col-6 col-md-3">
                  <div className="border-end">
                    <h4 className="mb-1" style={{color: 'var(--primary-green)'}}>150+</h4>
                    <small className="text-muted">Usuarios</small>
                  </div>
                </div>
                <div className="col-6 col-md-3">
                  <div className="border-end">
                    <h4 className="mb-1" style={{color: 'var(--secondary-gray)'}}>500+</h4>
                    <small className="text-muted">Alumnos</small>
                  </div>
                </div>
                <div className="col-6 col-md-3">
                  <div className="border-end">
                    <h4 className="mb-1" style={{color: 'var(--primary-green)'}}>25</h4>
                    <small className="text-muted">Grupos</small>
                  </div>
                </div>
                <div className="col-6 col-md-3">
                  <h4 className="mb-1" style={{color: 'var(--secondary-gray)'}}>89</h4>
                  <small className="text-muted">Reportes</small>
                </div>
              </div>
            </Card.Body>
          </Card>
        </Col>
        
        <Col md={4}>
          <Card className="shadow-sm border-0 mb-3">
            <Card.Body className="p-4">
              <h5 className="card-title mb-3">
                🚀 Acciones Rápidas
              </h5>
              <div className="d-grid gap-2">
                {systemItems.map((item, index) => (
                  <Button 
                    key={index}
                    variant={`outline-${item.color}`}
                    onClick={() => navigate(item.path)}
                    className="text-start"
                  >
                    <span className="me-2">{item.icon}</span>
                    {item.title}
                  </Button>
                ))}
              </div>
            </Card.Body>
          </Card>
        </Col>
      </Row>

      <Row>
        <Col>
          <div className="bg-light p-4 rounded text-center">
            <h6 className="text-muted mb-2">Sistema de Incidencias Escolares v1.0</h6>
            <small className="text-muted">
              Desarrollado con React + Bootstrap • Responsive Design
            </small>
          </div>
        </Col>
      </Row>

      <style>
        {`
          .hover-shadow {
            transition: all 0.3s ease;
          }
          .hover-shadow:hover {
            transform: translateY(-2px);
            box-shadow: 0 .5rem 1rem rgba(0,0,0,.15) !important;
          }
        `}
      </style>
        </Container>
      </div>
    </div>
  );
};

export default BootstrapDashboard;