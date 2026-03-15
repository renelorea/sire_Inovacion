import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart';
import 'screens/menu_principal_screen.dart';
import 'screens/usuarios_screen.dart';
import 'screens/alumnos_screen.dart';
import 'screens/grupos_screen.dart';
import 'screens/tipos_reporte_screen.dart';
import 'screens/reportes_screen.dart';
import 'screens/reporte_incidencias_screen.dart';
import 'config/global.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null); // inicializa formatos de fecha en español
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incidencias Escolares',
      debugShowCheckedModeBanner: false, // Quita la leyenda "DEBUG"
      locale: const Locale('es', ''), // forzar español (opcional)
      // no usar `const` aquí: los delegates pueden no ser constantes según la versión de Flutter
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // español
        Locale('en', ''), // mantener inglés si hace falta
      ],
      home: LoginScreen(),
      routes: {
        '/login': (_) => LoginScreen(),
        '/menu': (_) => MenuPrincipalScreen(),
        '/alumnos': (_) => AlumnosScreen(),
        '/usuarios': (_) => UsuariosScreen(),
        '/grupos': (_) => GruposScreen(),
        '/tipos-reporte': (_) => TiposReporteScreen(),
        '/tipos_reporte': (_) => TiposReporteScreen(),
        '/reportes': (_) => ReportesScreen(),
        '/reporte_incidencias': (context) => const ReporteIncidenciasScreen(),
      },
    );
  }
}
