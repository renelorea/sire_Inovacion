import os

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "P3rr1ll01981")
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "R3n31981")
    # Forzar TCP para evitar error de socket /tmp/mysql.sock
    MYSQL_HOST = os.getenv("MYSQL_HOST", "srv734.hstgr.io")
    MYSQL_PORT = int(os.getenv("MYSQL_PORT", 3306))
    MYSQL_USER = os.getenv("MYSQL_USER", "u893431309_usercon")
    MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "NTf^C=f8")
    MYSQL_DB = os.getenv("MYSQL_DB", "u893431309_incidencias")
    MYSQL_CHARSET = os.getenv("MYSQL_CHARSET", "utf8mb4")
