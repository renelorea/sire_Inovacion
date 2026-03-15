from flask import jsonify, current_app
from database.cursor_manager import get_cursor
from datetime import datetime

def alta_reporte(datos):
    try:
        with get_cursor() as cursor:
            # Generar folio si no viene en los datos: formato REP-Año-consecutivo
            folio = datos.get('folio')
            if not folio or str(folio).strip() == '':
                year = datetime.now().year
                like_pattern = f"REP-{year}-%"
                cursor.execute(
                    "SELECT MAX(CAST(SUBSTRING_INDEX(folio,'-',-1) AS UNSIGNED)) FROM reportes_incidencias WHERE folio LIKE %s",
                    (like_pattern,)
                )
                row = cursor.fetchone()
                maxn = row[0] if row and row[0] is not None else 0
                folio = f"REP-{year}-{maxn + 1}"

            cursor.execute("""
                INSERT INTO reportes_incidencias (
                    folio, id_alumno, id_usuario_que_reporta, id_tipo_reporte,
                    descripcion_hechos, acciones_tomadas, fecha_incidencia, estatus
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                folio,
                datos['id_alumno'],
                datos['id_usuario_que_reporta'],
                datos['id_tipo_reporte'],
                datos['descripcion_hechos'],
                datos.get('acciones_tomadas'),
                datos['fecha_incidencia'],
                datos.get('estatus', 'Abierto')
            ))
        return jsonify({"msg": "Reporte creado", "folio": folio}), 201
    except Exception as e:
        current_app.logger.exception("Error en alta_reporte: %s", e)
        return jsonify({"error": "Error interno al crear reporte", "detail": str(e)}), 500

def baja_reporte(id):
    with get_cursor() as cursor:
        cursor.execute("DELETE FROM reportes_incidencias WHERE id_reporte = %s", (id,))
    return jsonify({"msg": "Reporte eliminado"}), 200

def cambio_reporte(id, datos):
    with get_cursor() as cursor:
        cursor.execute("""
            UPDATE reportes_incidencias SET
                descripcion_hechos=%s,
                acciones_tomadas=%s,
                estatus=%s
            WHERE id_reporte = %s
        """, (
            datos['descripcion_hechos'],
            datos.get('acciones_tomadas'),
            datos['estatus'],
            id
        ))
    return jsonify({"msg": "Reporte actualizado"}), 200

def find_all_reportes():
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("""
        SELECT r.*, 
               -- Alumno y grupo
               a.id_alumno, a.matricula, a.nombres AS alumno_nombre, a.apellido_paterno AS alumno_apaterno, a.apellido_materno AS alumno_amaterno,
               a.fecha_nacimiento, g.id_grupo, g.grado AS grupo_grado, g.Descripcion AS grupo_nombre, g.ciclo_escolar,
               
               -- Usuario que reporta
               u.id_usuario, u.nombres AS usuario_nombre, u.apellido_paterno AS usuario_apaterno, u.apellido_materno AS usuario_amaterno,
               u.email AS email, u.rol AS usuario_rol, u.activo AS usuario_activo,
               
               -- Tipo de reporte
               t.id_tipo_reporte, t.nombre AS tipo_nombre, t.descripcion AS tipo_descripcion, t.gravedad AS tipo_gravedad
        FROM reportes_incidencias r
        JOIN alumnos a ON r.id_alumno = a.id_alumno
        JOIN grupos g ON a.id_grupo = g.id_grupo
        JOIN usuarios u ON r.id_usuario_que_reporta = u.id_usuario
        JOIN tipos_reporte t ON r.id_tipo_reporte = t.id_tipo_reporte
    """)
    # Proteger contra error de NoneType en fetchall()
    if hasattr(cursor, '_rows') and cursor._rows is None:
        rows = []
    else:
        rows = cursor.fetchall()

    reportes = []
    for r in rows:
        reporte = {
            "id_reporte": r["id_reporte"],
            "folio": r["folio"],
            "descripcion_hechos": r["descripcion_hechos"],
            "acciones_tomadas": r["acciones_tomadas"],
            "fecha_incidencia": r["fecha_incidencia"],
            "fecha_creacion": r["fecha_creacion"],
            "estatus": r["estatus"],
            "alumno": {
                "id_alumno": r["id_alumno"],
                "matricula": r["matricula"],
                "nombre": r["alumno_nombre"],
                "apellido_paterno": r["alumno_apaterno"],
                "apellido_materno": r["alumno_amaterno"],
                "fecha_nacimiento": r["fecha_nacimiento"],
                "grupo": {
                    "id_grupo": r["id_grupo"],
                    "grado": r["grupo_grado"],
                    "grupo": r["grupo_nombre"],
                    "ciclo_escolar": r["ciclo_escolar"]
                }
            },
            "usuario": {
                "id_usuario": r["id_usuario"],
                "nombre": r["usuario_nombre"],
                "apellido_paterno": r["usuario_apaterno"],
                "apellido_materno": r["usuario_amaterno"],
                "email": r["email"],
                "rol": r["usuario_rol"],
                "activo": r["usuario_activo"]
            },
            "tipo_reporte": {
                "id_tipo_reporte": r["id_tipo_reporte"],
                "nombre": r["tipo_nombre"],
                "descripcion": r["tipo_descripcion"],
                "gravedad": r["tipo_gravedad"]
            }
        }
        reportes.append(reporte)

    return jsonify(reportes), 200


def find_reporte_by_id(id):
    with get_cursor(dict_cursor=True) as cursor:
        cursor.execute("""
            SELECT r.*, 
                   -- Alumno y grupo
                   a.id_alumno, a.matricula, a.nombres AS alumno_nombre, a.apellido_paterno AS alumno_apaterno, a.apellido_materno AS alumno_amaterno,
                   a.fecha_nacimiento, g.id_grupo, g.grado AS grupo_grado, g.Descripcion AS grupo_nombre, g.ciclo_escolar,
                   
                   -- Usuario que reporta
                   u.id_usuario, u.nombres AS usuario_nombre, u.apellido_paterno AS usuario_apatero, u.apellido_materno AS usuario_amaterno,
                   u.email AS email, u.rol AS usuario_rol, u.activo AS usuario_activo,
                   
                   -- Tipo de reporte
                   t.id_tipo_reporte, t.nombre AS tipo_nombre, t.descripcion AS tipo_descripcion, t.gravedad AS tipo_gravedad
            FROM reportes_incidencias r
            JOIN alumnos a ON r.id_alumno = a.id_alumno
            JOIN grupos g ON a.id_grupo = g.id_grupo
            JOIN usuarios u ON r.id_usuario_que_reporta = u.id_usuario
            JOIN tipos_reporte t ON r.id_tipo_reporte = t.id_tipo_reporte
            WHERE r.id_reporte = %s
        """, (id,))
        r = cursor.fetchone()

    if not r:
        return jsonify({"msg": "Reporte no encontrado"}), 404

    reporte = {
        "id_reporte": r["id_reporte"],
        "folio": r["folio"],
        "descripcion_hechos": r["descripcion_hechos"],
        "acciones_tomadas": r["acciones_tomadas"],
        "fecha_incidencia": r["fecha_incidencia"],
        "fecha_creacion": r["fecha_creacion"],
        "estatus": r["estatus"],
        "alumno": {
            "id_alumno": r["id_alumno"],
            "matricula": r["matricula"],
            "nombre": r["alumno_nombre"],
            "apellido_paterno": r["alumno_apaterno"],
            "apellido_materno": r["alumno_amaterno"],
            "fecha_nacimiento": r["fecha_nacimiento"],
            "grupo": {
                "id_grupo": r["id_grupo"],
                "grado": r["grupo_grado"],
                "grupo": r["grupo_nombre"],
                "ciclo_escolar": r["ciclo_escolar"]
            }
        },
        "usuario": {
            "id_usuario": r["id_usuario"],
            "nombre": r["usuario_nombre"],
            "apellido_paterno": r["usuario_apatero"],
            "apellido_materno": r["usuario_amaterno"],
            "email": r["email"],
            "rol": r["usuario_rol"],
            "activo": r["usuario_activo"]
        },
        "tipo_reporte": {
            "id_tipo_reporte": r["id_tipo_reporte"],
            "nombre": r["tipo_nombre"],
            "descripcion": r["tipo_descripcion"],
            "gravedad": r["tipo_gravedad"]
        }
    }

    return jsonify(reporte), 200

def find_reportes_filtered(grupo=None, nombre=None, apellido_paterno=None, apellido_materno=None):
    """
    Busca reportes en reportes_incidencias filtrando opcionalmente por:
      - grupo: id de grupo (numérico) o texto en la descripción del grupo
      - nombre: búsqueda parcial en alumnos.nombres
      - apellido_paterno: búsqueda parcial en alumnos.apellido_paterno
      - apellido_materno: búsqueda parcial en alumnos.apellido_materno
    Devuelve la misma estructura JSON que find_all_reportes.
    """
    with get_cursor(dict_cursor=True) as cursor:
        sql = """
            SELECT r.*, 
                   a.id_alumno, a.matricula, a.nombres AS alumno_nombre, a.apellido_paterno AS alumno_apaterno, a.apellido_materno AS alumno_amaterno,
                   a.fecha_nacimiento, g.id_grupo, g.grado AS grupo_grado, g.Descripcion AS grupo_nombre, g.ciclo_escolar,
                   u.id_usuario, u.nombres AS usuario_nombre, u.apellido_paterno AS usuario_apaterno, u.apellido_materno AS usuario_amaterno,
                   u.email AS email, u.rol AS usuario_rol, u.activo AS usuario_activo,
                   t.id_tipo_reporte, t.nombre AS tipo_nombre, t.descripcion AS tipo_descripcion, t.gravedad AS tipo_gravedad
            FROM reportes_incidencias r
            JOIN alumnos a ON r.id_alumno = a.id_alumno
            LEFT JOIN grupos g ON a.id_grupo = g.id_grupo
            LEFT JOIN usuarios u ON r.id_usuario_que_reporta = u.id_usuario
            LEFT JOIN tipos_reporte t ON r.id_tipo_reporte = t.id_tipo_reporte
            WHERE 1=1
        """
        params = []

        if grupo:
            if str(grupo).isdigit():
                sql += " AND g.id_grupo = %s"
                params.append(int(grupo))
            else:
                sql += " AND LOWER(g.Descripcion) LIKE %s"
                params.append(f"%{grupo.lower()}%")

        if nombre:
            sql += " AND LOWER(a.nombres) LIKE %s"
            params.append(f"%{nombre.lower()}%")

        if apellido_paterno:
            sql += " AND LOWER(a.apellido_paterno) LIKE %s"
            params.append(f"%{apellido_paterno.lower()}%")

        if apellido_materno:
            sql += " AND LOWER(a.apellido_materno) LIKE %s"
            params.append(f"%{apellido_materno.lower()}%")

        sql += " ORDER BY r.fecha_incidencia DESC"

        cursor.execute(sql, tuple(params))
        rows = cursor.fetchall()

    reportes = []
    for r in rows:
        reporte = {
            "id_reporte": r.get("id_reporte"),
            "folio": r.get("folio"),
            "descripcion_hechos": r.get("descripcion_hechos"),
            "acciones_tomadas": r.get("acciones_tomadas"),
            "fecha_incidencia": r.get("fecha_incidencia"),
            "fecha_creacion": r.get("fecha_creacion"),
            "estatus": r.get("estatus"),
            "alumno": {
                "id_alumno": r.get("id_alumno"),
                "matricula": r.get("matricula"),
                "nombre": r.get("alumno_nombre"),
                "apellido_paterno": r.get("alumno_apaterno"),
                "apellido_materno": r.get("alumno_amaterno"),
                "fecha_nacimiento": r.get("fecha_nacimiento"),
                "grupo": {
                    "id_grupo": r.get("id_grupo"),
                    "grado": r.get("grupo_grado"),
                    "grupo": r.get("grupo_nombre"),
                    "ciclo_escolar": r.get("ciclo_escolar")
                }
            },
            "usuario": {
                "id_usuario": r.get("id_usuario"),
                "nombre": r.get("usuario_nombre"),
                "apellido_paterno": r.get("usuario_apaterno"),
                "apellido_materno": r.get("usuario_amaterno"),
                "email": r.get("email"),
                "rol": r.get("usuario_rol"),
                "activo": r.get("usuario_activo")
            },
            "tipo_reporte": {
                "id_tipo_reporte": r.get("id_tipo_reporte"),
                "nombre": r.get("tipo_nombre"),
                "descripcion": r.get("tipo_descripcion"),
                "gravedad": r.get("tipo_gravedad")
            }
        }
        reportes.append(reporte)

    return jsonify(reportes), 200
