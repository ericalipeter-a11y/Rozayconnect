import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://iqahvpbsmwvrpezgsayr.supabase.co',
    publishableKey: 'sb_publishable_GhXFFKLhgdpZb0Y4YqOF5w_ODAwwpxW',
  );
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
