import 'package:webspark/models/matrix.dart';
import 'package:webspark/models/pathFinder.dart';
import 'package:webspark/models/position.dart';

class Data {
  final Matrix matrix;
  final Position start;
  final Position end;
  final String id;

  Data({required this.matrix, required this.start, required this.end, required this.id});

  factory Data.fromJson(Map<String, dynamic> json) {
    List<List<String>> grid = (json['field'] as List<dynamic>)
        .map((row) => (row as String).split('').toList())
        .toList();
    Matrix matrix = Matrix(grid);
    Position start = Position(json['start']['x'], json['start']['y']);
    Position end = Position(json['end']['x'], json['end']['y']);
    String id = json['id'];

    return Data(matrix: matrix, start: start, end: end, id: id);
  }

  Map<String, dynamic> toJson() {
    List<Position> path = calculatePath();
    return {
      "id": id,
      "result": {
        "steps": [
          {"x": start.x.toString(), "y": start.y.toString()},
          {"x": end.x.toString(), "y": end.y.toString()},
        ],
        "path": path.map((pos) => pos.toString()).join(' -> '),
      }
    };
  }

  List<Position> calculatePath() {
    PathFinder pathFinder = PathFinder(matrix: matrix, start: start, end: end);
    return pathFinder.findShortestPath();
  }
}
