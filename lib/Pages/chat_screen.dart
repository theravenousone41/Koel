import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String peerEmail;

  const ChatScreen({
    required this.peerId,
    required this.peerName,
    required this.peerEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  String get chatRoomId =>
      currentUser.uid.hashCode <= widget.peerId.hashCode
          ? '${currentUser.uid}_${widget.peerId}'
          : '${widget.peerId}_${currentUser.uid}';

  void sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': _controller.text.trim(),
      'senderId': currentUser.uid,
      'senderEmail': currentUser.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
        backgroundColor: Colors.blueAccent,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == currentUser.uid;
                    final time = data['timestamp'] != null
                        ? DateFormat('hh:mm a').format(
                        (data['timestamp'] as Timestamp).toDate())
                        : '';

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: 250),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft:
                            isMe ? Radius.circular(16) : Radius.circular(0),
                            bottomRight:
                            isMe ? Radius.circular(0) : Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['text'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                // Optional emoji icon
                Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
