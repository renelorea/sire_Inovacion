import os
import smtplib
from email.message import EmailMessage
import logging
import urllib.request
import urllib.parse
import json
import base64

logger = logging.getLogger(__name__)

class EmailService:
    """Servicio de correo con múltiples proveedores de respaldo"""
    
    def __init__(self):
        self.providers = [
            {
                "name": "SendGrid",
                "host": "smtp.sendgrid.net",
                "port": 587,
                "user": "apikey",
                "password": os.getenv('SENDGRID_API_KEY'),
                "use_tls": True,
                "use_ssl": False
            },
            {
                "name": "Gmail-SSL",
                "host": "smtp.gmail.com",
                "port": 465,
                "user": os.getenv('SMTP_USER'),
                "password": os.getenv('SMTP_PASS'),
                "use_tls": False,
                "use_ssl": True
            },
            {
                "name": "Gmail-TLS", 
                "host": "smtp.gmail.com",
                "port": 587,
                "user": os.getenv('SMTP_USER'),
                "password": os.getenv('SMTP_PASS'),
                "use_tls": True,
                "use_ssl": False
            },
            {
                "name": "Gmail-Plain",
                "host": "smtp.gmail.com", 
                "port": 25,
                "user": os.getenv('SMTP_USER'),
                "password": os.getenv('SMTP_PASS'),
                "use_tls": True,
                "use_ssl": False
            }
        ]
        
        self.email_from = os.getenv('EMAIL_FROM', os.getenv('SMTP_USER'))
    
    def send_email(self, to_email, subject, content, attachment_data=None, attachment_filename=None):
        """
        Envía un correo intentando múltiples proveedores
        
        Args:
            to_email (str): Dirección de destino
            subject (str): Asunto del correo
            content (str): Contenido del correo
            attachment_data (bytes): Datos del archivo adjunto
            attachment_filename (str): Nombre del archivo adjunto
            
        Returns:
            tuple: (success, provider_used, error_message)
        """
        
        errors = []  # Acumular errores de cada proveedor
        
        for provider in self.providers:
            if not provider['password']:
                error_detail = f"{provider['name']}: Sin credenciales configuradas"
                logger.info(error_detail)
                errors.append(error_detail)
                continue
                
            try:
                logger.info(f"Intentando enviar correo con {provider['name']} ({provider['host']}:{provider['port']})")
                
                # Crear mensaje
                msg = EmailMessage()
                msg['Subject'] = subject
                msg['From'] = self.email_from
                msg['To'] = to_email
                msg.set_content(content)
                
                # Agregar archivo adjunto si se proporciona
                if attachment_data and attachment_filename:
                    if attachment_filename.endswith('.xlsx'):
                        msg.add_attachment(attachment_data,
                                         maintype='application',
                                         subtype='vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                         filename=attachment_filename)
                    else:
                        msg.add_attachment(attachment_data, filename=attachment_filename)
                
                # Establecer conexión con reintentos
                max_retries = 3
                for retry in range(max_retries):
                    try:
                        if provider['use_ssl']:
                            logger.info(f"Conectando con SSL a {provider['host']}:{provider['port']} (intento {retry + 1})")
                            smtp = smtplib.SMTP_SSL(provider['host'], provider['port'], timeout=60)
                        else:
                            logger.info(f"Conectando con SMTP a {provider['host']}:{provider['port']} (intento {retry + 1})")
                            smtp = smtplib.SMTP(provider['host'], provider['port'], timeout=60)
                            if provider['use_tls']:
                                logger.info("Iniciando TLS...")
                                smtp.starttls()
                        
                        # Si llegamos aquí, la conexión fue exitosa
                        break
                        
                    except Exception as conn_error:
                        logger.warning(f"Error de conexión en intento {retry + 1}: {str(conn_error)}")
                        if retry == max_retries - 1:
                            raise conn_error
                        # Esperar un poco antes del siguiente intento
                        import time
                        time.sleep(2)
                
                # Autenticarse y enviar
                logger.info(f"Autenticando con usuario: {provider['user']}")
                smtp.login(provider['user'], provider['password'])
                logger.info("Enviando mensaje...")
                smtp.send_message(msg)
                
                # Cerrar conexión de forma segura
                try:
                    smtp.quit()
                except:
                    smtp.close()
                
                logger.info(f"✅ Correo enviado exitosamente con {provider['name']} a {to_email}")
                return True, provider['name'], None
                
            except Exception as e:
                error_msg = str(e)
                error_detail = f"{provider['name']}: {error_msg}"
                logger.warning(f"❌ Error con {provider['name']}: {error_msg}")
                errors.append(error_detail)
                
                # Cerrar conexión si existe
                try:
                    if 'smtp' in locals():
                        smtp.quit()
                except:
                    pass
                
                # Categorizar errores y decidir si continuar
                if any(err_type in error_msg.lower() for err_type in [
                    "network is unreachable", "errno 101", "connection refused",
                    "connection aborted", "software caused connection abort",
                    "broken pipe", "connection reset by peer"
                ]):
                    logger.info(f"Error de red detectado con {provider['name']}, probando siguiente proveedor...")
                    continue
                elif any(err_type in error_msg.lower() for err_type in [
                    "authentication failed", "535", "invalid credentials",
                    "username and password not accepted"
                ]):
                    logger.info(f"Error de autenticación con {provider['name']}, probando siguiente proveedor...")
                    continue
                elif any(err_type in error_msg.lower() for err_type in [
                    "timeout", "timed out"
                ]):
                    logger.info(f"Timeout con {provider['name']}, probando siguiente proveedor...")
                    continue
                else:
                    # Otros errores también intentar siguiente proveedor
                    logger.info(f"Error general con {provider['name']}, probando siguiente proveedor...")
                    continue
        
        # Si ningún proveedor SMTP funcionó, intentar SendGrid API como último recurso
        if os.getenv('SENDGRID_API_KEY'):
            logger.info("Todos los proveedores SMTP fallaron, intentando SendGrid API...")
            success, provider, error = self.send_email_sendgrid_api(to_email, subject, content, attachment_data, attachment_filename)
            if success:
                return success, provider, error
            else:
                errors.append(f"SendGrid-API: {error}")
        
        # Si absolutamente todo falló
        error_msg = f"Todos los proveedores fallaron. Detalles: {'; '.join(errors)}"
        logger.error(error_msg)
        return False, None, error_msg
    
    def test_connection(self):
        """Prueba la conectividad de todos los proveedores"""
        results = {}
        
        for provider in self.providers:
            if not provider['password']:
                results[provider['name']] = "Sin credenciales"
                continue
            
            try:
                logger.info(f"Probando conexión con {provider['name']} ({provider['host']}:{provider['port']})")
                
                if provider['use_ssl']:
                    smtp = smtplib.SMTP_SSL(provider['host'], provider['port'], timeout=10)
                else:
                    smtp = smtplib.SMTP(provider['host'], provider['port'], timeout=10)
                    if provider['use_tls']:
                        smtp.starttls()
                
                smtp.login(provider['user'], provider['password'])
                smtp.quit()
                results[provider['name']] = "✅ Conectado"
                
            except Exception as e:
                error_detail = f"❌ Error: {str(e)}"
                results[provider['name']] = error_detail
                logger.warning(f"Error probando {provider['name']}: {str(e)}")
        
        return results
    
    def get_configuration_info(self):
        """Obtiene información sobre la configuración actual"""
        config_info = {}
        
        for provider in self.providers:
            config_info[provider['name']] = {
                "host": provider['host'],
                "port": provider['port'],
                "user": provider['user'],
                "has_password": bool(provider['password']),
                "use_ssl": provider['use_ssl'],
                "use_tls": provider['use_tls']
            }
        
        return {
            "email_from": self.email_from,
            "providers": config_info
        }
    
    def send_email_sendgrid_api(self, to_email, subject, content, attachment_data=None, attachment_filename=None):
        """Alternativa usando SendGrid API REST en lugar de SMTP"""
        api_key = os.getenv('SENDGRID_API_KEY')
        if not api_key:
            return False, None, "SendGrid API Key no configurada"
        
        try:
            # Preparar el payload para SendGrid API
            email_data = {
                "personalizations": [{
                    "to": [{"email": to_email}]
                }],
                "from": {"email": self.email_from},
                "subject": subject,
                "content": [{
                    "type": "text/plain",
                    "value": content
                }]
            }
            
            # Agregar archivo adjunto si existe
            if attachment_data and attachment_filename:
                attachment_b64 = base64.b64encode(attachment_data).decode()
                email_data["attachments"] = [{
                    "content": attachment_b64,
                    "filename": attachment_filename,
                    "type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" if attachment_filename.endswith('.xlsx') else "application/octet-stream"
                }]
            
            # Preparar request HTTP
            url = "https://api.sendgrid.com/v3/mail/send"
            headers = {
                'Authorization': f'Bearer {api_key}',
                'Content-Type': 'application/json'
            }
            
            data = json.dumps(email_data).encode('utf-8')
            req = urllib.request.Request(url, data=data, headers=headers, method='POST')
            
            # Enviar request
            with urllib.request.urlopen(req, timeout=30) as response:
                if response.status == 202:  # SendGrid retorna 202 para éxito
                    logger.info(f"✅ Correo enviado via SendGrid API a {to_email}")
                    return True, "SendGrid-API", None
                else:
                    error_msg = f"SendGrid API error: {response.status}"
                    logger.error(error_msg)
                    return False, None, error_msg
                    
        except Exception as e:
            error_msg = f"Error con SendGrid API: {str(e)}"
            logger.error(error_msg)
            return False, None, error_msg

# Instancia global del servicio
email_service = EmailService()