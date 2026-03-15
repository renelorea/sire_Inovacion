import 'package:flutter/material.dart';

String? jwtToken; // Se asigna tras login
String? usuarioRol; // Se asigna tras login
String? notasUsuario; // <-- nueva variable global para almacenar notas del usuario
int? usuarioId;     // Si lo necesitas para peticiones
String? usuarioNombreCompleto; // Nombre completo del usuario loggeado

// Indicador global de "busy" / reloj de arena
final ValueNotifier<bool> appBusy = ValueNotifier<bool>(false);

void setBusy(bool value) => appBusy.value = value;

void showBusy() => setBusy(true);
void hideBusy() => setBusy(false);
