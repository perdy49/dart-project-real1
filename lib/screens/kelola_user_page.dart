import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaUserPage extends StatefulWidget {
  const KelolaUserPage({super.key});

  @override
  State<KelolaUserPage> createState() => _KelolaUserPageState();
}

class _KelolaUserPageState extends State<KelolaUserPage> {
  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .neq('role', 'admin');
    return List<Map<String, dynamic>>.from(response);
  }

  late Future<List<Map<String, dynamic>>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = _fetchUsers();
  }

  void _refreshUsers() {
    setState(() {
      _futureUsers = _fetchUsers();
    });
  }

  void _konfirmasiHapus(BuildContext context, String userId, String username) {
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
              onPressed: () async {
                await Supabase.instance.client
                    .from('users')
                    .delete()
                    .eq('id', userId);

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Akun "$username" berhasil dihapus')),
                );

                _refreshUsers();
              },
            ),
          ],
        );
      },
    );
  }

  void _lihatDetailUser(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user['username'] ?? 'Tanpa Nama',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Email: ${user['email'] ?? '-'}'),
              Text('ID: ${user['id'] ?? '-'}'),
              Text('Role: ${user['role'] ?? '-'}'),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup sheet dulu
                      _konfirmasiHapus(
                        context,
                        user['id'],
                        user['username'] ?? '',
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Tutup'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureUsers,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;

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
              onTap: () => _lihatDetailUser(context, user),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _konfirmasiHapus(context, user['id'], user['username'] ?? '');
                },
              ),
            );
          },
        );
      },
    );
  }
}
