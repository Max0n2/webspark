import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webspark/screens/homeScreen.dart';
import 'package:webspark/screens/listScreen.dart';
import 'package:webspark/screens/loadingScreen.dart';
import 'package:webspark/screens/previewScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}