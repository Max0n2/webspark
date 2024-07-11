import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:webspark/models/position.dart';

import '../models/data.dart';

class LoadingScreen extends StatefulWidget {
  final String url;

  const LoadingScreen({super.key, required this.url});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final Dio _dio = Dio();
  bool isLoading = false;
  double progress = 0.0;
  List<Data> data = [];
  bool hasError = false;
  String errorMessage = '';
  List<Map<String, dynamic>> sentData = [];

  void fetchData() async {
    if (widget.url.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
      progress = 0.0;
    });

    try {
      Response response = await _dio.get(widget.url);

      final List<dynamic> results = response.data['data'];
      data = results.map((item) => Data.fromJson(item)).toList(growable: false);

      for (var i = 0; i <= 100; i++) {
        setState(() {
          progress = i / 100.0;
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
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

  void sendResults() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> jsonData = [];

      for (var item in data) {
        jsonData.add(item.toJson());
      }

      Response postResponse = await _dio.post(
        'https://flutter.webspark.dev/',
        data: jsonData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (postResponse.statusCode == 200) {
        setState(() {
          sentData = jsonData;
        });
      } else {
        throw Exception('Error sending results: ${postResponse.data}');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error sending results: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String formatField(List<String> field) {
    return field.map((row) => row.split('').join(', ')).join('\n');
  }

  String formatSolution(List<Position> solution) {
    return solution.map((pos) => pos.toString()).join(' > ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process screen'),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: isLoading ? null : sendResults,
          style: ElevatedButton.styleFrom(
            side: const BorderSide(color: Colors.blue),
            backgroundColor: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "Send result to server",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLoading)
              const Text(
                "All calculations have finished, you can send your results to server",
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontSize: 28),
            ),
            if (isLoading)
              CircularProgressIndicator(value: progress),
            if (hasError)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
          ],
        ),
      ),
    );
  }
}
