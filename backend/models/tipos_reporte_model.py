from flask import jsonify
from database.cursor_manager import get_cursor

def alta_tipo(datos):
    with get_cursor() as cursor:
        cursor.execute("""
            INSERT INTO tipos_reporte (nombre, descripcion, gravedad)
            VALUES (%s, %s, %s)
        """, (
            datos['nombre'],
            datos.get('descripcion'),
            datos['gravedad']
        ))
    return jsonify({"msg": "Tipo de reporte creado"}), 201

def baja_tipo(id):
    with get_cursor() as cursor:
        cursor.execute("DELETE FROM tipos_reporte WHERE id_tipo_reporte = %s", (id,))
    return jsonify({"msg": "Tipo de reporte eliminado"}), 200

def cambio_tipo(id, datos):
    with get_cursor() as cursor:
        cursor.execute("""
            UPDATE tipos_reporte SET nombre=%s, descripcion=%s, gravedad=%s
            WHERE id_tipo_reporte = %s
        """, (
            datos['nombre'],
            datos.get('descripcion'),
            datos['gravedad'],
            id
        ))
    return jsonify({"msg": "Tipo de reporte actualizado"}), 200

def find_all_tipos():
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("SELECT * FROM tipos_reporte")
        tipos = cursor.fetchall()
    return jsonify(tipos), 200

def find_tipo_by_id(id):
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("SELECT * FROM tipos_reporte WHERE id_tipo_reporte = %s", (id,))
        tipo = cursor.fetchone()
    if tipo:
        return jsonify(tipo), 200
    else:
        return jsonify({"msg": "Tipo de reporte no encontrado"}), 404

