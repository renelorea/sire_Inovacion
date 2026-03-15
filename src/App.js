import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import 'bootstrap/dist/css/bootstrap.min.css';
import './styles/theme.css';
import { AuthProvider } from './context/AuthContext';
import PasswordChangeWrapper from './components/PasswordChangeWrapper';
import PrivateRoute from './components/PrivateRoute';
import BootstrapLayout from './components/BootstrapLayout';
import BootstrapLogin from './pages/BootstrapLogin';
import BootstrapDashboard from './pages/BootstrapDashboard';
import BootstrapUsuarios from './pages/BootstrapUsuarios';
import Alumnos from './pages/Alumnos';
import Grupos from './pages/Grupos';
import TiposReporte from './pages/TiposReporte';
import Reportes from './pages/Reportes';
import DiagnosisPage from './pages/DiagnosisPage';
import ErrorCheckPage from './pages/ErrorCheckPage';

function App() {
  return (
    <>
      <AuthProvider>
        <PasswordChangeWrapper>
          <Router>
        <Routes>
          <Route path="/login" element={<BootstrapLogin />} />
          <Route
            path="/"
            element={
              <PrivateRoute>
                <BootstrapLayout>
                  <Navigate to="/dashboard" replace />
                </BootstrapLayout>
              </PrivateRoute>
            }
          />
          <Route
            path="/dashboard"
            element={
              <PrivateRoute>
                <BootstrapLayout>
                  <BootstrapDashboard />
                </BootstrapLayout>
              </PrivateRoute>
            }
          />
          <Route
            path="/usuarios"
            element={
              <PrivateRoute>
                <BootstrapLayout>
                  <BootstrapUsuarios />
                </BootstrapLayout>
              </PrivateRoute>
            }
          />
            <Route
              path="/alumnos"
              element={
                <PrivateRoute>
                  <BootstrapLayout>
                    <Alumnos />
                  </BootstrapLayout>
                </PrivateRoute>
              }
            />
            <Route
              path="/grupos"
              element={
                <PrivateRoute>
                  <BootstrapLayout>
                    <Grupos />
                  </BootstrapLayout>
                </PrivateRoute>
              }
            />
            <Route
              path="/tipos-reporte"
              element={
                <PrivateRoute>
                  <BootstrapLayout>
                    <TiposReporte />
                  </BootstrapLayout>
                </PrivateRoute>
              }
            />
            <Route
              path="/reportes"
              element={
                <PrivateRoute>
                  <BootstrapLayout>
                    <Reportes />
                  </BootstrapLayout>
                </PrivateRoute>
              }
            />
            <Route
              path="/diagnostics"
              element={
                <PrivateRoute>
                  <BootstrapLayout>
                    <DiagnosisPage />
                  </BootstrapLayout>
                </PrivateRoute>
              }
            />
            <Route
              path="/diagnosis"
              element={<DiagnosisPage />}
            />
            <Route
              path="/error-check"
              element={<ErrorCheckPage />}
            />
          </Routes>
        </Router>
        </PasswordChangeWrapper>
      </AuthProvider>
    </>
  );
}

export default App;
