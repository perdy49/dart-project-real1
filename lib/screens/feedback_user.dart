import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackFormPage extends StatefulWidget {
  final String username;

  const FeedbackFormPage({super.key, required this.username});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _submitFeedback() async {
    if (_controller.text.isEmpty) return;
    setState(() => _loading = true);

    await Supabase.instance.client.from('feedback').insert({
      'username': widget.username,
      'message': _controller.text,
    });

    setState(() => _loading = false);
    Navigator.pop(context); // kembali ke halaman sebelumnya
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Keluhan berhasil dikirim')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kirim Keluhan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Tulis keluhan kamu di sini...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitFeedback,
                    child: const Text('Kirim'),
                  ),
          ],
        ),
      ),
    );
  }
}
