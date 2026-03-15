import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/global.dart';

class CambioPasswordScreen extends StatefulWidget {
  final String correoUsuario;
  
  const CambioPasswordScreen({Key? key, required this.correoUsuario}) : super(key: key);

  @override
  _CambioPasswordScreenState createState() => _CambioPasswordScreenState();
}

class _CambioPasswordScreenState extends State<CambioPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordActualController = TextEditingController();
  final _nuevaPasswordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool _obscureActual = true;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Prellenar la contraseña actual con la predeterminada
    _passwordActualController.text = 'cecytem@1234';
  }

  @override
  void dispose() {
    _passwordActualController.dispose();
    _nuevaPasswordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  String? _validarPassword(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (valor == 'cecytem@1234') {
      return 'No puedes usar la contraseña predeterminada';
    }
    return null;
  }

  String? _validarConfirmacion(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Confirma tu nueva contraseña';
    }
    if (valor != _nuevaPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void _cambiarPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final exito = await _authService.cambiarPassword(
        widget.correoUsuario,
        _passwordActualController.text,
        _nuevaPasswordController.text,
      );

      if (exito) {
        // Mostrar mensaje de éxito y redirigir al menú principal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contraseña actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Redirigir al menú principal
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        setState(() {
          _error = 'Error al actualizar la contraseña';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar Contraseña'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // No mostrar botón atrás
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔐 Ícono de seguridad
                Icon(
                  Icons.security,
                  size: 80,
                  color: Colors.orange,
                ),
                SizedBox(height: 24),

                // 📋 Título y descripción
                Text(
                  'Cambio de Contraseña Obligatorio',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                Text(
                  'Estás usando la contraseña predeterminada. Por seguridad, debes cambiarla antes de continuar.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // 📧 Mostrar correo del usuario
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey[600]),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Usuario: ${widget.correoUsuario}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // 🔒 Campo contraseña actual
                TextFormField(
                  controller: _passwordActualController,
                  obscureText: _obscureActual,
                  readOnly: true, // Solo lectura porque sabemos que es la predeterminada
                  decoration: InputDecoration(
                    labelText: 'Contraseña Actual',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureActual ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureActual = !_obscureActual),
                    ),
                  ),
                  validator: (valor) {
                    if (valor != 'cecytem@1234') {
                      return 'Contraseña actual incorrecta';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // 🔑 Campo nueva contraseña
                TextFormField(
                  controller: _nuevaPasswordController,
                  obscureText: _obscureNueva,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    border: OutlineInputBorder(),
                    helperText: 'Mínimo 6 caracteres, diferente a la actual',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNueva ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureNueva = !_obscureNueva),
                    ),
                  ),
                  validator: _validarPassword,
                ),
                SizedBox(height: 16),

                // ✅ Campo confirmar contraseña
                TextFormField(
                  controller: _confirmarPasswordController,
                  obscureText: _obscureConfirmar,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nueva Contraseña',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmar ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                    ),
                  ),
                  validator: _validarConfirmacion,
                ),
                SizedBox(height: 16),

                // ⚠️ Error visual
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(height: 24),

                // 🔘 Botón de actualizar
                ElevatedButton(
                  onPressed: _cargando ? null : _cambiarPassword,
                  child: _cargando
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Actualizar Contraseña'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
                SizedBox(height: 16),

                // ℹ️ Nota informativa
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Una vez actualizada tu contraseña, podrás acceder al sistema con normalidad.',
                            style: TextStyle(color: Colors.blue[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}