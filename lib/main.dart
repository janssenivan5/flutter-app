import 'package:flutter/material.dart';
import 'main_dashboard.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuxeBite',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MainDashboard(), 
    );
  }
}