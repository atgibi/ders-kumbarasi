import 'package:flutter/material.dart';

void main() {
  runApp(const DersKumbarasiApp());
}

class DersKumbarasiApp extends StatelessWidget {
  const DersKumbarasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ders Kumbarası',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF2A93B)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Ders Kumbarası',
            key: Key('app-title'),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
