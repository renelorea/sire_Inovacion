import 'package:flutter/material.dart';
import 'screens/board_screen.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tres en Línea CECyTEM',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const BoardScreen(),
    );
  }
}
