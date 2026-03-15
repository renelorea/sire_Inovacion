import 'package:flutter/material.dart';
import '../models/grupo.dart';
import '../models/alumno.dart';
import '../services/alumno_service.dart';

class GrupoDetalleScreen extends StatefulWidget {
  final Grupo grupo;

  GrupoDetalleScreen({required this.grupo});

  @override
  _GrupoDetalleScreenState createState() => _GrupoDetalleScreenState();
}

class _GrupoDetalleScreenState extends State<GrupoDetalleScreen> {
  List<Alumno> _alumnos = [];
  bool _cargando = true;
  int _totalAlumnos = 0;
  int _hombres = 0;
  int _mujeres = 0;

  @override
  void initState() {
    super.initState();
    _cargarAlumnos();
  }

  Future<void> _cargarAlumnos() async {
    try {
      // Cargar todos los alumnos y filtrar por grupo
      final todosAlumnos = await AlumnoService().obtenerAlumnos();
      
      final alumnosGrupo = todosAlumnos.where((a) {
        if (a.grupo == null) return false;
        // Acceder al id del grupo directamente desde el objeto Grupo
        if (a.grupo is Grupo) {
          return (a.grupo as Grupo).id == widget.grupo.id;
        } else if (a.grupo is Map) {
          final grupoId = (a.grupo as Map)['id_grupo'] ?? (a.grupo as Map)['id'];
          return grupoId?.toString() == widget.grupo.id.toString();
        }
        return false;
      }).toList();

      // Calcular estadísticas por sexo
      int hombres = 0;
      int mujeres = 0;
      
      for (var alumno in alumnosGrupo) {
        // Usar el campo sexo del modelo Alumno
        final sexo = alumno.sexo?.toLowerCase() ?? '';
        if (sexo == 'masculino' || sexo == 'm' || sexo == 'hombre') {
          hombres++;
        } else if (sexo == 'femenino' || sexo == 'f' || sexo == 'mujer') {
          mujeres++;
        }
      }

      setState(() {
        _alumnos = alumnosGrupo;
        _totalAlumnos = alumnosGrupo.length;
        _hombres = hombres;
        _mujeres = mujeres;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando alumnos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Colors.grey.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Detalle - ${widget.grupo.descripcion}', style: TextStyle(color: Colors.white)),
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del grupo
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Grupo',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Descripción: ${widget.grupo.descripcion}'),
                          Text('Grado: ${widget.grupo.grado}°'),
                          Text('Ciclo: ${widget.grupo.ciclo}'),
                          Text('ID Tutor: ${widget.grupo.idTutor}'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Estadísticas de alumnos
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estadísticas de Alumnos',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildEstadisticaCard('Total', _totalAlumnos.toString(), Colors.blue),
                              _buildEstadisticaCard('Hombres', _hombres.toString(), Colors.cyan),
                              _buildEstadisticaCard('Mujeres', _mujeres.toString(), Colors.pink),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Lista de alumnos
                  Text(
                    'Lista de Alumnos ($_totalAlumnos)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  
                  Expanded(
                    child: _totalAlumnos == 0
                        ? Center(
                            child: Text(
                              'No hay alumnos registrados en este grupo',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _alumnos.length,
                            itemBuilder: (context, index) {
                              final alumno = _alumnos[index];
                              final sexo = alumno.sexo?.toLowerCase() ?? 'no especificado';
                              final iconoSexo = sexo.contains('m') && !sexo.contains('f') 
                                  ? Icons.male 
                                  : sexo.contains('f') 
                                      ? Icons.female 
                                      : Icons.person;
                              final colorSexo = sexo.contains('m') && !sexo.contains('f')
                                  ? Colors.cyan
                                  : sexo.contains('f')
                                      ? Colors.pink
                                      : Colors.grey;
                              
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: Icon(iconoSexo, color: colorSexo),
                                  title: Text('${alumno.nombre} ${alumno.apaterno} ${alumno.amaterno}'),
                                  subtitle: Text('Matrícula: ${alumno.matricula}'),
                                  trailing: Text(
                                    sexo.toUpperCase(),
                                    style: TextStyle(
                                      color: colorSexo,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEstadisticaCard(String titulo, String valor, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}