import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/onboarding.dart'; // pastikan path benar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://oppzfokkrmwlztmgoqwc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wcHpmb2trcm13bHp0bWdvcXdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzMjg2NDQsImV4cCI6MjA2NzkwNDY0NH0.RzK6ePuC-cuYJ0UK_TNHCbw-jWo9pG-IymaGaBz21pc',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Auth UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home:
          OnboardingScreen(), // ganti dari LoginScreen ke OnboardingScreen
    );
  }
}
