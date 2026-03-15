import React from 'react';
import { useAuth } from '../context/AuthContext';
import ChangePasswordModal from './ChangePasswordModal';

const PasswordChangeWrapper = ({ children }) => {
  const { user, needsPasswordChange, setNeedsPasswordChange } = useAuth();

  const handlePasswordChangeSuccess = () => {
    setNeedsPasswordChange(false);
    alert('✅ Contraseña cambiada exitosamente. Ahora puedes acceder al sistema.');
  };

  return (
    <>
      {children}
      <ChangePasswordModal
        show={needsPasswordChange && user}
        onHide={() => {}} // No permitir cerrar el modal
        user={user}
        onSuccess={handlePasswordChangeSuccess}
      />
    </>
  );
};

export default PasswordChangeWrapper;