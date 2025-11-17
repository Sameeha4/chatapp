// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/message_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUid;

  const ChatScreen({super.key, required this.chatId, required this.otherUid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _fs = FirestoreService();
  final _auth = AuthService();
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) => DateFormat('hh:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    final me = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: _fs.getMessages(widget.chatId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  final messages = snap.data ?? [];
                  if (messages.isEmpty)
                    return const Center(
                      child: Text('No messages yet. Say hi!'),
                    );
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final isMe = me != null && me.uid == m.senderId;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: MessageBubble(
                          isMe: isMe,
                          text: m.text,
                          time: _formatTime(m.timestamp),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = _ctrl.text.trim();
                      final meUser = _auth.currentUser;
                      if (text.isEmpty || meUser == null) return;

                      final msg = MessageModel(
                        senderId: meUser.uid,
                        text: text,
                        timestamp: DateTime.now(),
                      );
                      try {
                        await _fs.sendMessage(widget.chatId, msg);
                        _ctrl.clear();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Send failed: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
