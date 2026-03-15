from flask import Flask, jsonify, request
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Datos mock para pruebas
usuarios_mock = [
    {"id": 1, "nombres": "Admin", "apellido_paterno": "Sistema", "email": "admin@sistema.com", "rol": "admin", "activo": True},
    {"id": 2, "nombres": "Juan", "apellido_paterno": "Pérez", "email": "juan@email.com", "rol": "profesor", "activo": True}
]

alumnos_mock = [
    {"id": 1, "nombres": "María", "apellido_paterno": "González", "matricula": "2024001", "grado": "1", "grupo": "A"},
    {"id": 2, "nombres": "Carlos", "apellido_paterno": "Ramírez", "matricula": "2024002", "grado": "1", "grupo": "B"}
]

grupos_mock = [
    {"id": 1, "nombre": "1A", "grado": "1", "turno": "Matutino", "profesor_titular": "Prof. García", "aula": "101"},
    {"id": 2, "nombre": "1B", "grado": "1", "turno": "Matutino", "profesor_titular": "Prof. López", "aula": "102"}
]

tipos_reporte_mock = [
    {"id": 1, "nombre": "Disciplina", "descripcion": "Problemas de comportamiento"},
    {"id": 2, "nombre": "Académico", "descripcion": "Problemas académicos"}
]

reportes_mock = [
    {"id": 1, "alumno_id": 1, "tipo_reporte_id": 1, "descripcion": "Comportamiento disruptivo", "gravedad": "media", "estado": "pendiente"}
]

# Rutas de autenticación
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('correo')
    password = data.get('contraseña')
    
    # Verificación simple
    if email == "admin@sistema.com" and password == "123456":
        return jsonify({
            "token": "fake-jwt-token-for-testing",
            "usuario": {"id": 1, "nombres": "Admin", "apellido_paterno": "Sistema", "email": email, "rol": "admin"}
        })
    else:
        return jsonify({"message": "Credenciales inválidas"}), 401

# Rutas de usuarios
@app.route('/api/usuarios', methods=['GET'])
def get_usuarios():
    return jsonify({"usuarios": usuarios_mock})

@app.route('/api/usuarios', methods=['POST'])
def create_usuario():
    data = request.get_json()
    new_user = {
        "id": len(usuarios_mock) + 1,
        **data,
        "activo": True
    }
    usuarios_mock.append(new_user)
    return jsonify({"message": "Usuario creado exitosamente", "usuario": new_user}), 201

@app.route('/api/usuarios/<int:user_id>', methods=['PUT'])
def update_usuario(user_id):
    data = request.get_json()
    for user in usuarios_mock:
        if user["id"] == user_id:
            user.update(data)
            return jsonify({"message": "Usuario actualizado exitosamente", "usuario": user})
    return jsonify({"message": "Usuario no encontrado"}), 404

@app.route('/api/usuarios/<int:user_id>', methods=['DELETE'])
def delete_usuario(user_id):
    global usuarios_mock
    usuarios_mock = [u for u in usuarios_mock if u["id"] != user_id]
    return jsonify({"message": "Usuario eliminado exitosamente"})

# Rutas de alumnos
@app.route('/api/alumnos', methods=['GET'])
def get_alumnos():
    return jsonify({"alumnos": alumnos_mock})

@app.route('/api/alumnos', methods=['POST'])
def create_alumno():
    data = request.get_json()
    new_alumno = {
        "id": len(alumnos_mock) + 1,
        **data
    }
    alumnos_mock.append(new_alumno)
    return jsonify({"message": "Alumno creado exitosamente", "alumno": new_alumno}), 201

@app.route('/api/alumnos/<int:alumno_id>', methods=['PUT'])
def update_alumno(alumno_id):
    data = request.get_json()
    for alumno in alumnos_mock:
        if alumno["id"] == alumno_id:
            alumno.update(data)
            return jsonify({"message": "Alumno actualizado exitosamente", "alumno": alumno})
    return jsonify({"message": "Alumno no encontrado"}), 404

@app.route('/api/alumnos/<int:alumno_id>', methods=['DELETE'])
def delete_alumno(alumno_id):
    global alumnos_mock
    alumnos_mock = [a for a in alumnos_mock if a["id"] != alumno_id]
    return jsonify({"message": "Alumno eliminado exitosamente"})

# Rutas de grupos
@app.route('/api/grupos', methods=['GET'])
def get_grupos():
    return jsonify({"grupos": grupos_mock})

@app.route('/api/grupos', methods=['POST'])
def create_grupo():
    data = request.get_json()
    new_grupo = {
        "id": len(grupos_mock) + 1,
        **data
    }
    grupos_mock.append(new_grupo)
    return jsonify({"message": "Grupo creado exitosamente", "grupo": new_grupo}), 201

# Rutas de tipos de reporte
@app.route('/api/tipos-reporte', methods=['GET'])
def get_tipos_reporte():
    return jsonify({"tipos": tipos_reporte_mock})

@app.route('/api/tipos-reporte', methods=['POST'])
def create_tipo_reporte():
    data = request.get_json()
    new_tipo = {
        "id": len(tipos_reporte_mock) + 1,
        **data
    }
    tipos_reporte_mock.append(new_tipo)
    return jsonify({"message": "Tipo de reporte creado exitosamente", "tipo": new_tipo}), 201

# Rutas de reportes
@app.route('/api/reportes', methods=['GET'])
def get_reportes():
    return jsonify({"reportes": reportes_mock})

@app.route('/api/reportes', methods=['POST'])
def create_reporte():
    data = request.get_json()
    new_reporte = {
        "id": len(reportes_mock) + 1,
        **data
    }
    reportes_mock.append(new_reporte)
    return jsonify({"message": "Reporte creado exitosamente", "reporte": new_reporte}), 201

# Ruta de estado del servidor
@app.route('/api/status', methods=['GET'])
def status():
    return jsonify({"status": "ok", "message": "Backend mock funcionando correctamente"})

if __name__ == '__main__':
    print("🚀 Iniciando servidor mock para pruebas del frontend...")
    print("📍 Servidor disponible en: http://localhost:5001")
    print("🔑 Credenciales de prueba:")
    print("   Email: admin@sistema.com")
    print("   Password: 123456")
    print("💡 Este es un servidor mock para pruebas del frontend React")
    app.run(host='127.0.0.1', port=5001, debug=False)