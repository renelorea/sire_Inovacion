"""
Manejador de cursores para evitar conexiones abiertas acumuladas
"""
from contextlib import contextmanager
from database.connection import get_connection
from MySQLdb.cursors import DictCursor
import logging

logger = logging.getLogger(__name__)

@contextmanager
def get_cursor(dict_cursor=False):
    """
    Context manager para manejar cursores de MySQL de forma segura.
    Garantiza que el cursor se cierre apropiadamente.
    
    Args:
        dict_cursor (bool): Si True, usa DictCursor
        
    Usage:
        with get_cursor() as cursor:
            cursor.execute("SELECT * FROM tabla")
            result = cursor.fetchall()
    """
    conn = None
    cursor = None
    try:
        conn = get_connection()
        cursor_class = DictCursor if dict_cursor else None
        cursor = conn.cursor(cursor_class)
        yield cursor
        conn.commit()
    except Exception as e:
        logger.error(f"Error en cursor: {e}")
        if conn:
            conn.rollback()
        raise
    finally:
        if cursor:
            try:
                cursor.close()
            except Exception as e:
                logger.warning(f"Error cerrando cursor: {e}")
        if conn:
            try:
                conn.close()
            except Exception as e:
                logger.warning(f"Error cerrando conexión: {e}")

@contextmanager
def get_transaction_cursor(dict_cursor=False):
    """
    Context manager para manejar transacciones con cursores.
    Hace commit automáticamente si no hay errores, rollback si los hay.
    
    Args:
        dict_cursor (bool): Si True, usa DictCursor
        
    Usage:
        with get_transaction_cursor() as cursor:
            cursor.execute("UPDATE tabla SET...")
            # Commit automático si no hay excepciones
    """
    cursor = None
    try:
        cursor_class = DictCursor if dict_cursor else None
        cursor = mysql.connection.cursor(cursor_class)
        yield cursor
        mysql.connection.commit()
    except Exception as e:
        logger.error(f"Error en transacción: {e}")
        if mysql.connection:
            mysql.connection.rollback()
        raise
    finally:
        if cursor:
            try:
                cursor.close()
            except Exception as e:
                logger.warning(f"Error cerrando cursor: {e}")