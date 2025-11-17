import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final String time;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.blue : Colors.grey.shade200;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Text(
                text,
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
