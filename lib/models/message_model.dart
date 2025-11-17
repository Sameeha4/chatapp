import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Convert to Firestore-compatible map
  Map<String, dynamic> toMap() => {
    "senderId": senderId,
    "text": text,
    // Use Timestamp for Firestore
    "timestamp": Timestamp.fromDate(timestamp),
  };

  // Convert Firestore map to MessageModel
  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
    senderId: map["senderId"] ?? "",
    text: map["text"] ?? "",
    timestamp: map["timestamp"] != null
        ? (map["timestamp"] as Timestamp).toDate()
        : DateTime.now(),
  );
}
