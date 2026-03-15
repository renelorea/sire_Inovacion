import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import 'usuario_form_screen.dart';

class UsuariosScreen extends StatefulWidget {
  @override
  _UsuariosScreenState createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _service = UsuarioService();
  Future<List<Usuario>> _usuarios = Future.value([]);
  List<Usuario> _todos = [];
  final List<String> _roles = ['Todos', 'Profesor', 'Administrador'];
  String _filtroRol = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final lista = await _service.obtenerUsuarios();
    setState(() {
      _todos = lista;
      _aplicarFiltro();
    });
  }

  void _aplicarFiltro() {
    final filtro = _filtroRol?.trim().toLowerCase();
    if (filtro == null || filtro == 'todos') {
      _usuarios = Future.value(_todos);
      return;
    }
    final filtrados = _todos.where((u) {
      final rolUsuario = (u.rol ?? '').trim().toLowerCase();
      return rolUsuario == filtro;
    }).toList();
    _usuarios = Future.value(filtrados);
  }

  void _refrescar() {
    _cargarUsuarios();
  }

  void _eliminar(int id) async {
    await _service.eliminarUsuario(id);
    _cargarUsuarios();
  }

  void _resetearContrasena(Usuario usuario) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resetear Contraseña'),
        content: Text(
          '¿Está seguro de que desea resetear la contraseña de:\n\n'
          '${usuario.nombre} ${usuario.apaterno}\n'
          '${usuario.correo}\n\n'
          'La nueva contraseña será: cecytem@1234'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Resetear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _service.resetearContrasena(usuario.id);
        
        // Mostrar diálogo de éxito
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Contraseña Reseteada'),
            content: Text(
              'La contraseña de ${usuario.nombre} ${usuario.apaterno} '
              'ha sido reseteada exitosamente.\n\n'
              'Nueva contraseña temporal: cecytem@1234\n\n'
              'Informe al usuario para que cambie su contraseña.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        
        _refrescar();
      } catch (e) {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al resetear contraseña: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // flecha de regreso en blanco
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Usuarios', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filtroRol,
                    decoration: InputDecoration(labelText: 'Filtrar por rol'),
                    items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (value) {
                      setState(() {
                        _filtroRol = value!;
                        _aplicarFiltro();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filtroRol = 'Todos';
                      _aplicarFiltro();
                    });
                  },
                  child: Text('Limpiar'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Usuario>>(
              future: _usuarios,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final usuarios = snapshot.data!;
                  return ListView.builder(
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) {
                      final u = usuarios[index];
                      return ListTile(
                        title: Text('${u.nombre} ${u.apaterno}'),
                        subtitle: Text('${u.correo} • ${u.rol}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'editar':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UsuarioFormScreen(usuario: u),
                                  ),
                                ).then((_) => _refrescar());
                                break;
                              case 'resetear':
                                _resetearContrasena(u);
                                break;
                              case 'eliminar':
                                _eliminar(u.id);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'editar',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'resetear',
                              child: Row(
                                children: [
                                  Icon(Icons.lock_reset, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Resetear contraseña'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'eliminar',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar usuarios'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UsuarioFormScreen()),
          ).then((_) => _refrescar());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green[600],
      ),
    );
  }
}
