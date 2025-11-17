import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('messages').add({
      'text': text,
      'sender': 'user',
      'createdAt': Timestamp.now(),
    });
    _controller.clear();
    // optional simple bot reply
    await FirebaseFirestore.instance.collection('messages').add({
      'text': 'Bot: Thanks, I received "$text"',
      'sender': 'bot',
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Bot')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final isUser = data['sender'] == 'user';
                    return Container(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(data['text'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
