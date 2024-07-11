import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webspark/screens/loadingScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            final url = _urlController.text.trim();
            if (url.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoadingScreen(url: url),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid URL'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            side: const BorderSide(color: Colors.blue),
            backgroundColor: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "Start counting process",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Set valid API base URL in order to continue",
              style: TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                const Icon(CupertinoIcons.add),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'API URL',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
