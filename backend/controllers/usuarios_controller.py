from flask import Blueprint, request, jsonify, make_response
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.usuarios_model import alta_usuario, baja_usuario, cambio_usuario, find_all_usuarios, find_usuario_by_id, resetear_contrasena_usuario, cambiar_contrasena_usuario
import logging

usuarios_bp = Blueprint('usuarios_bp', __name__)

@usuarios_bp.route('/api/usuarios', methods=['POST'])
@jwt_required()
def alta():
    """
    Alta de usuario
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - nombres
              - apellido_paterno
              - email
              - rol
              - contrasena
            properties:
              nombres:
                type: string
              apellido_paterno:
                type: string
              apellido_materno:
                type: string
              email:
                type: string
              rol:
                type: string
                enum:
                  - Profesor
                  - Administrativo
                  - Director
                  - Psicologia
              contrasena:
                type: string
    responses:
      201:
        description: Usuario creado exitosamente
      409:
        description: El correo ya está registrado
    """
    datos = request.json
    logging.info(f'Datos recibidos en POST /usuarios: {datos}')
    return alta_usuario(datos)

@usuarios_bp.route('/api/usuarios/<int:id>', methods=['DELETE'])
@jwt_required()
def baja(id):
    """
    Eliminar usuario por ID
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
    responses:
      200:
        description: Usuario desactivado
    """
    return baja_usuario(id)

@usuarios_bp.route('/api/usuarios/<int:id>', methods=['PUT'])
@jwt_required()
def cambio(id):
    """
    Actualizar usuario por ID
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              nombres:
                type: string
              apellido_paterno:
                type: string
              apellido_materno:
                type: string
              rol:
                type: string
    responses:
      200:
        description: Usuario actualizado
    """
    datos = request.json
    return cambio_usuario(id, datos)

@usuarios_bp.route('/api/usuarios/<int:id>/reset-password', methods=['POST'])
@jwt_required()
def resetear_contrasena(id):
    """
    Resetear contraseña de usuario a la contraseña por defecto
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
        description: ID del usuario al que se le reseteará la contraseña
    responses:
      200:
        description: Contraseña reseteada exitosamente
        content:
          application/json:
            schema:
              type: object
              properties:
                msg:
                  type: string
                  example: "Contraseña reseteada exitosamente"
                nueva_contrasena:
                  type: string
                  example: "cecytem@1234"
                usuario:
                  type: string
                  example: "Juan Pérez"
      404:
        description: Usuario no encontrado o inactivo
      500:
        description: Error interno del servidor
    """
    try:
        current_user = get_jwt_identity()
        logging.info(f'Usuario {current_user} reseteando contraseña del usuario ID: {id}')
        return resetear_contrasena_usuario(id)
    except Exception as e:
        logging.error(f'Error en resetear_contrasena: {str(e)}')
        return {"msg": "Error interno del servidor"}, 500

@usuarios_bp.route('/api/usuarios/<int:id>/change-password', methods=['PUT'])
@jwt_required()
def cambiar_contrasena(id):
    """
    Cambiar contraseña de usuario
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
        description: ID del usuario al que se le cambiará la contraseña
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - nueva_contrasena
            properties:
              nueva_contrasena:
                type: string
                description: Nueva contraseña del usuario
                minLength: 6
                example: "miNuevaContrasena123"
    responses:
      200:
        description: Contraseña actualizada exitosamente
        content:
          application/json:
            schema:
              type: object
              properties:
                msg:
                  type: string
                  example: "Contraseña actualizada exitosamente"
      400:
        description: Nueva contraseña es requerida
      404:
        description: Usuario no encontrado
      500:
        description: Error interno del servidor
    """
    try:
        datos = request.json
        current_user = get_jwt_identity()
        logging.info(f'Usuario {current_user} cambiando contraseña del usuario ID: {id}')
        
        if not datos or 'nueva_contrasena' not in datos:
            return {"msg": "Nueva contraseña es requerida"}, 400
            
        if len(datos['nueva_contrasena']) < 6:
            return {"msg": "La contraseña debe tener al menos 6 caracteres"}, 400
        
        return cambiar_contrasena_usuario(id, datos)
    except Exception as e:
        logging.error(f'Error en cambiar_contrasena: {str(e)}')
        return {"msg": "Error interno del servidor"}, 500

@usuarios_bp.route('/api/usuarios', methods=['GET'])
@jwt_required()
def listar_todos():
    """
    Listar todos los usuarios activos
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    responses:
      200:
        description: Lista de usuarios
    """
    return find_all_usuarios()

@usuarios_bp.route('/api/usuarios/<int:id>', methods=['GET'])
@jwt_required()
def obtener_por_id(id):
    """
    Obtener usuario por ID
    ---
    tags:
      - Usuarios
    security:
      - Bearer: []
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
    responses:
      200:
        description: Usuario encontrado
      404:
        description: Usuario no encontrado
    """
    return find_usuario_by_id(id)

@usuarios_bp.route('/api/usuarios/cambiar-password', methods=['PUT'])
def cambiar_password_por_correo():
    """
    Cambiar contraseña de usuario por correo (sin autenticación JWT)
    Se usa cuando el usuario tiene la contraseña predeterminada
    """
    try:
        datos = request.json
        logging.info(f'Solicitud de cambio de contraseña por correo')
        logging.info(f'Datos recibidos: {datos}')
        
        if not datos:
            logging.warning(f'Datos faltantes - request.json es None')
            return make_response(jsonify({"msg": "Datos requeridos"}), 400)
        
        correo = datos.get('correo')
        password_actual = datos.get('password_actual')
        password_nueva = datos.get('password_nueva')
        
        logging.info(f'Campos recibidos - correo: {correo}, password_actual: {"***" if password_actual else None}, password_nueva: {"***" if password_nueva else None}')
        
        if not correo or not password_actual or not password_nueva:
            logging.warning(f'Campos requeridos faltantes - correo: {bool(correo)}, password_actual: {bool(password_actual)}, password_nueva: {bool(password_nueva)}')
            return make_response(jsonify({"msg": "Correo, contraseña actual y nueva contraseña son requeridos"}), 400)
        
        if len(password_nueva) < 6:
            logging.warning(f'Contraseña muy corta - longitud: {len(password_nueva)}')
            return make_response(jsonify({"msg": "La contraseña debe tener al menos 6 caracteres"}), 400)
        
        if password_nueva == 'cecytem@1234':
            logging.warning(f'Intento de usar contraseña predeterminada')
            return make_response(jsonify({"msg": "No puedes usar la contraseña predeterminada"}), 400)
        
        # Importar función de modelo para cambiar contraseña por correo
        from models.usuarios_model import cambiar_password_por_correo as cambiar_pass_modelo
        
        resultado = cambiar_pass_modelo(correo, password_actual, password_nueva)
        
        if resultado.get('success'):
            logging.info(f'Contraseña cambiada exitosamente para usuario: {correo}')
            return make_response(jsonify({"msg": "Contraseña actualizada exitosamente"}), 200)
        else:
            logging.warning(f'Error al cambiar contraseña para usuario {correo}: {resultado.get("msg")}')
            return make_response(jsonify({"msg": resultado.get('msg', 'Error al cambiar contraseña')}), 400)
    
    except Exception as e:
        logging.exception(f'Error en cambiar_password_por_correo: {str(e)}')
        return make_response(jsonify({"msg": "Error interno del servidor"}), 500)
