from flask_bcrypt import generate_password_hash, check_password_hash

def encriptar_contraseña(plain_text):
    return generate_password_hash(plain_text).decode('utf-8')

def verificar_contraseña(plain_text, hashed):
    return check_password_hash(hashed, plain_text)
