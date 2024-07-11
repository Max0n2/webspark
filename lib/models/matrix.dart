import 'package:webspark/models/position.dart';

class Matrix {
  final List<List<String>> grid;

  Matrix(this.grid);

  bool isValid(Position pos) =>
      pos.y >= 0 && pos.y < grid.length && pos.x >= 0 && pos.x < grid[0].length;

  bool isWalkable(Position pos) => grid[pos.y][pos.x] != 'X';
}