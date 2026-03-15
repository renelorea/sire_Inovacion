from flask import jsonify
from flask_bcrypt import generate_password_hash
from database.cursor_manager import get_cursor

def alta_usuario(datos):
    # Si no se proporciona contraseña, usar la contraseña por defecto
    contrasena = datos.get('contrasena', 'cecytem@1234')
    
    with get_cursor() as cursor:
        cursor.execute("""
            INSERT INTO usuarios (nombres, apellido_paterno, apellido_materno, email, rol, contrasena)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            datos['nombres'],
            datos['apellido_paterno'],
            datos.get('apellido_materno'),
            datos['email'],
            datos['rol'],
            generate_password_hash(contrasena).decode('utf-8')
        ))
    return jsonify({"msg": "Usuario creado"}), 201

def baja_usuario(id):
    with get_cursor() as cursor:
        cursor.execute("UPDATE usuarios SET activo = 0 WHERE id_usuario = %s", (id,))
    return jsonify({"msg": "Usuario desactivado"}), 200

def cambio_usuario(id, datos):
    with get_cursor() as cursor:
        cursor.execute("""
            UPDATE usuarios SET nombres=%s, apellido_paterno=%s, apellido_materno=%s, rol=%s
            WHERE id_usuario = %s
        """, (
            datos['nombres'],
            datos['apellido_paterno'],
            datos.get('apellido_materno'),
            datos['rol'],
            id
        ))
    return jsonify({"msg": "Usuario actualizado"}), 200

def resetear_contrasena_usuario(id):
    """
    Resetea la contraseña de un usuario a la contraseña por defecto (cecytem@1234)
    """
    contrasena_default = 'cecytem@1234'
    try:
        with get_cursor(dict_cursor=True) as cursor:
            # Verificar que el usuario existe y está activo
            cursor.execute("SELECT * FROM usuarios WHERE id_usuario = %s AND activo = 1", (id,))
            usuario = cursor.fetchone()
            if not usuario:
                return jsonify({"msg": "Usuario no encontrado o inactivo"}), 404
            # Actualizar la contraseña
            cursor.execute("""
                UPDATE usuarios SET contrasena = %s
                WHERE id_usuario = %s
            """, (
                generate_password_hash(contrasena_default).decode('utf-8'),
                id
            ))
        return jsonify({
            "msg": "Contraseña reseteada exitosamente",
            "nueva_contrasena": contrasena_default,
            "usuario": f"{usuario['nombres']} {usuario['apellido_paterno']}"
        }), 200
    except Exception as e:
        return jsonify({"msg": f"Error al resetear contraseña: {str(e)}"}), 500

def cambiar_contrasena_usuario(id, datos):
    """
    Cambia la contraseña de un usuario (requiere contraseña actual y nueva contraseña)
    """
    try:
        with get_cursor(dict_cursor=True) as cursor:
            # Verificar que el usuario existe
            cursor.execute("SELECT * FROM usuarios WHERE id_usuario = %s AND activo = 1", (id,))
            usuario = cursor.fetchone()
            if not usuario:
                return jsonify({"msg": "Usuario no encontrado"}), 404
            nueva_contrasena = datos.get('nueva_contrasena')
            if not nueva_contrasena:
                return jsonify({"msg": "Nueva contraseña es requerida"}), 400
            # Actualizar la contraseña
            cursor.execute("""
                UPDATE usuarios SET contrasena = %s
                WHERE id_usuario = %s
            """, (
                generate_password_hash(nueva_contrasena).decode('utf-8'),
                id
            ))
        return jsonify({"msg": "Contraseña actualizada exitosamente"}), 200
    except Exception as e:
        return jsonify({"msg": f"Error al cambiar contraseña: {str(e)}"}), 500

def find_all_usuarios():
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("SELECT * FROM usuarios WHERE activo = 1")
        usuarios = cursor.fetchall()
    return jsonify(usuarios), 200

def find_usuario_by_id(id):
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("SELECT * FROM usuarios WHERE id_usuario = %s", (id,))
        usuario = cursor.fetchone()
    if usuario:
        return jsonify(usuario), 200
    else:
        return jsonify({"msg": "Usuario no encontrado"}), 404

def cambiar_password_por_correo(correo, password_actual, password_nueva):
    """
    Cambiar contraseña de usuario usando correo electrónico
    Valida que la contraseña actual sea correcta
    """
    try:
        from flask_bcrypt import check_password_hash
        with get_cursor(dict_cursor=True) as cursor:
            # Buscar usuario por correo
            cursor.execute("SELECT id_usuario, contrasena FROM usuarios WHERE email = %s AND activo = 1", (correo,))
            usuario = cursor.fetchone()
            if not usuario:
                return {"success": False, "msg": "Usuario no encontrado"}
            # Verificar contraseña actual
            if not check_password_hash(usuario['contrasena'], password_actual):
                return {"success": False, "msg": "Contraseña actual incorrecta"}
            # Actualizar con nueva contraseña
            nueva_contrasena_hash = generate_password_hash(password_nueva).decode('utf-8')
            cursor.execute("""
                UPDATE usuarios SET contrasena = %s
                WHERE id_usuario = %s
            """, (nueva_contrasena_hash, usuario['id_usuario']))
        return {"success": True, "msg": "Contraseña actualizada exitosamente"}
    except Exception as e:
        return {"success": False, "msg": f"Error al cambiar contraseña: {str(e)}"}

