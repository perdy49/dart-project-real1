import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String username = '', email = '', password = '';
  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
  final isValid = _formKey.currentState!.validate();
  if (!isValid) return;

  try {
    // Buat akun di Firebase Auth
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Simpan data user ke Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid) // gunakan UID sebagai ID dokumen
        .set({
      'username': username.trim(),
      'email': email.trim(),
      'createdAt': Timestamp.now(),
      'role': 'user', // <- tambahkan ini
    });

    // Sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  } on FirebaseAuthException catch (e) {
    print('Error saat registrasi: ${e.code} - ${e.message}');
    String message = '';
    if (e.code == 'email-already-in-use') {
      message = 'Email sudah digunakan.';
    } else if (e.code == 'weak-password') {
      message = 'Password terlalu lemah.';
    } else {
      message = 'Gagal daftar: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Register untuk akun baru',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Opacity(
                          opacity: 0.5, // atur transparansi ikon di sini
                          child: Icon(Icons.person),
                        ),
                      ),
                      onChanged: (val) => username = val,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Masukkan username'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Opacity(
                          opacity: 0.5, // atur transparansi ikon di sini
                          child: Icon(Icons.email),
                        ),
                      ),
                      onChanged: (val) => email = val,
                      validator: (val) => val == null || !val.contains('@')
                          ? 'Email tidak valid'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Opacity(
                          opacity: 0.5,
                          child: Icon(Icons.lock),
                        ),
                      ),
                      obscureText: true,
                      onChanged: (val) => password = val,
                      validator: (val) => val == null || val.length < 6
                          ? 'Minimal 6 karakter'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Register'),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Kembali ke login
                      },
                      child: Text(
                        "Sudah punya akun? Login",
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
