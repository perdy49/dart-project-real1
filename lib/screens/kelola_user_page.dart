import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KelolaUserPage extends StatelessWidget {
  const KelolaUserPage({super.key});

  void _konfirmasiHapus(BuildContext context, String docId, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Yakin ingin menghapus akun "$username"?'),
          actions: [
            TextButton(
              child: const Text('Tidak'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allUsers = snapshot.data!.docs;

        // Filter: sembunyikan user yang role-nya 'admin'
        final users = allUsers
            .where((user) => user['role'] != 'admin')
            .toList();

        if (users.isEmpty) {
          return const Center(child: Text('Tidak ada user non-admin.'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(user['username'] ?? 'Tanpa Nama'),
              subtitle: Text(user['email'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _konfirmasiHapus(context, user.id, user['username'] ?? '');
                },
              ),
            );
          },
        );
      },
    );
  }
}
