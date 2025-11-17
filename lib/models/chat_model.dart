import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> users;
  final String lastMessage;
  final DateTime lastMessageTime;

  ChatModel({
    required this.chatId,
    required this.users,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory ChatModel.fromMap(String id, Map<String, dynamic> data) {
    return ChatModel(
      chatId: id,
      users: List<String>.from(data['users']),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
