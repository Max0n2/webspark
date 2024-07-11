import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webspark/models/matrix.dart';
import 'package:webspark/models/pathFinder.dart';

import 'package:webspark/models/position.dart';

class PreviewScreen extends StatefulWidget {
  final String jsonString;

  const PreviewScreen({super.key, required this.jsonString});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  Matrix? matrix;
  Position? start;
  Position? end;
  List<Position> path = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJson(widget.jsonString);
  }

  void loadJson(String jsonString) {
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    List<List<String>> tempMatrix = (jsonMap['field'] as List<dynamic>)
        .map((row) => (row as String).split('').toList())
        .toList();

    setState(() {
      matrix = Matrix(tempMatrix);
      start = Position(jsonMap['start']['x'], jsonMap['start']['y']);
      end = Position(jsonMap['end']['x'], jsonMap['end']['y']);
      isLoading = false;
    });

    calculatePath();
  }

  void calculatePath() {
    if (matrix != null && start != null && end != null) {
      PathFinder pathFinder = PathFinder(matrix: matrix!, start: start!, end: end!);
      List<Position> foundPath = pathFinder.findShortestPath();
      setState(() {
        path = foundPath;
      });
    }
  }

  Color getCellColor(int y, int x) {
    Position pos = Position(x, y);
    if (pos == start) {
      return const Color.fromRGBO(100, 255, 218, 1);
    } else if (pos == end) {
      return const Color.fromRGBO(0, 150, 136, 1);
    } else if (path.contains(pos)) {
      return const Color.fromRGBO(76, 175, 80, 1);
    } else if (matrix!.grid[y][x] == 'X') {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  Color getTextColor(int y, int x) {
    Color bgColor = getCellColor(y, x);
    return bgColor == Colors.black ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Screen"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: matrix!.grid[0].length,
              ),
              itemCount: matrix!.grid.length * matrix!.grid[0].length,
              itemBuilder: (ctx, index) {
                int x = index % matrix!.grid[0].length;
                int y = index ~/ matrix!.grid[0].length;
                String display = '($x, $y)';
                return Container(
                  margin: const EdgeInsets.all(1),
                  color: getCellColor(y, x),
                  child: Center(
                    child: Text(
                      display,
                      style: TextStyle(color: getTextColor(y, x)),
                    ),
                  ),
                );
              },
            ),
          ),
          Text(path.map((pos) => pos.toString()).join(' > ')),
        ],
      ),
    );
  }
}
