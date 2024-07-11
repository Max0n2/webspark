import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:webspark/screens/previewScreen.dart';

class ListScreen extends StatefulWidget {

  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Map<String, dynamic>> dataSets = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  String url = 'https://flutter.webspark.dev/flutter/api';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    if (url.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      Dio dio = Dio();
      Response response = await dio.get(url);

      final List<dynamic> results = response.data['data'];
      List<Map<String, dynamic>> tempDataSets = List<Map<String, dynamic>>.from(results);

      setState(() {
        dataSets = tempDataSets;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error fetching data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<List<int>> directions = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
    [-1, -1],
    [-1, 1],
    [1, -1],
    [1, 1],
  ];

  List<List<int>> findShortestPath(List<List<String>> matrix, Map<String, int> start, Map<String, int> end) {
    Queue<List<int>> queue = Queue();
    Set<String> visited = {};
    Map<String, List<int>> parentMap = {};

    List<int> startPos = [start['y']!, start['x']!];
    List<int> endPos = [end['y']!, end['x']!];

    queue.add(startPos);
    visited.add(startPos.join(','));

    while (queue.isNotEmpty) {
      List<int> current = queue.removeFirst();
      int y = current[0];
      int x = current[1];

      if (x == endPos[1] && y == endPos[0]) {
        return constructPath(parentMap, startPos, endPos);
      }

      for (List<int> dir in directions) {
        int newY = y + dir[0];
        int newX = x + dir[1];

        List<int> newPos = [newY, newX];

        if (newY >= 0 && newY < matrix.length &&
            newX >= 0 && newX < matrix[0].length &&
            matrix[newY][newX] != 'X' &&
            !visited.contains(newPos.join(','))) {
          queue.add(newPos);
          visited.add(newPos.join(','));
          parentMap[newPos.join(',')] = current;
        }
      }
    }

    return [];
  }

  List<List<int>> constructPath(Map<String, List<int>> parentMap, List<int> start, List<int> end) {
    List<List<int>> path = [];
    List<int>? current = end;

    while (current != null && current != start) {
      path.add(current);
      current = parentMap[current.join(',')];
    }

    path.add(start);
    path = path.reversed.toList();

    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result List Screen"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: dataSets.length,
        itemBuilder: (ctx, index) {
          var dataSet = dataSets[index];
          List<List<String>> matrix = (dataSet['field'] as List<dynamic>)
              .map((row) => (row as String).split('').toList())
              .toList();
          Map<String, int> start = {
            'x': dataSet['start']['x'],
            'y': dataSet['start']['y']
          };
          Map<String, int> end = {
            'x': dataSet['end']['x'],
            'y': dataSet['end']['y']
          };
          List<List<int>> path = findShortestPath(matrix, start, end);

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PreviewScreen(jsonString: json.encode(dataSet),)));
            },
            child: Column(
              children: [
                Text(
                  path.map((pos) => '(${pos[1]}, ${pos[0]})').join(' > '),
                  style: const TextStyle(fontSize: 20),
                ),
                const Divider()
              ],
            ),
          );
        },
      ),
    );
  }
}
