#!/usr/bin/env python3
import os
import smtplib
from email.message import EmailMessage

def test_email():
    """Función para probar el envío de correos"""
    print("Probando configuración de correo...")
    
    # Leer variables de entorno
    smtp_host = os.getenv('SMTP_HOST')
    smtp_port = int(os.getenv('SMTP_PORT', '587'))
    smtp_user = os.getenv('SMTP_USER')
    smtp_pass = os.getenv('SMTP_PASS')
    email_from = os.getenv('EMAIL_FROM', smtp_user)
    
    print(f"SMTP_HOST: {smtp_host}")
    print(f"SMTP_PORT: {smtp_port}")
    print(f"SMTP_USER: {smtp_user}")
    print(f"EMAIL_FROM: {email_from}")
    print(f"SMTP_PASS configurado: {bool(smtp_pass)}")
    
    if not smtp_host or not smtp_user or not smtp_pass:
        print("❌ Error: Configuración SMTP incompleta")
        return False
    
    # Correo de prueba (cambia esto por tu correo)
    email_to = smtp_user  # Enviar a ti mismo
    
    try:
        print("Creando mensaje...")
        msg = EmailMessage()
        msg['Subject'] = 'Prueba de correo desde Railway'
        msg['From'] = email_from
        msg['To'] = email_to
        msg.set_content('Este es un correo de prueba para verificar la configuración SMTP en Railway.')
        
        print(f"Conectando a {smtp_host}:{smtp_port}...")
        
        if smtp_port == 465:
            smtp = smtplib.SMTP_SSL(smtp_host, smtp_port, timeout=30)
            smtp.login(smtp_user, smtp_pass)
            smtp.send_message(msg)
            smtp.quit()
        else:
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

if __name__ == "__main__":
    # Para usar localmente, configura las variables aquí:
    if not os.getenv('SMTP_HOST'):
        os.environ['SMTP_HOST'] = 'smtp.gmail.com'
        os.environ['SMTP_PORT'] = '465'  # Cambiar a puerto 465
        os.environ['SMTP_USER'] = 'perrillo1981@gmail.com'
        os.environ['SMTP_PASS'] = 'qiuj fsca izzl hcfy'
        os.environ['EMAIL_FROM'] = 'perrillo1981@gmail.com'
    
    test_email()