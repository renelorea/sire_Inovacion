"""
Ejemplo de cómo usar el cursor_manager para evitar conexiones acumuladas
"""
from database.cursor_manager import get_cursor, get_transaction_cursor

def ejemplo_consulta_segura():
    """Ejemplo de consulta de solo lectura"""
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("SELECT * FROM usuarios WHERE activo = 1")
        usuarios = cursor.fetchall()
        return usuarios
    # El cursor se cierra automáticamente aquí

def ejemplo_insercion_segura(datos):
    """Ejemplo de inserción con transacción"""
    try:
        with get_transaction_cursor() as cursor:
            cursor.execute("""
                INSERT INTO usuarios (nombres, apellido_paterno, email)
                VALUES (%s, %s, %s)
            """, (datos['nombres'], datos['apellido_paterno'], datos['email']))
            # Commit automático si no hay excepciones
            return True
    except Exception as e:
        # Rollback automático en caso de error
        print(f"Error en inserción: {e}")
        return False

def ejemplo_actualizacion_segura(id_usuario, datos):
    """Ejemplo de actualización con transacción"""
    try:
        with get_transaction_cursor() as cursor:
            cursor.execute("""
                UPDATE usuarios 
                SET nombres = %s, apellido_paterno = %s 
                WHERE id_usuario = %s
            """, (datos['nombres'], datos['apellido_paterno'], id_usuario))
            
            if cursor.rowcount == 0:
                raise Exception("Usuario no encontrado")
            
            # Commit automático
            return True
    except Exception as e:
        # Rollback automático
        print(f"Error en actualización: {e}")
        return False