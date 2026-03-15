from flask import jsonify
from database.cursor_manager import get_cursor

def alta_grupo(datos):
    with get_cursor() as cursor:
        cursor.execute("""
            INSERT INTO grupos (grado, ciclo_escolar, id_tutor, Descripcion)
            VALUES (%s, %s, %s, %s)
        """, (
            datos['grado'],
            datos['ciclo_escolar'],
            datos.get('id_tutor'),
            datos.get('Descripcion')
        ))
    return jsonify({"msg": "Grupo creado"}), 201

def baja_grupo(id):
    with get_cursor() as cursor:
        cursor.execute("DELETE FROM grupos WHERE id_grupo = %s", (id,))
    return jsonify({"msg": "Grupo eliminado"}), 200

def cambio_grupo(id, datos):
    with get_cursor() as cursor:
        cursor.execute("""
            UPDATE grupos SET grado=%s, ciclo_escolar=%s, id_tutor=%s, Descripcion=%s
            WHERE id_grupo = %s
        """, (
            datos['grado'],
            datos['ciclo_escolar'],
            datos.get('id_tutor'),
            datos.get('Descripcion'),
            id
        ))
    return jsonify({"msg": "Grupo actualizado"}), 200

def find_all_grupos():
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("SELECT * FROM grupos")
        grupos = cursor.fetchall()
    return jsonify(grupos), 200

def find_grupo_by_id(id):
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("SELECT * FROM grupos WHERE id_grupo = %s", (id,))
        grupo = cursor.fetchone()
    if grupo:
        return jsonify(grupo), 200
    else:
        return jsonify({"msg": "Grupo no encontrado"}), 404

