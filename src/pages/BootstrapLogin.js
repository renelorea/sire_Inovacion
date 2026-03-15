import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Card, Form, Button, Alert, Spinner } from 'react-bootstrap';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';

const BootstrapLogin = () => {
  const [formData, setFormData] = useState({
    correo: '',
    contraseña: ''
  });
  const [loading, setLoading] = useState(false);
  const { login, isAuthenticated, error, clearError } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (isAuthenticated) {
      navigate('/dashboard');
    }
  }, [isAuthenticated, navigate]);

  useEffect(() => {
    // Limpiar errores cuando el componente se monta
    clearError();
  }, [clearError]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await login(formData.correo, formData.contraseña);
    } catch (error) {
      console.error('Login error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-vh-100 d-flex align-items-center login-container">
      <Container>
        <Row className="justify-content-center">
          <Col xs={12} sm={8} md={6} lg={4}>
            <div className="text-center mb-4">
              <div className="mb-3">
                <img 
                  src="/images/logo.png" 
                  alt="Logo Sistema de Incidencias" 
                  style={{
                    maxWidth: '120px',
                    height: 'auto',
                    filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.1))'
                  }}
                />
              </div>
              <h2 className="h3 mb-2" style={{color: 'var(--dark-gray)'}}>
                Sistema de Incidencias Escolares
              </h2>
              <p className="text-muted">Inicia sesión para continuar</p>
            </div>

            <Card className="login-card shadow">
              <Card.Body className="p-4">
                {error && (
                  <Alert variant="danger" className="mb-3">
                    <div className="d-flex align-items-center">
                      <span className="me-2">❌</span>
                      {error}
                    </div>
                  </Alert>
                )}

                <Form onSubmit={handleSubmit}>
                  <div className="mb-3">
                    <Form.Label htmlFor="correo" className="form-label" style={{color: 'var(--secondary-gray)', fontWeight: '600'}}>
                      📧 Correo Electrónico
                    </Form.Label>
                    <Form.Control
                      type="email"
                      id="correo"
                      name="correo"
                      value={formData.correo}
                      onChange={handleChange}
                      placeholder="usuario@ejemplo.com"
                      required
                      className="form-control-lg"
                    />
                  </div>

                  <div className="mb-4">
                    <Form.Label htmlFor="contraseña" className="form-label" style={{color: 'var(--secondary-gray)', fontWeight: '600'}}>
                      🔒 Contraseña
                    </Form.Label>
                    <Form.Control
                      type="password"
                      id="contraseña"
                      name="contraseña"
                      value={formData.contraseña}
                      onChange={handleChange}
                      placeholder="••••••••"
                      required
                      className="form-control-lg"
                    />
                  </div>

                  <div className="d-grid">
                    <Button
                      type="submit"
                      className="btn-green"
                      size="lg"
                      disabled={loading}
                      style={{
                        padding: '12px 0',
                        fontWeight: '600',
                        borderRadius: '8px'
                      }}
                    >
                      {loading ? (
                        <>
                          <Spinner
                            as="span"
                            animation="border"
                            size="sm"
                            role="status"
                            className="me-2"
                          />
                          Iniciando sesión...
                        </>
                      ) : (
                        <>
                          🌿 Iniciar Sesión
                        </>
                      )}
                    </Button>
                  </div>
                </Form>

                <div className="text-center mt-3">
                  <small className="text-muted">
                    📝 Si es tu primer acceso, usarás la contraseña predeterminada.<br/>
                    Se te pedirá cambiarla por razones de seguridad.
                  </small>
                </div>
              </Card.Body>
            </Card>

            <div className="text-center mt-4">
              <div className="bg-info bg-opacity-10 p-3 rounded">
                <h6 className="text-info mb-2">
                  🧪 Credenciales de Prueba
                </h6>
                <small className="d-block">
                  <strong>Email:</strong> admin@sistema.com
                </small>
                <small className="d-block">
                  <strong>Contraseña:</strong> 123456
                </small>
              </div>
            </div>
          </Col>
        </Row>
      </Container>
    </div>
  );
};

export default BootstrapLogin;