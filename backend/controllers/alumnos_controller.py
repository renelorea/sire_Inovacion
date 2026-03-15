from flask import Blueprint, request, jsonify, make_response
from flask_jwt_extended import jwt_required
from models.alumnos_model import alta_alumno, baja_alumno, cambio_alumno, find_all_alumnos, find_alumno_by_id, importar_alumnos
import logging

alumnos_bp = Blueprint('alumnos_bp', __name__)

@alumnos_bp.route('/api/alumnos', methods=['POST'])
@jwt_required()
def alta():
    """
    Alta de alumno
    ---
    tags:
      - Alumnos
    security:
      - Bearer: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - matricula
              - nombres
              - apellido_paterno
              - id_grupo
            properties:
              matricula:
                type: string
              nombres:
                type: string
              apellido_paterno:
                type: string
              apellido_materno:
                type: string
              fecha_nacimiento:
                type: string
                format: date
              id_grupo:
                type: integer
    responses:
      201:
        description: Alumno creado exitosamente
    """
    return alta_alumno(request.json)

@alumnos_bp.route('/api/alumnos/<int:id>', methods=['DELETE'])
@jwt_required()
def baja(id):
    """
    Eliminar alumno por ID
    ---
    tags:
      - Alumnos
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
        description: Alumno eliminado
    """
    return baja_alumno(id)

@alumnos_bp.route('/api/alumnos/<int:id>', methods=['PUT'])
@jwt_required()
def cambio(id):
    """
    Actualizar alumno
    ---
    tags:
      - Alumnos
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
              fecha_nacimiento:
                type: string
                format: date
              id_grupo:
                type: integer
    responses:
      200:
        description: Alumno actualizado
    """
    return cambio_alumno(id, request.json)

@alumnos_bp.route('/api/alumnos', methods=['GET'])
@jwt_required()
def listar_todos():
    """
    Listar todos los alumnos
    ---
    tags:
      - Alumnos
    security:
      - Bearer: []
    responses:
      200:
        description: Lista de alumnos
    """
    return find_all_alumnos()

@alumnos_bp.route('/api/alumnos/<int:id>', methods=['GET'])
@jwt_required()
def obtener_por_id(id):
    """
    Obtener alumno por ID
    ---
    tags:
      - Alumnos
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
        description: Alumno encontrado
      404:
        description: Alumno no encontrado
    """
    return find_alumno_by_id(id)

@alumnos_bp.route('/api/importar-alumnos', methods=['POST'])
@jwt_required()
def importar_alumnos_route():
    """
    Importar alumnos desde un archivo Excel (.xls/.xlsx).
    Espera un multipart/form-data con el campo 'file'.
    """
    if 'file' not in request.files:
        return make_response(jsonify({'error': 'Archivo no proporcionado (campo "file")'}), 400)

    f = request.files['file']
    if f.filename == '':
        return make_response(jsonify({'error': 'Nombre de archivo vacío'}), 400)

    try:
        import io
        import pandas as pd  # requiere pandas + openpyxl en el entorno
        # pandas puede leer directamente el stream
        stream = io.BytesIO(f.read())
        df = pd.read_excel(stream)
        records = df.fillna('').to_dict(orient='records')  # normaliza NaN -> ''
        inserted = importar_alumnos(records)
        logging.info(f'[alumnos.import] inserted={inserted} total={len(records)}')
        return jsonify({'inserted': inserted, 'total': len(records)}), 201
    except Exception as e:
        logging.exception('[alumnos.import] error al importar')
        return make_response(jsonify({'error': str(e)}), 500)
