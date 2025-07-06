import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String email;
  final String lastMessage;
  final VoidCallback onTap;

  const ChatTile({
    required this.name,
    required this.email,
    required this.lastMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(name[0])),
      title: Text(name),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.chat),
    );
  }
}
