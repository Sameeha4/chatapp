import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/chat_model.dart';
import '../widgets/chat_tile.dart';
import 'chat_screen.dart';
import 'search_user_screen.dart';

class MainChatScreen extends StatelessWidget {
  const MainChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final fs = FirestoreService();
    final me = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await auth.logout(),
          ),
        ],
      ),
      body: me == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<List<ChatModel>>(
              stream: fs.getChats(me.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chats = snap.data ?? [];
                if (chats.isEmpty) {
                  return const Center(
                    child: Text('No chats yet. Tap + to start.'),
                  );
                }
                return ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final chat = chats[i];
                    final otherUid = chat.users.firstWhere((u) => u != me.uid);
                    return FutureBuilder<String>(
                      future: fs.getUserEmail(otherUid),
                      builder: (context, esnap) {
                        final email = esnap.data ?? 'Loading...';
                        return ChatTile(
                          chatId: chat.chatId,
                          otherEmail: email,
                          lastMessage: chat.lastMessage,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chat.chatId,
                                  otherUid: otherUid,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchUserScreen()),
        ),
      ),
    );
  }
}
