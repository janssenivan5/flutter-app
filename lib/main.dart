import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; 
import 'main_dashboard.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://anbxociqkrdkgfspyvrm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFuYnhvY2lxa3Jka2dmc3B5dnJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc3NDEzODgsImV4cCI6MjEwMzMxNzM4OH0.WwnS6s1MVvzg3cCYJ7iPI135CCr4w2210XlRuiuzwrw',
  );

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
      home: const AuthGate(), 
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF064E3B)),
            ),
          );
        }
        
        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          return const MainDashboard(); 
        }

        return const LoginScreen(); 
      },
    );
  }
}