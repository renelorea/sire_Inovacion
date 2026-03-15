#!/usr/bin/env python3
"""
Script para diagnosticar y corregir problemas de "Too many open files"
"""
import os
import subprocess
import sys
import resource

def check_current_limits():
    """Verificar límites actuales del sistema"""
    print("=== LÍMITES ACTUALES ===")
    
    # Límite actual de archivos abiertos
    soft_limit, hard_limit = resource.getrlimit(resource.RLIMIT_NOFILE)
    print(f"Límite soft de archivos abiertos: {soft_limit}")
    print(f"Límite hard de archivos abiertos: {hard_limit}")
    
    # Verificar con ulimit
    try:
        result = subprocess.run(['ulimit', '-n'], shell=True, capture_output=True, text=True)
        print(f"ulimit -n: {result.stdout.strip()}")
    except:
        print("No se pudo ejecutar ulimit -n")

def count_open_files():
    """Contar archivos actualmente abiertos por el proceso"""
    try:
        pid = os.getpid()
        if sys.platform == 'darwin':  # macOS
            result = subprocess.run(['lsof', '-p', str(pid)], capture_output=True, text=True)
            if result.returncode == 0:
                lines = result.stdout.split('\n')
                count = len([line for line in lines if line.strip()])
                print(f"Archivos abiertos por este proceso: {count}")
            else:
                print("No se pudo ejecutar lsof")
        else:  # Linux
            fd_dir = f"/proc/{pid}/fd"
            if os.path.exists(fd_dir):
                count = len(os.listdir(fd_dir))
                print(f"File descriptors abiertos: {count}")
            else:
                print("No se pudo acceder a /proc/pid/fd")
    except Exception as e:
        print(f"Error contando archivos abiertos: {e}")

def suggest_fixes():
    """Sugerir correcciones"""
    print("\n=== SOLUCIONES SUGERIDAS ===")
    
    soft_limit, hard_limit = resource.getrlimit(resource.RLIMIT_NOFILE)
    
    if soft_limit < 1024:
        print("🔧 El límite soft es muy bajo. Ejecutar:")
        print("   ulimit -n 4096")
        print("   O agregar al ~/.bashrc o ~/.zshrc:")
        print("   ulimit -n 4096")
    
    print("\n🔧 Para macOS, agregar a ~/.zshrc o ~/.bash_profile:")
    print("   ulimit -n 4096")
    
    print("\n🔧 Para cambio permanente en macOS, crear/editar:")
    print("   /etc/launchd.conf")
    print("   limit maxfiles 4096 unlimited")
    
    print("\n🔧 En el código Python, usar context managers:")
    print("   with get_cursor() as cursor:")
    print("       # operaciones de base de datos")
    
    print("\n🔧 Reiniciar el servidor Flask después de estos cambios")

def increase_limits():
    """Intentar aumentar los límites del proceso actual"""
    try:
        soft_limit, hard_limit = resource.getrlimit(resource.RLIMIT_NOFILE)
        
        # Intentar aumentar el límite soft al máximo del hard
        new_soft = min(4096, hard_limit)
        resource.setrlimit(resource.RLIMIT_NOFILE, (new_soft, hard_limit))
        
        print(f"✅ Límite aumentado de {soft_limit} a {new_soft}")
        return True
    except Exception as e:
        print(f"❌ No se pudo aumentar el límite: {e}")
        return False

if __name__ == "__main__":
    print("🔍 DIAGNÓSTICO DE ARCHIVOS ABIERTOS")
    print("=" * 50)
    
    check_current_limits()
    print()
    count_open_files()
    print()
    
    # Intentar aumentar límites
    if increase_limits():
        print()
        check_current_limits()
    
    suggest_fixes()
    
    print("\n" + "=" * 50)
    print("💡 Para aplicar cambios permanentes, reinicia el terminal y el servidor")