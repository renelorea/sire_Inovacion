import 'package:flutter/material.dart';
import '../models/grupo.dart';
import '../services/grupo_service.dart';
import 'grupo_form_screen.dart';
import 'grupo_detalle_screen.dart';
import 'login_screen.dart';

class GruposScreen extends StatefulWidget {
  @override
  _GruposScreenState createState() => _GruposScreenState();
}

class _GruposScreenState extends State<GruposScreen> {
  final _service = GrupoService();
  // Inicializar para que el FutureBuilder no lea una variable no inicializada
  Future<List<Grupo>> _grupos = Future.value([]);
  List<Grupo> _todos = [];
  List<String> _ciclos = [];
  String? _filtroCiclo;

  @override
  void initState() {
    super.initState();
    _cargarGrupos();
  }

  void _handleUnauthorized() {
    // muestra mensaje y redirige al login limpiando la pila
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión expirada. Por favor inicia sesión de nuevo.')),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    });
  }

  Future<void> _cargarGrupos() async {
    try {
      final grupos = await _service.obtenerGrupos();
      final ciclos = grupos.map((g) => g.ciclo).toSet().toList()..sort();
      setState(() {
        _todos = grupos;
        _ciclos = ciclos;
        _aplicarFiltro();
      });
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('401') || msg.contains('no autorizado') || msg.contains('unauthorized')) {
        _handleUnauthorized();
        return;
      }
      // error genérico: mostrar mensaje y mantener estado actual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando grupos: ${e.toString()}')),
      );
    }
  }

  void _aplicarFiltro() {
    if (_filtroCiclo == null || _filtroCiclo == 'Todos') {
      _grupos = Future.value(_todos);
    } else {
      final filtrados = _todos.where((g) => g.ciclo == _filtroCiclo).toList();
      _grupos = Future.value(filtrados);
    }
  }

  void _refrescar() => _cargarGrupos();

  void _eliminar(int id) async {
    try {
      await _service.eliminarGrupo(id);
      await _cargarGrupos();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('401') || msg.contains('no autorizado') || msg.contains('unauthorized')) {
        _handleUnauthorized();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando grupo: ${e.toString()}')),
      );
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
        title: Text('Grupos', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filtroCiclo ?? 'Todos',
                    decoration: InputDecoration(labelText: 'Filtrar por ciclo'),
                    items: ['Todos', ..._ciclos].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _filtroCiclo = value;
                        _aplicarFiltro();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filtroCiclo = 'Todos';
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
            child: FutureBuilder<List<Grupo>>(
              future: _grupos,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final grupos = snapshot.data!;
                  return ListView.builder(
                    itemCount: grupos.length,
                    itemBuilder: (context, index) {
                      final g = grupos[index];
                      return ListTile(
                        title: Text('Grupo ${g.descripcion} - ${g.grado}°'),
                        subtitle: Text('Ciclo: ${g.ciclo} • Tutor ID: ${g.idTutor}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.info),
                              tooltip: 'Ver detalles',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GrupoDetalleScreen(grupo: g),
                                  ),
                                );
                              },
                            ),
                            IconButton(icon: Icon(Icons.edit), onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GrupoFormScreen(grupo: g),
                                ),
                              ).then((_) => _refrescar());
                            }),
                            IconButton(icon: Icon(Icons.delete), onPressed: () => _eliminar(g.id)),
                          ],
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  final msg = snapshot.error.toString().toLowerCase();
                  if (msg.contains('401') || msg.contains('no autorizado') || msg.contains('unauthorized')) {
                    // si FutureBuilder muestra error de autorización, redirigir
                    WidgetsBinding.instance.addPostFrameCallback((_) => _handleUnauthorized());
                    return Center(child: Text('Redirigiendo a login...'));
                  }
                  return Center(child: Text('Error cargando grupos'));
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
            MaterialPageRoute(builder: (_) => GrupoFormScreen()),
          ).then((_) => _refrescar());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
