// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final _ctrl = TextEditingController();
  final _fs = FirestoreService();
  final _auth = AuthService();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await _fs.searchUserByEmail(q.trim());
      setState(() => _results = res);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Search user')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: 'Enter exact email',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(_ctrl.text),
                ),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final u = _results[i];
                        final isMe = me != null && me.uid == u['uid'];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(u['email'] ?? 'Unknown'),
                          subtitle: Text(isMe ? 'This is you' : 'Tap to chat'),
                          enabled: !isMe,
                          onTap: isMe
                              ? null
                              : () async {
                                  if (me == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please login first'),
                                      ),
                                    );
                                    return;
                                  }
                                  final chatId = await _fs.getOrCreateChat(
                                    me.uid,
                                    u['uid'],
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        chatId: chatId,
                                        otherUid: u['uid'],
                                      ),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
