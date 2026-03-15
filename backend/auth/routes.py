from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from flask_bcrypt import generate_password_hash
from auth.utils import verificar_contraseña

from database.cursor_manager import get_cursor

auth_bp = Blueprint('auth_bp', __name__)

@auth_bp.route('/api/login', methods=['POST'])
def login():
    correo = request.json.get('correo')
    contraseña = request.json.get('contraseña')


    usuario = None
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("SELECT * FROM usuarios WHERE email = %s", (correo,))
        usuario = cursor.fetchone()

    if usuario and verificar_contraseña(contraseña, usuario['contrasena']):
        token = create_access_token(identity=str(usuario['id_usuario']), additional_claims={"rol": usuario['rol']})
        return jsonify(access_token=token, usuario={
            "id": usuario['id_usuario'], 
            "nombres": usuario['nombres'],
            "apellido_paterno": usuario['apellido_paterno'],
            "apellido_materno": usuario['apellido_materno'], 
            "rol": usuario['rol'],
            "email": usuario['email']
        })
    return jsonify({"msg": "Credenciales inválidas"}), 401



