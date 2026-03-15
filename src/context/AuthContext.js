import React, { createContext, useContext, useReducer, useEffect, useCallback } from 'react';
import { authService } from '../services/authService';

// Estado inicial
const initialState = {
  user: null,
  isLoading: true,
  isAuthenticated: false,
  error: null,
  needsPasswordChange: false,
};

// Tipos de acciones
const AUTH_ACTIONS = {
  LOGIN_START: 'LOGIN_START',
  LOGIN_SUCCESS: 'LOGIN_SUCCESS',
  LOGIN_FAILURE: 'LOGIN_FAILURE',
  LOGOUT: 'LOGOUT',
  SET_LOADING: 'SET_LOADING',
  CLEAR_ERROR: 'CLEAR_ERROR',
  SET_NEEDS_PASSWORD_CHANGE: 'SET_NEEDS_PASSWORD_CHANGE',
};

// Reducer
const authReducer = (state, action) => {
  switch (action.type) {
    case AUTH_ACTIONS.LOGIN_START:
      return {
        ...state,
        isLoading: true,
        error: null,
      };
    case AUTH_ACTIONS.LOGIN_SUCCESS:
      return {
        ...state,
        user: action.payload,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      };
    case AUTH_ACTIONS.LOGIN_FAILURE:
      return {
        ...state,
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: action.payload,
      };
    case AUTH_ACTIONS.LOGOUT:
      return {
        ...state,
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      };
    case AUTH_ACTIONS.SET_LOADING:
      return {
        ...state,
        isLoading: action.payload,
      };
    case AUTH_ACTIONS.CLEAR_ERROR:
      return {
        ...state,
        error: null,
      };
    case AUTH_ACTIONS.SET_NEEDS_PASSWORD_CHANGE:
      return {
        ...state,
        needsPasswordChange: action.payload,
      };
    default:
      return state;
  }
};

// Crear contextos
const AuthContext = createContext();

// Hook personalizado para usar el contexto de auth
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth debe ser usado dentro de un AuthProvider');
  }
  return context;
};

// Provider del contexto
export const AuthProvider = ({ children }) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  // Verificar si hay un usuario logueado al cargar la app
  useEffect(() => {
    const checkAuth = () => {
      const user = authService.getCurrentUser();
      const isAuthenticated = authService.isAuthenticated();

      if (isAuthenticated && user) {
        dispatch({
          type: AUTH_ACTIONS.LOGIN_SUCCESS,
          payload: user,
        });
      } else {
        dispatch({ type: AUTH_ACTIONS.SET_LOADING, payload: false });
      }
    };

    checkAuth();
  }, []);

  // Función para login
  const login = useCallback(async (correo, contraseña) => {
    try {
      dispatch({ type: AUTH_ACTIONS.LOGIN_START });
      
      const data = await authService.login(correo, contraseña);
      
      dispatch({
        type: AUTH_ACTIONS.LOGIN_SUCCESS,
        payload: data.usuario,
      });

      // Verificar si usa contraseña por defecto
      if (contraseña === 'cecytem@1234') {
        dispatch({
          type: AUTH_ACTIONS.SET_NEEDS_PASSWORD_CHANGE,
          payload: true,
        });
      }

      return { success: true, data };
    } catch (error) {
      dispatch({
        type: AUTH_ACTIONS.LOGIN_FAILURE,
        payload: error.message || 'Error en el login',
      });
      return { success: false, error: error.message || 'Error en el login' };
    }
  }, []);

  // Función para logout
  const logout = useCallback(() => {
    authService.logout();
    dispatch({ type: AUTH_ACTIONS.LOGOUT });
  }, []);

  // Función para limpiar errores
  const clearError = useCallback(() => {
    dispatch({ type: AUTH_ACTIONS.CLEAR_ERROR });
  }, []);

  // Función para establecer necesidad de cambio de contraseña
  const setNeedsPasswordChange = useCallback((needs) => {
    dispatch({ 
      type: AUTH_ACTIONS.SET_NEEDS_PASSWORD_CHANGE, 
      payload: needs 
    });
  }, []);

  const value = {
    ...state,
    login,
    logout,
    clearError,
    setNeedsPasswordChange,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};