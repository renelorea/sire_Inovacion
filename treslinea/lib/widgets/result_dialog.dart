import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final String winner;
  final VoidCallback onReset;

  const ResultDialog({super.key, required this.winner, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(winner == 'Empate' ? '¡Empate!' : 'Ganó $winner'),
      content: const Text('¿Quieres jugar otra vez?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onReset();
          },
          child: const Text('Reiniciar'),
        ),
      ],
    );
  }
}
