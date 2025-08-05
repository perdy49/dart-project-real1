import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  Future<List<Map<String, dynamic>>> _getFeedback() async {
    final response = await Supabase.instance.client
        .from('feedback')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  void _showFeedbackDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Keluhan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '👤 Username:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(item['username'] ?? 'Tidak diketahui'),
              const SizedBox(height: 12),
              Text(
                '📝 Isi Pesan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(item['message'] ?? 'Tidak ada isi'),
              const SizedBox(height: 12),
              Text('🕒 Waktu:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(item['created_at'].toString().substring(0, 16)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Feedback")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getFeedback(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('Belum ada keluhan'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                leading: const Icon(Icons.feedback),
                title: Text(item['username'] ?? 'Tanpa nama'),
                subtitle: Text(
                  item['message'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(item['created_at'].toString().substring(0, 16)),
                onTap: () => _showFeedbackDetail(context, item),
              );
            },
          );
        },
      ),
    );
  }
}
