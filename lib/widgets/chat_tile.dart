import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final String chatId;
  final String otherEmail;
  final String lastMessage;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chatId,
    required this.otherEmail,
    required this.lastMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(otherEmail),
      subtitle: Text(lastMessage.isEmpty ? "No messages yet" : lastMessage),
      leading: CircleAvatar(child: Text(otherEmail[0].toUpperCase())),
      onTap: onTap,
    );
  }
}
