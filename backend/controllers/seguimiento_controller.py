# controllers/seguimiento_controller.py
from flask import Blueprint, request, jsonify, make_response, send_file, Response
from flask_jwt_extended import jwt_required
from models import seguimiento_model
from models.seguimiento_model import obtener_archivo_evidencia  # 🔧 AGREGAR ESTA LÍNEA
import logging
import base64
import io

seguimiento_bp = Blueprint('seguimiento_bp', __name__)

@seguimiento_bp.route('/api/seguimientos', methods=['POST'])
@jwt_required()
def crear():
    data = request.get_json()
    logging.info(f'[seguimiento.create] payload: {data}')
    if not data:
        logging.warning('[seguimiento.create] payload vacío')
        return make_response(jsonify({'error': 'Payload vacío'}), 400)

    # crear seguimiento
    creado = seguimiento_model.crear_seguimiento(data)
    if not creado:
        logging.error(f'[seguimiento.create] fallo al crear seguimiento, payload={data}')
        return make_response(jsonify({'error': 'No se pudo crear el seguimiento'}), 500)

    logging.info(f'[seguimiento.create] seguimiento creado: {creado}')

    # si el cliente envía nuevo_estatus_reporte, intentar actualizar estatus del reporte
    nuevo_estatus = data.get('nuevo_estatus_reporte')
    if nuevo_estatus:
        id_reporte = data.get('id_reporte') or data.get('idReporte')
        if id_reporte:
            logging.info(f'[seguimiento.create] intentará actualizar estatus del reporte {id_reporte} -> {nuevo_estatus}')
            actualizado = seguimiento_model.actualizar_estatus_reporte(id_reporte, nuevo_estatus)
            if not actualizado:
                logging.warning(f'[seguimiento.create] seguimiento creado pero no se pudo actualizar estatus del reporte id_reporte={id_reporte}')
                # Loguear/retornar advertencia, pero seguimiento ya fue creado
                return make_response(jsonify({
                    'warning': 'Seguimiento creado, pero no se pudo actualizar estatus del reporte',
                    'seguimiento': creado
                }), 201)
            logging.info(f'[seguimiento.create] estatus del reporte {id_reporte} actualizado a "{nuevo_estatus}"')

    return make_response(jsonify(creado), 201)

@seguimiento_bp.route('/api/seguimientos', methods=['GET'])
@jwt_required()
def listar():
    lista = seguimiento_model.listar_seguimientos()
    return make_response(jsonify(lista), 200)

@seguimiento_bp.route('/api/seguimientos/<int:id>', methods=['GET'])
@jwt_required()
def obtener(id):
    seg = seguimiento_model.obtener_seguimiento(id)
    if not seg:
        return make_response(jsonify({'error': 'No encontrado'}), 404)
    return make_response(jsonify(seg), 200)

@seguimiento_bp.route('/api/seguimientos/<int:id>', methods=['PUT'])
@jwt_required()
def actualizar(id):
    data = request.get_json()
    if not data:
        return make_response(jsonify({'error': 'Payload vacío'}), 400)
    actualizado = seguimiento_model.actualizar_seguimiento(id, data)
    if not actualizado:
        return make_response(jsonify({'error': 'No se pudo actualizar'}), 500)
    return make_response(jsonify(actualizado), 200)

@seguimiento_bp.route('/api/seguimientos/<int:id>', methods=['DELETE'])
@jwt_required()
def eliminar(id):
    eliminado = seguimiento_model.eliminar_seguimiento(id)
    if not eliminado:
        return make_response(jsonify({'error': 'No se pudo eliminar'}), 500)
    return make_response(jsonify({'message': 'Eliminado'}), 200)

@seguimiento_bp.route('/api/reportes/<int:id_reporte>/estatus', methods=['PUT'])
@jwt_required()
def actualizar_estatus(id_reporte):
    data = request.get_json() or {}
    logging.info(f'[reportes.actualizar_estatus] id={id_reporte} payload={data}')
    nuevo = data.get('estatus')
    if not nuevo:
        logging.warning('[reportes.actualizar_estatus] falta campo "estatus"')
        return make_response(jsonify({'error': 'Campo "estatus" requerido'}), 400)

    ok = seguimiento_model.actualizar_estatus(id_reporte, nuevo)
    if not ok:
        logging.error(f'[reportes.actualizar_estatus] no se pudo actualizar estatus id={id_reporte}')
        return make_response(jsonify({'error': 'No se pudo actualizar estatus'}), 500)

    logging.info(f'[reportes.actualizar_estatus] estatus actualizado id={id_reporte} -> {nuevo}')
    return make_response(jsonify({'message': 'Estatus actualizado', 'id_reporte': id_reporte, 'estatus': nuevo}), 200)

@seguimiento_bp.route('/api/reportes/<int:id_reporte>/seguimientos', methods=['GET'])
@jwt_required()
def obtener_seguimientos_por_reporte(id_reporte):
    """
    Obtener seguimientos de un reporte específico
    """
    try:
        logging.info(f'[seguimiento.por_reporte] Obteniendo seguimientos para reporte ID: {id_reporte}')
        
        # Llamar al modelo para obtener seguimientos
        seguimientos = seguimiento_model.obtener_seguimientos_reporte(id_reporte)
        
        logging.info(f'[seguimiento.por_reporte] Encontrados {len(seguimientos)} seguimientos')
        
        return make_response(jsonify(seguimientos), 200)
        
    except Exception as e:
        logging.exception(f'[seguimiento.por_reporte] Error: {e}')
        return make_response(jsonify({'error': 'Error interno del servidor'}), 500)

@seguimiento_bp.route('/api/seguimientos/<int:id>/evidencia', methods=['GET'])
@jwt_required()
def descargar_evidencia(id):
    """
    Descarga el archivo de evidencia
    """
    try:
        logging.info(f'[seguimiento.evidencia] Iniciando descarga de evidencia para seguimiento ID: {id}')
        
        # Verificar si la función existe
        if 'obtener_archivo_evidencia' not in globals():
            logging.error(f'[seguimiento.evidencia] Función obtener_archivo_evidencia no encontrada')
            return {"msg": "Error interno: función no encontrada"}, 500
        
        archivo_data = obtener_archivo_evidencia(id)
        
        logging.info(f'[seguimiento.evidencia] Datos obtenidos: {archivo_data is not None}')
        
        if not archivo_data:
            logging.warning(f'[seguimiento.evidencia] No se encontraron datos para seguimiento ID: {id}')
            return {"msg": "Archivo no encontrado"}, 404
            
        if not archivo_data.get('evidencia_archivo'):
            logging.warning(f'[seguimiento.evidencia] No hay archivo de evidencia para seguimiento ID: {id}')
            return {"msg": "Archivo no encontrado"}, 404
        
        # Log de información del archivo
        evidencia_nombre = archivo_data.get('evidencia_nombre', 'sin_nombre')
        evidencia_tipo = archivo_data.get('evidencia_tipo', 'application/octet-stream')
        
        # Verificar si evidencia_archivo es bytes o string
        if isinstance(archivo_data['evidencia_archivo'], str):
            # Si es string, convertir de base64 a bytes
            import base64
            archivo_bytes = base64.b64decode(archivo_data['evidencia_archivo'])
        else:
            # Si ya es bytes
            archivo_bytes = archivo_data['evidencia_archivo']
        
        evidencia_tamano = len(archivo_bytes)
        
        logging.info(f'[seguimiento.evidencia] Archivo encontrado - Nombre: {evidencia_nombre}, Tipo: {evidencia_tipo}, Tamaño: {evidencia_tamano} bytes')
        
        # Verificar que io está importado
        import io
        
        # Crear un objeto de archivo en memoria
        archivo_io = io.BytesIO(archivo_bytes)
        
        logging.info(f'[seguimiento.evidencia] Enviando archivo {evidencia_nombre} de {evidencia_tamano} bytes')
        
        return send_file(
            archivo_io,
            download_name=evidencia_nombre,
            mimetype=evidencia_tipo,
            as_attachment=True
        )
        
    except Exception as e:
        logging.exception(f'[seguimiento.evidencia] Error detallado al descargar archivo para seguimiento ID {id}: {str(e)}')
        logging.error(f'[seguimiento.evidencia] Tipo de error: {type(e).__name__}')
        return {"msg": f"Error al descargar archivo: {str(e)}"}, 500

@seguimiento_bp.route('/api/seguimientos/<int:id>/evidencia/preview', methods=['GET'])
@jwt_required()
def obtener_evidencia_preview(id):
    """
    Obtener evidencia como base64 para preview en la app
    """
    try:
        logging.info(f'[seguimiento.evidencia.preview] Obteniendo preview para seguimiento ID: {id}')
        
        archivo_data = obtener_archivo_evidencia(id)
        
        if not archivo_data or not archivo_data.get('evidencia_archivo'):
            logging.warning(f'[seguimiento.evidencia.preview] No se encontró evidencia para ID: {id}')
            return make_response(jsonify({'error': 'Evidencia no encontrada'}), 404)
        
        # Convertir a base64 si es necesario
        if isinstance(archivo_data['evidencia_archivo'], str):
            evidencia_base64 = archivo_data['evidencia_archivo']
        else:
            import base64
            evidencia_base64 = base64.b64encode(archivo_data['evidencia_archivo']).decode('utf-8')
        
        response_data = {
            'id': id,
            'archivo': evidencia_base64,
            'nombre': archivo_data.get('evidencia_nombre'),
            'tipo': archivo_data.get('evidencia_tipo'),
            'tamano': archivo_data.get('evidencia_tamano')
        }
        
        logging.info(f'[seguimiento.evidencia.preview] Enviando preview - Nombre: {response_data["nombre"]}, Tamaño: {response_data["tamano"]} bytes')
        
        return make_response(jsonify(response_data), 200)
        
    except Exception as e:
        logging.exception(f'[seguimiento.evidencia.preview] Error al obtener preview: {e}')
        return make_response(jsonify({'error': 'Error interno del servidor'}), 500)