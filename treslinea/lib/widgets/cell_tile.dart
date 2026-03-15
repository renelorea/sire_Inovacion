import 'package:flutter/material.dart';

class CellTile extends StatelessWidget {
  final String symbol;
  final VoidCallback onTap;

  const CellTile({super.key, required this.symbol, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Center(
          child: Text(
            symbol,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
