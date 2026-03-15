from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt

def obtener_usuario_actual():
    usuario_id = get_jwt_identity()
    rol = get_jwt()['rol']
    return usuario_id, rol
