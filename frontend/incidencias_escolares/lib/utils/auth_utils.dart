import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'No autorizado']);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class AuthUtils {
  static void handleUnauthorized(BuildContext context, {String? message}) {
    final msg = message ?? 'Sesión expirada. Por favor inicia sesión de nuevo.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    });
  }
}