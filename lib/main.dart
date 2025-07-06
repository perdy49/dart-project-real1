import 'package:coba_firebase1/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <- Tambahkan ini
import 'screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://mlluqzmslhjxbrzviiky.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sbHVxem1zbGhqeGJyenZpaWt5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2NDE2NjIsImV4cCI6MjA2NzIxNzY2Mn0.WAZYm7WEhYCucdhroCbE3nM5L7LeqJc1kRdfbtkXA5U',
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
      home: const LoginScreen(),
    );
  }
}
