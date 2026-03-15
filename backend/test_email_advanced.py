#!/usr/bin/env python3
import os
import smtplib
from email.message import EmailMessage

def test_email_sendgrid():
    """Función para probar el envío de correos usando SendGrid"""
    print("Probando configuración de correo con SendGrid...")
    
    # Configuración SendGrid
    smtp_host = "smtp.sendgrid.net"
    smtp_port = 587
    smtp_user = "apikey"  # SendGrid usa 'apikey' como username
    smtp_pass = os.getenv('SENDGRID_API_KEY')  # Tu API key de SendGrid
    email_from = os.getenv('EMAIL_FROM', 'perrillo1981@gmail.com')
    
    print(f"SMTP_HOST: {smtp_host}")
    print(f"SMTP_PORT: {smtp_port}")
    print(f"SMTP_USER: {smtp_user}")
    print(f"EMAIL_FROM: {email_from}")
    print(f"SENDGRID_API_KEY configurado: {bool(smtp_pass)}")
    
    if not smtp_pass:
        print("❌ Error: SENDGRID_API_KEY no configurado")
        print("Configura tu API key de SendGrid en las variables de entorno")
        return False
    
    # Correo de prueba
    email_to = email_from  # Enviar a ti mismo
    
    try:
        print("Creando mensaje...")
        msg = EmailMessage()
        msg['Subject'] = 'Prueba de correo desde Railway (SendGrid)'
        msg['From'] = email_from
        msg['To'] = email_to
        msg.set_content('Este es un correo de prueba usando SendGrid desde Railway.')
        
        print(f"Conectando a {smtp_host}:{smtp_port}...")
        
        smtp = smtplib.SMTP(smtp_host, smtp_port, timeout=30)
        smtp.starttls()
        print("Iniciando sesión...")
        smtp.login(smtp_user, smtp_pass)
        print("Enviando mensaje...")
        smtp.send_message(msg)
        smtp.quit()
        
        print(f"✅ Correo enviado exitosamente a {email_to}")
        return True
        
    except Exception as e:
        print(f"❌ Error enviando correo: {e}")
        return False

def test_email_gmail_alt():
    """Función alternativa para Gmail con diferentes configuraciones"""
    print("Probando configuración alternativa de Gmail...")
    
    # Diferentes configuraciones para probar
    configs = [
        {"host": "smtp.gmail.com", "port": 465, "ssl": True},
        {"host": "smtp.gmail.com", "port": 587, "ssl": False},
        {"host": "smtp.gmail.com", "port": 25, "ssl": False},
    ]
    
    smtp_user = os.getenv('SMTP_USER', 'perrillo1981@gmail.com')
    smtp_pass = os.getenv('SMTP_PASS', 'qiuj fsca izzl hcfy')
    email_from = os.getenv('EMAIL_FROM', smtp_user)
    email_to = smtp_user
    
    for i, config in enumerate(configs, 1):
        print(f"\n--- Prueba {i}: {config['host']}:{config['port']} (SSL={config['ssl']}) ---")
        
        try:
            msg = EmailMessage()
            msg['Subject'] = f'Prueba Gmail {i} - Railway'
            msg['From'] = email_from
            msg['To'] = email_to
            msg.set_content(f'Prueba {i} usando {config["host"]}:{config["port"]} con SSL={config["ssl"]}')
            
            print(f"Conectando a {config['host']}:{config['port']}...")
            
            if config['ssl']:
                smtp = smtplib.SMTP_SSL(config['host'], config['port'], timeout=30)
            else:
                smtp = smtplib.SMTP(config['host'], config['port'], timeout=30)
                if config['port'] in [587, 25]:
                    smtp.starttls()
            
            print("Iniciando sesión...")
            smtp.login(smtp_user, smtp_pass)
            print("Enviando mensaje...")
            smtp.send_message(msg)
            smtp.quit()
            
            print(f"✅ ¡Éxito! Configuración que funciona: {config}")
            return config
            
        except Exception as e:
            print(f"❌ Error con {config}: {e}")
            continue
    
    print("❌ Ninguna configuración de Gmail funcionó")
    return None

if __name__ == "__main__":
    print("=== PRUEBAS DE CORREO PARA RAILWAY ===\n")
    
    # Configurar variables localmente para pruebas
    if not os.getenv('SMTP_HOST'):
        os.environ['SMTP_USER'] = 'perrillo1981@gmail.com'
        os.environ['SMTP_PASS'] = 'qiuj fsca izzl hcfy'
        os.environ['EMAIL_FROM'] = 'perrillo1981@gmail.com'
    
    # Prueba 1: Gmail con diferentes configuraciones
    print("1. Probando Gmail con diferentes configuraciones...")
    working_config = test_email_gmail_alt()
    
    # Prueba 2: SendGrid (si tienes API key)
    print("\n2. Probando SendGrid...")
    sendgrid_success = test_email_sendgrid()
    
    # Resumen
    print("\n=== RESUMEN ===")
    if working_config:
        print(f"✅ Gmail funciona con: {working_config}")
    if sendgrid_success:
        print("✅ SendGrid funciona")
    
    if not working_config and not sendgrid_success:
        print("❌ Ninguna configuración funcionó")
        print("\nRecomendaciones:")
        print("1. Usar SendGrid (Railway lo permite)")
        print("2. Contactar soporte de Railway sobre SMTP")
        print("3. Usar un servicio de correo diferente (Mailgun, etc.)")