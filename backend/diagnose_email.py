#!/usr/bin/env python3
"""Script simple para diagnosticar problemas de correo"""

import os
import sys

# Configurar variables de entorno para pruebas
os.environ['SMTP_USER'] = 'perrillo1981@gmail.com'
os.environ['SMTP_PASS'] = 'qiuj fsca izzl hcfy'
os.environ['EMAIL_FROM'] = 'perrillo1981@gmail.com'

# Agregar el path del proyecto
sys.path.append('/Users/reneloreaayala/Documents/Maestria/Segundo Semestre/Ingenieria de Software/Proyecto/backend')

from services.email_service import email_service
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    print("=== DIAGNÓSTICO DE CORREO ===\n")
    
    print("1. Información de configuración:")
    config = email_service.get_configuration_info()
    for provider_name, provider_config in config['providers'].items():
        print(f"  {provider_name}:")
        print(f"    Host: {provider_config['host']}:{provider_config['port']}")
        print(f"    Usuario: {provider_config['user']}")
        print(f"    Contraseña: {'✅ Configurada' if provider_config['has_password'] else '❌ Faltante'}")
        print(f"    SSL: {provider_config['use_ssl']}, TLS: {provider_config['use_tls']}")
    
    print(f"\n  Email From: {config['email_from']}\n")
    
    print("2. Probando conexiones:")
    test_results = email_service.test_connection()
    for provider, result in test_results.items():
        print(f"  {provider}: {result}")
    
    print("\n3. Intentando enviar correo de prueba...")
    success, provider_used, error_msg = email_service.send_email(
        to_email='perrillo1981@gmail.com',
        subject='Diagnóstico - Prueba de correo',
        content='Este es un correo de diagnóstico para identificar problemas.'
    )
    
    if success:
        print(f"✅ ¡Éxito! Correo enviado usando {provider_used}")
    else:
        print(f"❌ Error: {error_msg}")
        
        # Sugerencias
        print("\n=== SUGERENCIAS ===")
        if "Sin credenciales" in error_msg:
            print("• Verifica que las variables SMTP_USER, SMTP_PASS estén configuradas")
        if "Network is unreachable" in error_msg:
            print("• Railway está bloqueando conexiones SMTP")
            print("• Prueba con SendGrid: registrarte en sendgrid.com y configurar SENDGRID_API_KEY")
        if "Authentication failed" in error_msg:
            print("• Verifica la contraseña de aplicación de Gmail")
            print("• Asegúrate de tener habilitada la verificación en 2 pasos")

if __name__ == "__main__":
    main()