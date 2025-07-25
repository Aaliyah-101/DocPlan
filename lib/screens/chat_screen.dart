import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  UserModel? _otherUser;
  UserModel? _currentUser;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _markAsRead();
  }

  Future<void> _fetchUsers() async {
    final authService = AuthService();
    final other = await authService.getUserData(widget.otherUserId);
    final current = await authService.getUserData(widget.currentUserId);
    setState(() {
      _otherUser = other;
      _currentUser = current;
      _loadingUser = false;
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await _chatService.sendMessage(
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      message: text,
    );
    _controller.clear();
  }

  void _markAsRead() {
    // Mark all messages as read for the current user
    ChatService().updateLastRead(
      widget.currentUserId,
      widget.otherUserId,
      widget.currentUserId,
    );
  }

  Widget _buildAvatar(UserModel? user, {double radius = 18}) {
    if (user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.profilePictureUrl!),
      );
    } else if (user != null && user.name.isNotEmpty) {
      final initials = user.name.trim().split(' ').map((e) => e[0]).take(2).join();
      return CircleAvatar(
        radius: radius,
        child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    } else {
      return CircleAvatar(radius: radius, child: const Icon(Icons.person));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _buildAvatar(_otherUser),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.otherUserName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      body: _loadingUser
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _chatService.streamMessages(
                      widget.currentUserId,
                      widget.otherUserId,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final messages = snapshot.data!.docs;
                      // Mark as read when new messages arrive
                      if (messages.isNotEmpty) _markAsRead();
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg['senderId'] == widget.currentUserId;
                          final user = isMe ? _currentUser : _otherUser;
                          return Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe) ...[
                                _buildAvatar(user),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blueAccent.withOpacity(0.8)
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    msg['message'],
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 6),
                                _buildAvatar(user),
                              ],
                            ],
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
                            hintText: 'Type a message...',
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 