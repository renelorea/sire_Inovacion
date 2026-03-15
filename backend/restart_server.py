#!/usr/bin/env python3
"""
Script para limpiar el servidor y reiniciarlo correctamente
"""
import os
import signal
import subprocess
import sys
import time

def find_flask_processes():
    """Encontrar procesos de Flask corriendo"""
    try:
        # Buscar procesos Python que ejecuten app.py
        result = subprocess.run(
            ['pgrep', '-f', 'app.py'],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            pids = result.stdout.strip().split('\n')
            return [int(pid) for pid in pids if pid.strip()]
        return []
    except:
        return []

def kill_flask_processes():
    """Terminar procesos de Flask existentes"""
    pids = find_flask_processes()
    
    if not pids:
        print("No se encontraron procesos de Flask corriendo")
        return
    
    print(f"Encontrados procesos Flask: {pids}")
    
    for pid in pids:
        try:
            print(f"Terminando proceso {pid}...")
            os.kill(pid, signal.SIGTERM)
            time.sleep(2)
            
            # Verificar si sigue corriendo
            try:
                os.kill(pid, 0)  # No mata, solo verifica
                print(f"Proceso {pid} aún corriendo, usando SIGKILL...")
                os.kill(pid, signal.SIGKILL)
            except OSError:
                print(f"Proceso {pid} terminado correctamente")
        except OSError as e:
            print(f"Error terminando proceso {pid}: {e}")

def clean_log_files():
    """Limpiar archivos de log grandes"""
    try:
        if os.path.exists('app.log'):
            size = os.path.getsize('app.log')
            if size > 50*1024*1024:  # Si es mayor a 50MB
                print(f"Limpiando app.log ({size/1024/1024:.1f}MB)")
                with open('app.log', 'w') as f:
                    f.write('')
    except Exception as e:
        print(f"Error limpiando logs: {e}")

def start_flask():
    """Iniciar Flask en el fondo"""
    print("Iniciando servidor Flask...")
    try:
        # Activar entorno virtual y ejecutar app
        subprocess.Popen(
            ['python3', 'app.py'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        print("✅ Servidor Flask iniciado")
        return True
    except Exception as e:
        print(f"❌ Error iniciando Flask: {e}")
        return False

if __name__ == "__main__":
    print("🔧 LIMPIANDO Y REINICIANDO SERVIDOR FLASK")
    print("=" * 50)
    
    # 1. Terminar procesos existentes
    kill_flask_processes()
    time.sleep(3)
    
    # 2. Limpiar logs
    clean_log_files()
    
    # 3. Crear directorio de logs si no existe
    if not os.path.exists('logs'):
        os.makedirs('logs')
        print("📁 Directorio 'logs' creado")
    
    # 4. Reiniciar servidor
    if start_flask():
        print("\n✅ Servidor reiniciado correctamente")
        print("🌐 Debería estar disponible en http://localhost:5000")
    else:
        print("\n❌ Error reiniciando servidor")
        
    print("\n💡 Monitorea los logs en:")
    print("   tail -f logs/app.log")
    print("\n💡 Si sigues teniendo problemas, reinicia completamente:")
    print("   killall python3")
    print("   python3 app.py")