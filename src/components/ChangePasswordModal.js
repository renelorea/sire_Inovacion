import React, { useState } from 'react';
import { Modal, Form, Button, Alert } from 'react-bootstrap';
import { usuariosService } from '../services/usuariosService';

const ChangePasswordModal = ({ show, onHide, user, onSuccess }) => {
  const [formData, setFormData] = useState({
    contrasena_actual: '',
    nueva_contrasena: '',
    confirmar_contrasena: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    setError(null);
  };

  const validatePassword = (password) => {
    const minLength = 6;
    
    if (password.length < minLength) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (password === 'cecytem@1234') {
      return 'No puedes usar la contraseña predeterminada';
    }
    return null;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    console.log('Usuario completo:', user);
    console.log('Propiedades del usuario:', Object.keys(user || {}));
    console.log('Email del usuario (email):', user?.email);
    
    // Usar el campo email que ahora viene del backend
    const userEmail = user?.email;
    console.log('Email final a usar:', userEmail);
    
    if (!userEmail) {
      setError('Error: No se pudo obtener el correo del usuario');
      return;
    }
    
    if (formData.nueva_contrasena !== formData.confirmar_contrasena) {
      setError('Las contraseñas no coinciden');
      return;
    }

    const passwordError = validatePassword(formData.nueva_contrasena);
    if (passwordError) {
      setError(passwordError);
      return;
    }

    setLoading(true);
    try {
      await usuariosService.changePassword(userEmail, {
        contrasena_actual: formData.contrasena_actual,
        nueva_contrasena: formData.nueva_contrasena
      });
      
      onSuccess();
      handleClose();
    } catch (error) {
      console.error('Error completo:', error);
      setError(error.message || 'Error al cambiar la contraseña');
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    setFormData({
      contrasena_actual: '',
      nueva_contrasena: '',
      confirmar_contrasena: ''
    });
    setError(null);
    onHide();
  };

  return (
    <Modal 
      show={show} 
      onHide={handleClose} 
      backdrop="static" 
      keyboard={false}
      centered
    >
      <Modal.Header>
        <Modal.Title style={{color: 'var(--primary-green)'}}>
          🔐 Cambiar Contraseña
        </Modal.Title>
      </Modal.Header>
      
      <Form onSubmit={handleSubmit}>
        <Modal.Body>
          <div className="alert alert-green mb-3">
            <strong>🔔 Importante:</strong> Debes cambiar la contraseña predeterminada por razones de seguridad.
          </div>

          {error && (
            <Alert variant="danger" className="mb-3">
              <span className="me-2">❌</span>
              {error}
            </Alert>
          )}

          <div className="mb-3">
            <Form.Label style={{color: 'var(--secondary-gray)', fontWeight: '600'}}>
              🔒 Contraseña Actual
            </Form.Label>
            <Form.Control
              type="password"
              name="contrasena_actual"
              value={formData.contrasena_actual}
              onChange={handleChange}
              placeholder="cecytem@1234"
              required
            />
          </div>

          <div className="mb-3">
            <Form.Label style={{color: 'var(--secondary-gray)', fontWeight: '600'}}>
              🆕 Nueva Contraseña
            </Form.Label>
            <Form.Control
              type="password"
              name="nueva_contrasena"
              value={formData.nueva_contrasena}
              onChange={handleChange}
              placeholder="••••••••"
              required
            />
            <small className="text-muted">
              Mínimo 6 caracteres y no puede ser la contraseña predeterminada
            </small>
          </div>

          <div className="mb-3">
            <Form.Label style={{color: 'var(--secondary-gray)', fontWeight: '600'}}>
              ✅ Confirmar Nueva Contraseña
            </Form.Label>
            <Form.Control
              type="password"
              name="confirmar_contrasena"
              value={formData.confirmar_contrasena}
              onChange={handleChange}
              placeholder="••••••••"
              required
            />
          </div>
        </Modal.Body>

        <Modal.Footer>
          <Button 
            className="btn-green" 
            type="submit" 
            disabled={loading}
            style={{
              fontWeight: '600',
              minWidth: '120px'
            }}
          >
            {loading ? '🔄 Cambiando...' : '🔐 Cambiar Contraseña'}
          </Button>
        </Modal.Footer>
      </Form>
    </Modal>
  );
};

export default ChangePasswordModal;