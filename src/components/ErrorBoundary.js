import React from 'react';
import { Alert, AlertTitle, Button, Box } from '@mui/material';
import { Refresh } from '@mui/icons-material';

const ErrorBoundary = ({ error, onRetry }) => {
  if (error) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert 
          severity="error" 
          action={
            onRetry && (
              <Button
                color="inherit"
                size="small"
                startIcon={<Refresh />}
                onClick={onRetry}
              >
                Reintentar
              </Button>
            )
          }
        >
          <AlertTitle>Error</AlertTitle>
          {error.message || 'Ha ocurrido un error inesperado'}
        </Alert>
      </Box>
    );
  }
  return null;
};

export default ErrorBoundary;