import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save user document (call after registration)
  Future<void> saveUser(String uid, String name, String email) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Search user by exact email
  Future<List<Map<String, dynamic>>> searchUserByEmail(String email) async {
    final snap = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return snap.docs.map((d) => {...d.data(), 'uid': d.id}).toList();
  }

  // Return user email by uid
  Future<String> getUserEmail(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? (doc.data()?['email'] ?? 'Unknown') : 'Unknown';
  }

  // Get or create chat between two users (returns chatId)
  Future<String> getOrCreateChat(String currentUid, String otherUid) async {
    if (currentUid.isEmpty || otherUid.isEmpty) {
      throw Exception('UIDs cannot be empty');
    }

    // look for existing chat where currentUid is participant
    final q = await _db
        .collection('chats')
        .where('users', arrayContains: currentUid)
        .get();

    for (final doc in q.docs) {
      final users = List<String>.from(doc['users'] ?? []);
      if (users.contains(otherUid)) {
        return doc.id; // existing chat
      }
    }

    // create new chat
    final newChatRef = await _db.collection('chats').add({
      'users': [currentUid, otherUid],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newChatRef.id;
  }

  // Send a message
  Future<void> sendMessage(String chatId, MessageModel message) async {
    final messagesRef = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages');
    await messagesRef.add(message.toMap());
    // update parent chat
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': message.text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Stream chats for current user
  Stream<List<ChatModel>> getChats(String myUid) {
    return _db
        .collection('chats')
        .where('users', arrayContains: myUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ChatModel.fromMap(d.id, d.data())).toList(),
        );
  }

  // Stream messages for a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => MessageModel.fromMap(d.data())).toList(),
        );
  }
}
