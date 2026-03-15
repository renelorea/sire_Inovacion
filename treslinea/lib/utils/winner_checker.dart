List<List<int>> winningCombos = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // filas
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // columnas
  [0, 4, 8], [2, 4, 6]             // diagonales
];

String checkWinner(List<String> board) {
  for (var combo in winningCombos) {
    final a = combo[0], b = combo[1], c = combo[2];
    if (board[a] != '' && board[a] == board[b] && board[b] == board[c]) {
      return board[a];
    }
  }
  return board.contains('') ? '' : 'Empate';
}
