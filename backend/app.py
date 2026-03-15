from flask import Flask
from flask_jwt_extended import JWTManager
from flasgger import Swagger
from flask_cors import CORS
from config import Config
from controllers.usuarios_controller import usuarios_bp
from controllers.alumnos_controller import alumnos_bp
from controllers.grupos_controller import grupos_bp
from controllers.tipos_reporte_controller import tipos_bp
from controllers.reportes_controller import reportes_bp
from auth.routes import auth_bp
from controllers.seguimiento_controller import seguimiento_bp
import logging

# Configuración básica del logging con rotación de archivos
import logging
from logging.handlers import RotatingFileHandler
import os

# Crear directorio de logs si no existe
if not os.path.exists('logs'):
    os.makedirs('logs')

# Configurar el logging con rotación de archivos
handler = RotatingFileHandler(
    filename='logs/app.log',
    maxBytes=10*1024*1024,  # 10MB por archivo
    backupCount=5           # Mantener 5 archivos de respaldo
)
handler.setFormatter(logging.Formatter(
    '%(asctime)s - %(levelname)s - %(message)s'
))

logging.basicConfig(
    level=logging.INFO,
    handlers=[
        handler,
        logging.StreamHandler()  # También mostrar en consola
    ]
)

# Definir logger global para el módulo
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config.from_object(Config)

# Configuración adicional de MySQL para evitar conexiones acumuladas
app.config['MYSQL_POOL_NAME'] = 'mypool'
app.config['MYSQL_POOL_SIZE'] = 5
app.config['MYSQL_POOL_RESET_SESSION'] = True
app.config['MYSQL_AUTOCOMMIT'] = False
app.config['MYSQL_USE_UNICODE'] = True

# Desarrollo: permitir todas las origins para /api/* (cambiar a dominios específicos en prod)
CORS(app, resources={r"/api/*": {"origins": "*"}},
     supports_credentials=True,
     allow_headers=["Content-Type", "Authorization", "Access-Control-Allow-Origin"])

JWTManager(app)


# Elimina flask_mysqldb. Usar solo manejo personalizado de conexión/cursor
from database.cursor_manager import get_cursor, get_transaction_cursor

app.config['SWAGGER'] = {
    'title': 'API Incidencias Escolares',
    'uiversion': 3,
    'securityDefinitions': {
        'Bearer': {
            'type': 'apiKey',
            'name': 'Authorization',
            'in': 'header',
            'description': 'Agrega el token JWT como: Bearer <token>'
        }
    }
}

swagger = Swagger(app)

# Registrar blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(usuarios_bp)
app.register_blueprint(alumnos_bp)
app.register_blueprint(grupos_bp)
app.register_blueprint(tipos_bp)
app.register_blueprint(reportes_bp)
app.register_blueprint(seguimiento_bp)

# Endpoint de prueba para correo
@app.route('/api/test-email', methods=['GET'])
def test_email_endpoint():
    """Endpoint para probar la configuración de correo"""
    from flask import jsonify, request
    from services.email_service import email_service
    
    try:
        # Obtener información de configuración
        config_info = email_service.get_configuration_info()
        
        # Correo de destino (parámetro o el mismo usuario)
        email_to = request.args.get('email', os.getenv('SMTP_USER', 'perrillo1981@gmail.com'))
        
        # Probar conectividad primero
        logger.info("Probando conectividad de proveedores de correo...")
        connection_results = email_service.test_connection()
        
        # Si se pide solo test de conexión
        if request.args.get('test_only') == 'true':
            return jsonify({
                "config": config_info,
                "connection_test": connection_results
            }), 200
        
        # Enviar correo de prueba
        logger.info("Enviando correo de prueba...")
        success, provider_used, error_msg = email_service.send_email(
            to_email=email_to,
            subject='Prueba de correo desde Railway',
            content='Este es un correo de prueba para verificar la configuración SMTP en Railway.'
        )
        
        return jsonify({
            "success": success,
            "message": f"Correo enviado a {email_to} usando {provider_used}" if success else f"Error: {error_msg}",
            "provider_used": provider_used,
            "config": config_info,
            "connection_test": connection_results
        }), 200 if success else 500
        
    except Exception as e:
        logger.exception("Error en test_email_endpoint")
        return jsonify({
            "success": False,
            "message": f"Error inesperado: {str(e)}",
            "config": {},
            "connection_test": {}
        }), 500

# Endpoint para diagnóstico avanzado
@app.route('/api/diagnose-email', methods=['GET'])  
def diagnose_email_endpoint():
    """Endpoint para diagnóstico avanzado de problemas de correo"""
    from flask import jsonify
    from services.email_service import email_service
    import socket
    
    try:
        diagnosis = {
            "network_connectivity": {},
            "smtp_ports": {},
            "dns_resolution": {},
            "config_status": {},
            "recommendations": []
        }
        
        # 1. Verificar resolución DNS
        hosts_to_check = ["smtp.gmail.com", "smtp.sendgrid.net"]
        for host in hosts_to_check:
            try:
                ip = socket.gethostbyname(host)
                diagnosis["dns_resolution"][host] = f"✅ {ip}"
            except Exception as e:
                diagnosis["dns_resolution"][host] = f"❌ {str(e)}"
        
        # 2. Verificar conectividad de puertos
        ports_to_check = [25, 465, 587, 80, 443]
        for host in hosts_to_check:
            diagnosis["smtp_ports"][host] = {}
            for port in ports_to_check:
                try:
                    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    sock.settimeout(5)
                    result = sock.connect_ex((host, port))
                    sock.close()
                    diagnosis["smtp_ports"][host][port] = "✅ Abierto" if result == 0 else "❌ Cerrado"
                except Exception as e:
                    diagnosis["smtp_ports"][host][port] = f"❌ Error: {str(e)}"
        
        # 3. Verificar configuración
        config = email_service.get_configuration_info()
        diagnosis["config_status"] = config
        
        # 4. Generar recomendaciones
        all_ports_blocked = True
        for host_ports in diagnosis["smtp_ports"].values():
            if any("Abierto" in status for status in host_ports.values()):
                all_ports_blocked = False
                break
        
        if all_ports_blocked:
            diagnosis["recommendations"].append("🔥 CRÍTICO: Todos los puertos SMTP están bloqueados")
            diagnosis["recommendations"].append("💡 Solución: Usar SendGrid API (no SMTP)")
        
        if not os.getenv('SENDGRID_API_KEY'):
            diagnosis["recommendations"].append("💡 Configurar SENDGRID_API_KEY para mayor confiabilidad")
        
        # 5. Probar SendGrid API si está configurado
        if os.getenv('SENDGRID_API_KEY'):
            success, provider, error = email_service.send_email_sendgrid_api(
                to_email=os.getenv('SMTP_USER', 'test@example.com'),
                subject='Prueba SendGrid API',
                content='Test desde Railway usando API'
            )
            diagnosis["sendgrid_api_test"] = {
                "success": success,
                "provider": provider,
                "error": error
            }
        
        return jsonify(diagnosis), 200
        
    except Exception as e:
        logger.exception("Error en diagnose_email_endpoint")
        return jsonify({
            "error": f"Error en diagnóstico: {str(e)}"
        }), 500


# Función para limpiar recursos al cerrar la aplicación
import atexit

def cleanup():
    """Limpiar recursos al cerrar la aplicación"""
    try:
        # Cerrar handlers de logging
        for handler in logging.getLogger().handlers:
            handler.close()
        print("Recursos limpiados correctamente")
    except Exception as e:
        print(f"Error durante la limpieza: {e}")

atexit.register(cleanup)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
