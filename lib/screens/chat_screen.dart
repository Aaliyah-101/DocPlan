import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  UserModel? _otherUser;
  UserModel? _currentUser;
  bool _loadingUser = true;
  bool _isTyping = false;

  // Modern gradient color scheme
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color deepBlue = Color(0xFF0D47A1);
  static const Color accentTeal = Color(0xFF00ACC1);
  static const Color backgroundGradientStart = Color(0xFFF0F4F8);
  static const Color backgroundGradientEnd = Color(0xFFE8F4F8);
  static const Color cardBackground = Color(0xFFFAFBFC);
  static const Color inputBackground = Color(0xFFF5F7FA);
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color messageBubbleMe = Color(0xFF667EEA);
  static const Color messageBubbleMeGradient = Color(0xFF764BA2);
  static const Color messageBubbleOther = Color(0xFFEDF2F7);
  static const Color messageBubbleOtherBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _markAsRead();

    // Listen to focus changes to handle keyboard
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
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

    setState(() => _isTyping = true);

    await _chatService.sendMessage(
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      message: text,
    );

    _controller.clear();
    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _markAsRead() {
    ChatService().updateLastRead(
      widget.currentUserId,
      widget.otherUserId,
      widget.currentUserId,
    );
  }

  String _formatMessageTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }

  Widget _buildAvatar(UserModel? user, {double radius = 20}) {
    if (user?.profilePictureUrl != null &&
        user!.profilePictureUrl!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [primaryBlue.withOpacity(0.3), accentTeal.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: primaryBlue.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(user.profilePictureUrl!),
        ),
      );
    } else if (user != null && user.name.isNotEmpty) {
      final initials = user.name
          .trim()
          .split(' ')
          .map((e) => e[0])
          .take(2)
          .join();
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [primaryBlue, deepBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          child: Text(
            initials,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [primaryBlue, deepBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      );
    }
  }

  Widget _buildMessageBubble(
    QueryDocumentSnapshot msg,
    bool isMe,
    UserModel? user,
  ) {
    final hasTimestamp =
        msg.data() is Map && (msg.data() as Map).containsKey('timestamp');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildAvatar(user, radius: 16),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? LinearGradient(
                            colors: [messageBubbleMe, messageBubbleMeGradient],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMe ? null : messageBubbleOther,
                    border: isMe
                        ? null
                        : Border.all(color: messageBubbleOtherBorder, width: 1),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? messageBubbleMe.withOpacity(0.3)
                            : Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : textPrimary,
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (hasTimestamp)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Text(
                      _formatMessageTime(msg['timestamp']),
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            _buildAvatar(user, radius: 16),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundGradientStart, backgroundGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Custom AppBar with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cardBackground, cardBackground.withOpacity(0.95)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: textPrimary),
                        style: IconButton.styleFrom(
                          backgroundColor: inputBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildAvatar(_otherUser, radius: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.otherUserName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: accentTeal,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Online",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: textPrimary),
                        onPressed: () {
                          // Add menu options here
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: inputBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Messages Area
            Expanded(
              child: _loadingUser
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: primaryBlue,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Loading conversation...",
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _chatService.streamMessages(
                        widget.currentUserId,
                        widget.otherUserId,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: primaryBlue,
                            ),
                          );
                        }

                        final messages = snapshot.data!.docs;
                        if (messages.isNotEmpty) _markAsRead();

                        if (messages.isEmpty) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              margin: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardBackground,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryBlue.withOpacity(0.1),
                                          accentTeal.withOpacity(0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble_outline,
                                      size: 48,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "No messages yet",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Start the conversation!",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Auto-scroll to bottom when new messages arrive
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final isMe =
                                msg['senderId'] == widget.currentUserId;
                            final user = isMe ? _currentUser : _otherUser;
                            return _buildMessageBubble(msg, isMe, user);
                          },
                        );
                      },
                    ),
            ),

            // Input Area with modern design
            Container(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: inputBackground,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: primaryBlue.withOpacity(0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(color: textPrimary, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                            onChanged: (text) {
                              // You can add typing indicators here
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryBlue, deepBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: _isTyping
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                          onPressed: _isTyping ? null : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
