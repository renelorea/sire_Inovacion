
# Conexión directa usando MySQLdb
import MySQLdb
from config import Config

def get_connection():
    return MySQLdb.connect(
        host=Config.MYSQL_HOST,
        port=Config.MYSQL_PORT,
        user=Config.MYSQL_USER,
        passwd=Config.MYSQL_PASSWORD,
        db=Config.MYSQL_DB,
        charset=Config.MYSQL_CHARSET
    )
