// kelola_barang_page.dart
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html; // Web only
import 'package:supabase_flutter/supabase_flutter.dart';

class KelolaBarangPage extends StatefulWidget {
  const KelolaBarangPage({super.key});

  @override
  State<KelolaBarangPage> createState() => _KelolaBarangPageState();
}

class _KelolaBarangPageState extends State<KelolaBarangPage> {
  final String bucketName = 'barang-images';

  Future<void> _tambahBarang() async {
    final deskripsiController = TextEditingController();
    String? imageUrl;
    final supabase = Supabase.instance.client;

    if (kIsWeb) {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      input.onChange.listen((event) async {
        final file = input.files!.first;
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoadEnd.first;

        Uint8List fileBytes = reader.result as Uint8List;
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final filePath = 'images/$fileName.jpg';

        try {
          await supabase.storage
              .from(bucketName)
              .uploadBinary(filePath, fileBytes);
        } catch (e) {
          debugPrint('Upload error: $e');
          return;
        }

        final publicURL = supabase.storage
            .from(bucketName)
            .getPublicUrl(filePath);
        imageUrl = publicURL;
        _showDeskripsiDialog(imageUrl!, deskripsiController);
      });
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      final file = io.File(pickedFile.path);
      final fileBytes = await file.readAsBytes();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final filePath = 'images/$fileName.jpg';

      try {
        await supabase.storage
            .from(bucketName)
            .uploadBinary(filePath, fileBytes);
      } catch (e) {
        debugPrint('Upload error: $e');
        return;
      }

      final publicURL = supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      imageUrl = publicURL;
      _showDeskripsiDialog(imageUrl, deskripsiController);
    }
  }

void _showDeskripsiDialog(
    String imageUrl,
    TextEditingController deskripsiController,
  ) {
    final namaController = TextEditingController(); // Tambahkan controller nama

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Barang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                hintText: "Masukkan nama barang",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: deskripsiController,
              decoration: const InputDecoration(hintText: "Masukkan deskripsi"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client.from('barang').insert({
                'nama': namaController.text, // <-- Tambahkan ini
                'deskripsi': deskripsiController.text,
                'imageUrl': imageUrl,
                'createdAt': DateTime.now().toIso8601String(),
              });

              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _hapusBarang(String id, String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      final filePath = segments.sublist(segments.indexOf('images')).join('/');

      await Supabase.instance.client.storage.from(bucketName).remove([
        filePath,
      ]);
    } catch (e) {
      debugPrint('Gagal hapus dari Supabase: $e');
    }

    await Supabase.instance.client.from('barang').delete().eq('id', id);
    setState(() {});
  }

  Future<void> _editDeskripsi(String id, String currentDeskripsi) async {
    final controller = TextEditingController(text: currentDeskripsi);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Deskripsi"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Ubah deskripsi"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await Supabase.instance.client
                  .from('barang')
                  .update({'deskripsi': controller.text})
                  .eq('id', id);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchBarang() async {
    final response = await Supabase.instance.client
        .from('barang')
        .select()
        .order('createdAt', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBarang(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final id = data['id'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(
                    data['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(data['deskripsi'] ?? ''),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editDeskripsi(id, data['deskripsi']);
                      } else if (value == 'hapus') {
                        _hapusBarang(id, data['imageUrl']);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahBarang,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
