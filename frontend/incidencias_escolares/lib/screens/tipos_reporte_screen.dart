import 'package:flutter/material.dart';
import '../models/tipo_reporte.dart';
import '../services/tipo_reporte_service.dart';
import 'tipo_reporte_form_screen.dart';

class TiposReporteScreen extends StatefulWidget {
  @override
  _TiposReporteScreenState createState() => _TiposReporteScreenState();
}

class _TiposReporteScreenState extends State<TiposReporteScreen> {
  final _service = TipoReporteService();
  late Future<List<TipoReporte>> _tipos;

  @override
  void initState() {
    super.initState();
    _cargarTipos();
  }

  Future<void> _cargarTipos() async {
    final tipos = _service.obtenerTipos();
    setState(() {
      _tipos = tipos;
    });
  }

  Future<void> _eliminar(int id) async {
    await _service.eliminarTipo(id);
    await _cargarTipos();
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
        title: Text('Tipos de Incidencia', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<TipoReporte>>(
        future: _tipos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los tipos'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay tipos registrados'));
          }

          final tipos = snapshot.data!;
          return ListView.builder(
            itemCount: tipos.length,
            itemBuilder: (context, index) {
              final t = tipos[index];
              return ListTile(
                title: Text(t.nombre),
                subtitle: Text('${t.descripcion} • Gravedad: ${t.gravedad}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TipoReporteFormScreen(tipo: t),
                          ),
                        ).then((_) => _cargarTipos());
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _eliminar(t.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TipoReporteFormScreen()),
          ).then((_) => _cargarTipos());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
