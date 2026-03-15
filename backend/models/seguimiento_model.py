from flask import jsonify
from database.cursor_manager import get_cursor
from datetime import date
import base64
import logging

def crear_seguimiento(data):
    """
    Inserta un seguimiento con archivo en lugar de URL
    Espera keys: id_reporte, responsable, fecha_seguimiento, descripcion, 
    evidencia_archivo (base64), evidencia_nombre, evidencia_tipo, evidencia_tamaño
    """
    try:
        fecha = data.get('fecha_seguimiento') or date.today().isoformat()
        # Procesar archivo si existe
        evidencia_archivo = None
        evidencia_nombre = None
        evidencia_tipo = None
        evidencia_tamaño = None
        if 'evidencia_archivo' in data and data['evidencia_archivo']:
            evidencia_archivo = base64.b64decode(data['evidencia_archivo'])
            evidencia_nombre = data.get('evidencia_nombre', 'archivo')
            evidencia_tipo = data.get('evidencia_tipo', 'application/octet-stream')
            evidencia_tamaño = len(evidencia_archivo)
        params = (
            data['id_reporte'],
            data['responsable'],
            fecha,
            data['descripcion'],
            evidencia_archivo,
            evidencia_nombre,
            evidencia_tipo,
            evidencia_tamaño,
            data.get('estado', 'pendiente'),
            int(data.get('validado', 0) or 0)
        )
        query = '''
            INSERT INTO seguimiento_evidencias (
                id_reporte, responsable, fecha_seguimiento,
                descripcion, evidencia_archivo, evidencia_nombre,
                evidencia_tipo, evidencia_tamaño, estado, validado
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        '''
        # Log de los parámetros (sin incluir el archivo binario por ser muy grande)
        params_log = list(params)
        if params_log[4]:
            params_log[4] = f"<archivo_binario_{len(params_log[4])}_bytes>"
        logging.info(f'[seguimiento_model.crear_seguimiento] Query: {query.strip()}')
        logging.info(f'[seguimiento_model.crear_seguimiento] Params: {params_log}')
        with get_cursor(dict_cursor=True) as cursor:
            cursor.execute(query, params)
            new_id = cursor.lastrowid
            cursor.execute("""
                SELECT id_seguimiento, id_reporte, responsable, fecha_seguimiento,
                       descripcion, evidencia_nombre, evidencia_tipo, evidencia_tamaño,
                       estado, validado
                FROM seguimiento_evidencias 
                WHERE id_seguimiento = %s
            """, (new_id,))
            row = cursor.fetchone()
        return row
    except Exception as e:
        logging.error(f'[seguimiento_model.crear_seguimiento] Error: {e}')
        logging.error(f'[seguimiento_model.crear_seguimiento] Tipo de error: {type(e).__name__}')
        logging.error(f'[seguimiento_model.crear_seguimiento] Data recibida: {[k for k in data.keys()]}')
        print('Error crear_seguimiento:', e)
        return None

def listar_seguimientos():
    """Lista seguimientos sin incluir el archivo binario"""
    try:
        with get_cursor(dict_cursor=True) as cursor:
            cursor.execute("""
                SELECT id_seguimiento, id_reporte, responsable, fecha_seguimiento,
                       descripcion, evidencia_nombre, evidencia_tipo, evidencia_tamaño,
                       estado, validado
                FROM seguimiento_evidencias 
                ORDER BY fecha_seguimiento DESC
            """)
            rows = cursor.fetchall()
        return rows
    except Exception as e:
        print('Error listar_seguimientos:', e)
        return []

def obtener_seguimiento(id):
    """Obtiene seguimiento sin archivo binario"""
    try:
        with get_cursor(dict_cursor=True) as cursor:
            cursor.execute("""
                SELECT id_seguimiento, id_reporte, responsable, fecha_seguimiento,
                       descripcion, evidencia_nombre, evidencia_tipo, evidencia_tamaño,
                       estado, validado
                FROM seguimiento_evidencias 
                WHERE id_seguimiento = %s
            """, (id,))
            row = cursor.fetchone()
        return row
    except Exception as e:
        print('Error obtener_seguimiento:', e)
        return None

def obtener_archivo_evidencia(id_seguimiento):
    """
    Obtener los datos del archivo de evidencia
    """
    try:
        logging.info(f'[model.seguimiento] Obteniendo archivo evidencia para ID: {id_seguimiento}')
        with get_cursor(dict_cursor=True) as cursor:
            query = """
                SELECT evidencia_archivo, evidencia_nombre, evidencia_tipo, evidencia_tamaño
                FROM seguimiento_evidencias 
                WHERE id_seguimiento = %s AND evidencia_archivo IS NOT NULL
            """
            cursor.execute(query, (id_seguimiento,))
            result = cursor.fetchone()
            if result:
                logging.info(f'[model.seguimiento] Archivo encontrado - Nombre: {result["evidencia_nombre"]}, Tipo: {result["evidencia_tipo"]}, Tamaño DB: {result["evidencia_tamaño"]}')
                return {
                    'evidencia_archivo': result['evidencia_archivo'],
                    'evidencia_nombre': result['evidencia_nombre'],
                    'evidencia_tipo': result['evidencia_tipo'], 
                    'evidencia_tamano': result['evidencia_tamaño']
                }
            else:
                logging.warning(f'[model.seguimiento] No se encontró evidencia para ID: {id_seguimiento}')
                return None
    except Exception as e:
        logging.exception(f'[model.seguimiento] Error al obtener evidencia: {e}')
        return None

def actualizar_seguimiento(id, data):
    """
    Actualiza campos permitidos incluyendo archivo
    """
    try:
        allowed = {
            'id_reporte': 'id_reporte',
            'responsable': 'responsable',
            'fecha_seguimiento': 'fecha_seguimiento',
            'descripcion': 'descripcion',
            'estado': 'estado',
            'validado': 'validado'
        }
        fields = []
        params = []
        # Campos regulares
        for k, col in allowed.items():
            if k in data:
                fields.append(f"{col} = %s")
                params.append(data[k])
        # Manejar archivo si se proporciona
        if 'evidencia_archivo' in data and data['evidencia_archivo']:
            evidencia_archivo = base64.b64decode(data['evidencia_archivo'])
            evidencia_nombre = data.get('evidencia_nombre', 'archivo')
            evidencia_tipo = data.get('evidencia_tipo', 'application/octet-stream')
            evidencia_tamaño = len(evidencia_archivo)
            fields.extend([
                'evidencia_archivo = %s',
                'evidencia_nombre = %s', 
                'evidencia_tipo = %s',
                'evidencia_tamaño = %s'
            ])
            params.extend([evidencia_archivo, evidencia_nombre, evidencia_tipo, evidencia_tamaño])
        if not fields:
            return None
        params.append(id)
        sql = "UPDATE seguimiento_evidencias SET " + ", ".join(fields) + " WHERE id_seguimiento = %s"
        with get_cursor() as cursor:
            cursor.execute(sql, tuple(params))
        return obtener_seguimiento(id)
    except Exception as e:
        print('Error actualizar_seguimiento:', e)
        return None

def eliminar_seguimiento(id):
    try:
        with get_cursor() as cursor:
            cursor.execute("DELETE FROM seguimiento_evidencias WHERE id_seguimiento = %s", (id,))
            affected = cursor.rowcount
        return affected > 0
    except Exception as e:
        print('Error eliminar_seguimiento:', e)
        return False

def actualizar_estatus_reporte(id_reporte, nuevo_estatus):
    """
    Actualiza el estatus en reportes_incidencias. Devuelve True si se actualizó.
    """
    try:
        with get_cursor() as cursor:
            cursor.execute("UPDATE reportes_incidencias SET estatus = %s WHERE id_reporte = %s", (nuevo_estatus, id_reporte))
            affected = cursor.rowcount
        return affected > 0
    except Exception as e:
        print('Error actualizar_estatus_reporte:', e)
        return False


def actualizar_estatus(id_reporte, nuevo_estatus):
    """
    Actualiza el campo 'estatus' en reportes_incidencias.
    Retorna True si se actualizó (filas afectadas > 0), False en caso contrario.
    """
    try:
        sql = "UPDATE reportes_incidencias SET estatus = %s WHERE id_reporte = %s"
        with get_cursor() as cursor:
            cursor.execute(sql, (nuevo_estatus, id_reporte))
            affected = cursor.rowcount
        logging.info(f'[reportes_model.actualizar_estatus] id={id_reporte} affected={affected}')
        return affected > 0
    except Exception as e:
        logging.error(f'[reportes_model.actualizar_estatus] error: {e}')
        return False

def obtener_seguimientos_reporte(id_reporte):
    """
    Obtener todos los seguimientos de un reporte específico
    """
    try:
        logging.info(f'[model.seguimiento] Obteniendo seguimientos para reporte: {id_reporte}')
        with get_cursor() as cursor:
            query = """
                SELECT id_seguimiento, id_reporte, responsable, descripcion, fecha_seguimiento, 
                       estado, evidencia_nombre, evidencia_tipo, evidencia_tamaño
                FROM seguimiento_evidencias 
                WHERE id_reporte = %s 
                ORDER BY fecha_seguimiento DESC
            """
            cursor.execute(query, (id_reporte,))
            results = cursor.fetchall()
            seguimientos = []
            for row in results:
                seguimiento = {
                    'id': row[0],
                    'id_reporte': row[1],
                    'responsable': row[2],
                    'descripcion': row[3],
                    'fecha_seguimiento': row[4],
                    'estado': row[5],
                    'evidencia_nombre': row[6],
                    'evidencia_tipo': row[7],
                    'evidencia_tamano': row[8]
                }
                seguimientos.append(seguimiento)
        logging.info(f'[model.seguimiento] Encontrados {len(seguimientos)} seguimientos para reporte {id_reporte}')
        return seguimientos
    except Exception as e:
        logging.exception(f'[model.seguimiento] Error al obtener seguimientos: {e}')
        return []