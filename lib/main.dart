import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const RozayConnectApp());
}

class RozayConnectApp extends StatelessWidget {
  const RozayConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rozay Connect',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
