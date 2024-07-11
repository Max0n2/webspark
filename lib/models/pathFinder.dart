import 'dart:collection';

import 'package:webspark/models/matrix.dart';
import 'package:webspark/models/position.dart';

class PathFinder {
  final Matrix matrix;
  final Position start;
  final Position end;

  static const List<List<int>> directions = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
    [-1, -1],
    [-1, 1],
    [1, -1],
    [1, 1],
  ];

  PathFinder({required this.matrix, required this.start, required this.end});

  List<Position> findShortestPath() {
    Queue<Position> queue = Queue();
    Set<Position> visited = {};
    Map<Position, Position?> parentMap = {};

    queue.add(start);
    visited.add(start);
    parentMap[start] = null;

    while (queue.isNotEmpty) {
      Position current = queue.removeFirst();

      if (current == end) {
        return _constructPath(parentMap);
      }

      for (var direction in directions) {
        Position newPos = Position(current.x + direction[1], current.y + direction[0]);

        if (matrix.isValid(newPos) &&
            matrix.isWalkable(newPos) &&
            !visited.contains(newPos)) {
          queue.add(newPos);
          visited.add(newPos);
          parentMap[newPos] = current;
        }
      }
    }

    return [];
  }

  List<Position> _constructPath(Map<Position, Position?> parentMap) {
    List<Position> path = [];
    Position? current = end;

    while (current != null) {
      path.add(current);
      current = parentMap[current];
    }

    return path.reversed.toList();
  }
}