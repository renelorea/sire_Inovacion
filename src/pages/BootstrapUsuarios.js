import React, { useState, useEffect } from 'react';
import { Container, Row, Col, Card, Button, Table, Modal, Form, Alert, Spinner } from 'react-bootstrap';
import { usuariosService } from '../services/usuariosService';

const BootstrapUsuarios = () => {
  const [usuarios, setUsuarios] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showModal, setShowModal] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [formData, setFormData] = useState({
    nombres: '',
    apellido_paterno: '',
    apellido_materno: '',
    email: '',
    rol: 'usuario',
  });
  const [filters, setFilters] = useState({
    id: '',
    nombre: '',
    email: '',
    rol: '',
    estado: '',
  });
  const [filteredUsuarios, setFilteredUsuarios] = useState([]);

  const roles = [
    { value: 'admin', label: 'Administrador' },
    { value: 'profesor', label: 'Profesor' },
    { value: 'usuario', label: 'Usuario' }
  ];

  useEffect(() => {
    loadUsuarios();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [usuarios, filters]);

  const applyFilters = () => {
    let filtered = usuarios;

    Object.keys(filters).forEach(key => {
      if (filters[key]) {
        filtered = filtered.filter(usuario => {
          switch(key) {
            case 'id':
              return usuario.id_usuario?.toString().includes(filters[key]);
            case 'nombre':
              const fullName = `${usuario.nombres} ${usuario.apellido_paterno} ${usuario.apellido_materno}`.toLowerCase();
              return fullName.includes(filters[key].toLowerCase());
            case 'email':
              return usuario.email?.toLowerCase().includes(filters[key].toLowerCase());
            case 'rol':
              return usuario.rol?.toLowerCase().includes(filters[key].toLowerCase());
            case 'estado':
              const estado = usuario.activo ? 'activo' : 'inactivo';
              return estado.includes(filters[key].toLowerCase());
            default:
              return true;
          }
        });
      }
    });

    setFilteredUsuarios(filtered);
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
      nombre: '',
      email: '',
      rol: '',
      estado: '',
    });
  };

  const loadUsuarios = async () => {
    try {
      setLoading(true);
      const data = await usuariosService.getUsuarios();
      setUsuarios(data.usuarios || data);
      setError(null);
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleShowModal = (usuario = null) => {
    if (usuario) {
      setEditingUser(usuario);
      setFormData({
        nombres: usuario.nombres || '',
        apellido_paterno: usuario.apellido_paterno || '',
        apellido_materno: usuario.apellido_materno || '',
        email: usuario.email || '',
        rol: usuario.rol || 'usuario',
      });
    } else {
      setEditingUser(null);
      setFormData({
        nombres: '',
        apellido_paterno: '',
        apellido_materno: '',
        email: '',
        rol: 'usuario',
      });
    }
    setShowModal(true);
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setEditingUser(null);
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
      if (editingUser) {
        await usuariosService.updateUsuario(editingUser.id_usuario, formData);
      } else {
        await usuariosService.createUsuario(formData);
      }
      
      handleCloseModal();
      loadUsuarios();
    } catch (error) {
      setError(error.message);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('¿Está seguro de que desea eliminar este usuario?')) {
      try {
        await usuariosService.deleteUsuario(id);
        loadUsuarios();
      } catch (error) {
        setError(error.message);
      }
    }
  };

  const handleResetPassword = async (id, nombre) => {
    if (window.confirm(`¿Está seguro de que desea restablecer la contraseña de ${nombre}?\nLa nueva contraseña será: cecytem@1234`)) {
      try {
        const result = await usuariosService.resetPassword(id);
        alert(`Contraseña restablecida exitosamente.\nNueva contraseña: ${result.nueva_contrasena || 'cecytem@1234'}`);
        loadUsuarios();
      } catch (error) {
        setError(error.message);
      }
    }
  };

  const getRoleBadge = (rol) => {
    const variants = {
      admin: 'badge-green',
      profesor: 'badge-gray', 
      usuario: 'badge-gray'
    };
    return variants[rol] || 'badge-gray';
  };

  if (loading) {
    return (
      <Container className="text-center py-5">
        <Spinner animation="border" style={{color: 'var(--primary-green)'}} />
        <p className="mt-2">Cargando usuarios...</p>
      </Container>
    );
  }

  return (
    <Container>
      <Row className="mb-4">
        <Col>
          <div className="d-flex justify-content-between align-items-center">
            <div>
              <h2 className="mb-1" style={{color: 'var(--primary-green)'}}>👥 Gestión de Usuarios</h2>
              <p className="text-muted mb-0">Administra los usuarios del sistema</p>
            </div>
            <Button 
              className="btn-green"
              onClick={() => handleShowModal()}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                fontWeight: '600'
              }}
            >
              ➕ Nuevo Usuario
            </Button>
          </div>
        </Col>
      </Row>

      {error && (
        <Row className="mb-3">
          <Col>
            <Alert variant="danger">
              ❌ {error}
            </Alert>
          </Col>
        </Row>
      )}

      <Row>
        <Col>
          <Card className="card-green">
            <Card.Header style={{backgroundColor: 'var(--light-gray)', borderBottom: '1px solid var(--primary-green)'}}>
              <h5 className="mb-0" style={{color: 'var(--primary-green)'}}>📋 Lista de Usuarios ({usuarios.length})</h5>
            </Card.Header>
            <Card.Body className="p-0">
              <div className="table-responsive">
                <Table className="table-green mb-0" hover>
                  <thead className="table-light">
                    <tr>
                      <th>
                        <div>
                          <div className="fw-bold mb-1">ID</div>
                          <Form.Control
                            size="sm"
                            placeholder="Filtrar..."
                            value={filters.id}
                            onChange={(e) => handleFilterChange('id', e.target.value)}
                            style={{ minWidth: '80px' }}
                          />
                        </div>
                      </th>
                      <th>
                        <div>
                          <div className="fw-bold mb-1">Nombre Completo</div>
                          <Form.Control
                            size="sm"
                            placeholder="Filtrar..."
                            value={filters.nombre}
                            onChange={(e) => handleFilterChange('nombre', e.target.value)}
                            style={{ minWidth: '150px' }}
                          />
                        </div>
                      </th>
                      <th>
                        <div>
                          <div className="fw-bold mb-1">Email</div>
                          <Form.Control
                            size="sm"
                            placeholder="Filtrar..."
                            value={filters.email}
                            onChange={(e) => handleFilterChange('email', e.target.value)}
                            style={{ minWidth: '150px' }}
                          />
                        </div>
                      </th>
                      <th>
                        <div>
                          <div className="fw-bold mb-1">Rol</div>
                          <Form.Control
                            size="sm"
                            placeholder="Filtrar..."
                            value={filters.rol}
                            onChange={(e) => handleFilterChange('rol', e.target.value)}
                            style={{ minWidth: '100px' }}
                          />
                        </div>
                      </th>
                      <th>
                        <div>
                          <div className="fw-bold mb-1">Estado</div>
                          <Form.Control
                            size="sm"
                            placeholder="Filtrar..."
                            value={filters.estado}
                            onChange={(e) => handleFilterChange('estado', e.target.value)}
                            style={{ minWidth: '100px' }}
                          />
                        </div>
                      </th>
                      <th className="text-end">
                        <div>
                          <div className="fw-bold mb-1">Acciones</div>
                          <Button size="sm" variant="outline-secondary" onClick={clearFilters}>
                            Limpiar
                          </Button>
                        </div>
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredUsuarios.length === 0 ? (
                      <tr>
                        <td colSpan="6" className="text-center py-4 text-muted">
                          📭 No hay usuarios que coincidan con los filtros
                        </td>
                      </tr>
                    ) : (
                      filteredUsuarios.map((usuario) => (
                        <tr key={usuario.id_usuario}>
                          <td>
                            <code>#{usuario.id_usuario}</code>
                          </td>
                          <td>
                            <strong>{usuario.nombres}</strong>
                            <br />
                            <small className="text-muted">
                              {usuario.apellido_paterno} {usuario.apellido_materno}
                            </small>
                          </td>
                          <td>
                            <span className="d-flex align-items-center gap-1">
                              📧 {usuario.email}
                            </span>
                          </td>
                          <td>
                            <span className={`badge ${getRoleBadge(usuario.rol)}`}>
                              {usuario.rol}
                            </span>
                          </td>
                          <td>
                            <span className={`badge ${usuario.activo ? 'badge-green' : 'badge-gray'}`}>
                              {usuario.activo ? '✅ Activo' : '❌ Inactivo'}
                            </span>
                          </td>
                          <td className="text-end">
                            <div className="btn-group btn-group-sm" role="group">
                              <Button
                                className="btn-green-soft"
                                size="sm"
                                onClick={() => handleShowModal(usuario)}
                                style={{fontSize: '12px', padding: '4px 8px'}}
                                title="Editar usuario"
                              >
                                ✏️
                              </Button>
                              <Button
                                className="btn-green"
                                size="sm"
                                onClick={() => handleResetPassword(usuario.id_usuario, usuario.nombres)}
                                style={{fontSize: '12px', padding: '4px 8px'}}
                                title="Restablecer contraseña"
                              >
                                🔑
                              </Button>
                              <Button
                                className="btn-gray"
                                size="sm"
                                onClick={() => handleDelete(usuario.id_usuario)}
                                style={{fontSize: '12px', padding: '4px 8px'}}
                                title="Eliminar usuario"
                              >
                                🗑️
                              </Button>
                            </div>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </Table>
              </div>
            </Card.Body>
          </Card>
        </Col>
      </Row>

      {/* Modal para crear/editar usuario */}
      <Modal show={showModal} onHide={handleCloseModal} size="lg">
        <Modal.Header closeButton>
          <Modal.Title>
            {editingUser ? '✏️ Editar Usuario' : '➕ Nuevo Usuario'}
          </Modal.Title>
        </Modal.Header>
        <Form onSubmit={handleSubmit}>
          <Modal.Body>
            <Row>
              <Col md={6}>
                <div className="mb-3">
                  <Form.Label>Nombres *</Form.Label>
                  <Form.Control
                    type="text"
                    name="nombres"
                    value={formData.nombres}
                    onChange={handleChange}
                    required
                    placeholder="Juan"
                  />
                </div>
              </Col>
              <Col md={6}>
                <div className="mb-3">
                  <Form.Label>Apellido Paterno *</Form.Label>
                  <Form.Control
                    type="text"
                    name="apellido_paterno"
                    value={formData.apellido_paterno}
                    onChange={handleChange}
                    required
                    placeholder="Pérez"
                  />
                </div>
              </Col>
              <Col md={6}>
                <div className="mb-3">
                  <Form.Label>Apellido Materno</Form.Label>
                  <Form.Control
                    type="text"
                    name="apellido_materno"
                    value={formData.apellido_materno}
                    onChange={handleChange}
                    placeholder="López"
                  />
                </div>
              </Col>
              <Col md={6}>
                <div className="mb-3">
                  <Form.Label>Email *</Form.Label>
                  <Form.Control
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    required
                    placeholder="usuario@ejemplo.com"
                  />
                </div>
              </Col>
              <Col md={6}>
                <div className="mb-3">
                  <Form.Label>Rol *</Form.Label>
                  <Form.Select
                    name="rol"
                    value={formData.rol}
                    onChange={handleChange}
                    required
                  >
                    {roles.map((option) => (
                      <option key={option.value} value={option.value}>
                        {option.label}
                      </option>
                    ))}
                  </Form.Select>
                </div>
              </Col>
              {!editingUser && (
                <Col md={12}>
                  <div className="alert alert-green mb-3">
                    📝 <strong>Nota:</strong> La contraseña predeterminada será: <code>cecytem@1234</code>
                    <br />El usuario podrá cambiarla después del primer inicio de sesión.
                  </div>
                </Col>
              )}
            </Row>
          </Modal.Body>
          <Modal.Footer>
            <Button className="btn-gray" onClick={handleCloseModal}>
              Cancelar
            </Button>
            <Button className="btn-green" type="submit">
              {editingUser ? 'Actualizar' : 'Crear'} Usuario
            </Button>
          </Modal.Footer>
        </Form>
      </Modal>
    </Container>
  );
};

export default BootstrapUsuarios;