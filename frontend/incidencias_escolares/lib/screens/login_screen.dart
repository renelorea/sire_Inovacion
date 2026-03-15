import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/login_response.dart';
import '../config/global.dart';
import 'menu_principal_screen.dart';
import 'reportes_screen.dart';
import 'cambio_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _authService = AuthService();
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => _error = null);
    try {
      final correo = _correoController.text.trim();
      final contrasena = _contrasenaController.text;
      
      final loginResponse = await _authService.login(correo, contrasena);
      
      print('loginResponse: $loginResponse');
      if (loginResponse != null) {
        jwtToken = loginResponse.token;
        usuarioRol = loginResponse.usuario.rol ?? '';
        usuarioId = loginResponse.usuario.id;
        usuarioNombreCompleto = '${loginResponse.usuario.nombre} ${loginResponse.usuario.apaterno} ${loginResponse.usuario.amaterno}'.trim();
        print('token set, rol=$usuarioRol, usuario=$usuarioNombreCompleto');
        
        // 🔒 VERIFICACIÓN: Si usa contraseña predeterminada, forzar cambio
        if (contrasena == 'cecytem@1234') {
          print('Contraseña predeterminada detectada, redirigiendo a cambio de contraseña');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CambioPasswordScreen(correoUsuario: correo),
            ),
          );
          return;
        }
        
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        setState(() => _error = 'Credenciales inválidas');
        print('Login failed: loginResponse == null');
      }
    } catch (e, st) {
      print('Error en _login: $e\n$st');
      setState(() => _error = 'Error al conectar: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🖼️ Logo institucional
              Image.asset(
                'assets/images/logo.png', // Asegúrate de tener esta imagen en assets
                height: 120,
              ),
              SizedBox(height: 16),

              // 🏫 Nombre institucional
              Text(
                'Sistema de Incidencias Escolares',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 32),

              // 👤 Campo correo
              TextField(
                controller: _correoController,
                decoration: InputDecoration(
                  labelText: 'Correo institucional',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // 🔒 Campo contraseña
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // ⚠️ Error visual
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              SizedBox(height: 24),

              // 🔘 Botón de acceso
              ElevatedButton(
                onPressed: _login,
                child: Text('Ingresar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incidencias Escolares',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/menu': (context) => MenuPrincipalScreen(),
        '/reportes': (context) => ReportesScreen(),
        '/cambio-password': (context) => CambioPasswordScreen(correoUsuario: ''),
        // agrega más rutas aquí según tus pantallas
      },
      // opcional:
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
