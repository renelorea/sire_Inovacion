import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/winner_checker.dart';
import '../widgets/cell_tile.dart';
import '../widgets/result_dialog.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final GameState _game = GameState();

  void _handleTap(int index) {
    setState(() {
      _game.makeMove(index);
      final winner = checkWinner(_game.board);
      if (winner != '') {
        _game.gameOver = true;
        showDialog(
          context: context,
          builder: (_) => ResultDialog(winner: winner, onReset: _resetGame),
        );
      }
    });
  }

  void _resetGame() {
    setState(() {
      _game.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tres en Línea')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: 9,
        itemBuilder: (_, index) => CellTile(
          symbol: _game.board[index],
          onTap: () => _handleTap(index),
        ),
      ),
    );
  }
}
