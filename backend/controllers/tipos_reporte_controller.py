from flask import Blueprint, request
from flask_jwt_extended import jwt_required
from models.tipos_reporte_model import alta_tipo, baja_tipo, cambio_tipo, find_all_tipos, find_tipo_by_id

tipos_bp = Blueprint('tipos_bp', __name__)

@tipos_bp.route('/api/tipos-reporte', methods=['POST'])
@jwt_required()
def alta():
    """
    Alta de tipo de reporte
    ---
    tags:
      - Tipos de reporte
    security:
      - Bearer: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - nombre
              - gravedad
            properties:
              nombre:
                type: string
              descripcion:
                type: string
              gravedad:
                type: string
                enum: [Leve, Moderada, Grave]
    responses:
      201:
        description: Tipo de reporte creado
    """
    return alta_tipo(request.json)

@tipos_bp.route('/api/tipos-reporte/<int:id>', methods=['DELETE'])
@jwt_required()
def baja(id):
    """
    Eliminar tipo de reporte por ID
    ---
    tags:
      - Tipos de reporte
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
        description: Tipo de reporte eliminado
    """
    return baja_tipo(id)

@tipos_bp.route('/api/tipos-reporte/<int:id>', methods=['PUT'])
@jwt_required()
def cambio(id):
    """
    Actualizar tipo de reporte
    ---
    tags:
      - Tipos de reporte
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
              nombre:
                type: string
              descripcion:
                type: string
              gravedad:
                type: string
                enum: [Leve, Moderada, Grave]
    responses:
      200:
        description: Tipo de reporte actualizado
    """
    return cambio_tipo(id, request.json)

@tipos_bp.route('/api/tipos-reporte', methods=['GET'])
@jwt_required()
def listar_todos():
    """
    Listar todos los tipos de reporte
    ---
    tags:
      - Tipos de reporte
    security:
      - Bearer: []
    responses:
      200:
        description: Lista de tipos de reporte
    """
    return find_all_tipos()

@tipos_bp.route('/api/grupos/<int:id>', methods=['GET'])
@jwt_required()
def obtener_por_id(id):
    """
    Obtener grupo por ID
    ---
    tags:
      - Grupos
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
        description: Grupo encontrado
      404:
        description: Grupo no encontrado
    """
    return find_tipo_by_id(id)