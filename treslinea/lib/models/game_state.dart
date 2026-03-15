class GameState {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  bool gameOver = false;

  void reset() {
    board = List.filled(9, '');
    currentPlayer = 'X';
    gameOver = false;
  }

  void makeMove(int index) {
    if (board[index] == '' && !gameOver) {
      board[index] = currentPlayer;
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    }
  }
}
