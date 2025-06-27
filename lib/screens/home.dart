import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Bisa tambahkan fungsi logout di sini nanti
              Navigator.pop(context); // sementara kembali ke login
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Selamat datang di halaman Home!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
