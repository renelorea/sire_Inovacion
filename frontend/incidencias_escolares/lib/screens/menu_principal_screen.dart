import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/global.dart';
import 'login_screen.dart';

class MenuPrincipalScreen extends StatefulWidget {
  @override
  _MenuPrincipalScreenState createState() => _MenuPrincipalScreenState();
}

class _MenuPrincipalScreenState extends State<MenuPrincipalScreen> {
  bool _loading = true;
  List<_OpcionMenu> _opciones = [];
  String _rol = '';
  List<String> _permisos = [];

  @override
  void initState() {
    super.initState();
    if (usuarioRol != null && usuarioRol.toString().isNotEmpty) {
      _rol = usuarioRol!;
      _permisos = _permisosFromRol(_rol);
      developer.log('Rol obtenido desde login: $_rol', name: 'MenuPrincipal');
      _construirOpcionesSegunPermisos();
      developer.log('Opciones iniciales: ${_opciones.map((o) => o.titulo).toList()}', name: 'MenuPrincipal');
      _loading = false;
    } else {
      _cargarPerfil();
    }
  }

  List<String> _permisosFromRol(String rol) {
    final r = rol.toLowerCase();
    if (r == 'admin' || r == 'administrativo' || r == 'manage_all') {
      return ['manage_all', 'view_incidencias'];
    }
    return ['view_incidencias'];
  }

  Future<void> _cargarPerfil() async {
    try {
      final url = Uri.parse('$apiBaseUrl/profile');
      final resp = await http.get(url, headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      });
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _rol = (data['rol'] ?? '').toString();
        final perms = data['permisos'];
        if (perms is List) {
          _permisos = perms.map((e) => e.toString()).toList();
        } else {
          _permisos = _permisosFromRol(_rol);
        }
        developer.log('Perfil cargado desde API: rol=$_rol, permisos=$_permisos', name: 'MenuPrincipal');
      } else {
        _permisos = ['view_incidencias'];
        developer.log('Fallo al cargar perfil (status ${resp.statusCode}), usando fallback permisos', name: 'MenuPrincipal');
      }
    } catch (e, st) {
      developer.log('Error al cargar perfil: $e\n$st', name: 'MenuPrincipal');
      _permisos = ['view_incidencias'];
    } finally {
      _construirOpcionesSegunPermisos();
      developer.log('Opciones finales: ${_opciones.map((o) => o.titulo).toList()}', name: 'MenuPrincipal');
      setState(() => _loading = false);
    }
  }

  void _construirOpcionesSegunPermisos() {
    final todas = [
      _OpcionMenu('Usuarios', Icons.person, '/usuarios'),
      _OpcionMenu('Alumnos', Icons.school, '/alumnos'),
      _OpcionMenu('Grupos', Icons.group, '/grupos'),
      _OpcionMenu('Tipos de Incidencia', Icons.report, '/tipos_reporte'),
      _OpcionMenu('Incidencias', Icons.assignment, '/reportes'),
      _OpcionMenu('Reporte Incidencias', Icons.insert_drive_file_outlined, '/reporte_incidencias'),
    ];
    // opción visible para todos: acceso a la pantalla de consulta/exportación de reportes
    final soloIncidencias = [
      _OpcionMenu('Incidencias', Icons.assignment, '/reportes'),
      _OpcionMenu('Reporte Incidencias', Icons.insert_drive_file_outlined, '/reporte_incidencias'),
    ];

    if (_permisos.any((p) => p.toLowerCase() == 'manage_all' || p.toLowerCase() == 'admin')) {
      _opciones = todas;
    } else {
      _opciones = soloIncidencias;
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Deseas cerrar la sesión actual?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Cerrar')),
        ],
      ),
    );
    if (confirmed == true) _performLogout();
  }

  void _performLogout() {
    developer.log('Usuario con rol=$_rol cerrando sesión', name: 'MenuPrincipal');
    // Limpiar todas las variables globales de sesión
    jwtToken = null;
    usuarioRol = null;
    notasUsuario = null;
    usuarioId = null;
    usuarioNombreCompleto = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con fondo para asegurar legibilidad del texto y botones
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 2,
        titleSpacing: 0,
        title: Stack(
          alignment: Alignment.center,
          children: [
            // logo a la izquierda
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Image.asset(
                  'assets/images/headerc2.png',
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => SizedBox(width: 40, height: 40),
                ),
              ),
            ),
            // título centrado (ahora en posición fija)
            Positioned(
              left: 72.0, // <-- ajusta este valor para mover el texto a la derecha/izquierda
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  'Sistema de Incidencias Escolares',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo full-screen desde assets
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(color: Colors.white),
              ),
            ),

            // Overlay para mejorar contraste
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.35))),

            // Contenido encima del fondo
            Column(
              children: [
                // Encabezado eliminado: se quitó Image.asset('assets/images/headerc2.png')
                SizedBox(height: 8),

                // Grid / carga en Expanded
                Expanded(
                  child: _loading
                      ? Center(child: CircularProgressIndicator())
                      : GridView.count(
                          crossAxisCount: 2,
                          padding: EdgeInsets.all(16),
                          children: _opciones.map((opcion) {
                            return Card(
                              color: Colors.white.withOpacity(0.85),
                              child: InkWell(
                                onTap: () => Navigator.pushNamed(context, opcion.ruta),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(opcion.icono, size: 48, color: Colors.green[700]),
                                    SizedBox(height: 10),
                                    Text(opcion.titulo, style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionMenu {
  final String titulo;
  final IconData icono;
  final String ruta;

  _OpcionMenu(this.titulo, this.icono, this.ruta);
}
