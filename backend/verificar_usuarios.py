from database.connection import mysql
from MySQLdb.cursors import DictCursor
from flask import Flask
from config import Config
from flask_bcrypt import generate_password_hash

# Crear aplicación Flask para el contexto
app = Flask(__name__)
app.config.from_object(Config)
mysql.init_app(app)

def listar_usuarios():
    """Listar usuarios existentes en la base de datos"""
    try:
        with app.app_context():
            cursor = mysql.connection.cursor(DictCursor)
            cursor.execute("SELECT id_usuario, nombres, apellido_paterno, email, rol, activo FROM usuarios")
            usuarios = cursor.fetchall()
            cursor.close()
            
            print("📋 Usuarios encontrados en la base de datos:")
            print("-" * 70)
            if usuarios:
                for usuario in usuarios:
                    estado = "✅ Activo" if usuario['activo'] else "❌ Inactivo"
                    print(f"ID: {usuario['id_usuario']} | {usuario['nombres']} {usuario['apellido_paterno']} | {usuario['email']} | {usuario['rol']} | {estado}")
            else:
                print("⚠️  No se encontraron usuarios en la base de datos")
            print("-" * 70)
            return usuarios
    except Exception as e:
        print(f"❌ Error al conectar a la base de datos: {e}")
        return None

def crear_usuario_prueba():
    """Crear un usuario de prueba para el sistema"""
    try:
        with app.app_context():
            # Datos del usuario de prueba
            nombres = "Admin"
            apellido_paterno = "Sistema"
            apellido_materno = "Prueba"
            email = "admin@sistema.com"
            contrasena = "123456"
            rol = "admin"
            
            # Generar hash de la contraseña
            hash_contrasena = generate_password_hash(contrasena).decode('utf-8')
            
            cursor = mysql.connection.cursor()
            
            # Verificar si ya existe un usuario con ese email
            cursor.execute("SELECT id_usuario FROM usuarios WHERE email = %s", (email,))
            usuario_existente = cursor.fetchone()
            
            if usuario_existente:
                print(f"⚠️  Ya existe un usuario con el email {email}")
                cursor.close()
                return False
            
            # Insertar nuevo usuario
            query = """
                INSERT INTO usuarios (nombres, apellido_paterno, apellido_materno, email, contrasena, rol, activo)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            valores = (nombres, apellido_paterno, apellido_materno, email, hash_contrasena, rol, True)
            
            cursor.execute(query, valores)
            mysql.connection.commit()
            cursor.close()
            
            print("✅ Usuario de prueba creado exitosamente!")
            print(f"📧 Email: {email}")
            print(f"🔒 Contraseña: {contrasena}")
            print(f"👤 Rol: {rol}")
            
            return True
            
    except Exception as e:
        print(f"❌ Error al crear usuario de prueba: {e}")
        return False

if __name__ == "__main__":
    print("🔍 Verificando conexión a la base de datos...")
    print(f"🌐 Host: {Config.MYSQL_HOST}")
    print(f"🗄️  Base de datos: {Config.MYSQL_DB}")
    print()
    
    # Listar usuarios existentes
    usuarios = listar_usuarios()
    
    if usuarios is not None:
        print()
        respuesta = input("¿Deseas crear un usuario de prueba admin@sistema.com con contraseña 123456? (s/n): ")
        if respuesta.lower() in ['s', 'si', 'sí', 'y', 'yes']:
            crear_usuario_prueba()
            print()
            print("🔄 Listando usuarios después de la creación:")
            listar_usuarios()
    
    print("\n🎯 Para usar la aplicación React, utiliza estas credenciales:")
    print("   📧 Email: admin@sistema.com")
    print("   🔒 Contraseña: 123456")