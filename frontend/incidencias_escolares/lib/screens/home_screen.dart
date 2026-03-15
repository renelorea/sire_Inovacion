import 'package:flutter/material.dart';
import '../models/usuario.dart';

class HomeScreen extends StatelessWidget {
  final Usuario usuario;
  static const String _headerUrl = 'https://cecytem.mx/deo/rsc/img/headerc2.png';

  const HomeScreen({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Se mantiene AppBar pero el encabezado principal se muestra dentro del body
      appBar: AppBar(title: Text('Bienvenido')),
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado remoto
            Image.network(
              _headerUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 120,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            SizedBox(height: 16),
            // Contenido principal
            Center(
              child: Text('Rol: ${usuario.rol}', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
