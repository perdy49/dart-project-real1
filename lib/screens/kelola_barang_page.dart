// kelola_barang_page.dart
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final CollectionReference _barangRef = FirebaseFirestore.instance.collection(
    'barang',
  );

  final String bucketName = 'barang';

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
      final fileBytes = await file.readAsBytes(); // Konversi jadi Uint8List
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

  void _showDeskripsiDialog(String imageUrl, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Deskripsi Barang"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Masukkan deskripsi"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await _barangRef.add({
                'imageUrl': imageUrl,
                'deskripsi': controller.text,
                'createdAt': Timestamp.now(),
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _hapusBarang(String docId, String imageUrl) async {
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

    await _barangRef.doc(docId).delete();
  }

  Future<void> _editDeskripsi(String docId, String currentDeskripsi) async {
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
              await _barangRef.doc(docId).update({
                'deskripsi': controller.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _barangRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: Image.network(
                    data['imageUrl'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(data['deskripsi']),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editDeskripsi(docId, data['deskripsi']);
                      } else if (value == 'hapus') {
                        _hapusBarang(docId, data['imageUrl']);
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
