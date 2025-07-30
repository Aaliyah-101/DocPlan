import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a unique chat ID for a doctor-patient pair (sorted for consistency)
  String getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  // Send a message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    final chatId = getChatId(senderId, receiverId);
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // Fetch sender name
    final senderDoc = await _firestore.collection('users').doc(senderId).get();
    String senderName = 'Someone';
    if (senderDoc.exists) {
      final data = senderDoc.data() as Map<String, dynamic>;
      senderName = data['name'] ?? 'Someone';
    }
    // Send push notification
    await NotificationService.notifyNewChatMessage(
      receiverId: receiverId,
      senderName: senderName,
      message: message,
    );
  }

  // Stream messages between two users
  Stream<QuerySnapshot> streamMessages(String userId1, String userId2) {
    final chatId = getChatId(userId1, userId2);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Get chat document reference
  DocumentReference getChatDocRef(String userId1, String userId2) {
    final chatId = getChatId(userId1, userId2);
    return _firestore.collection('chats').doc(chatId);
  }

  // Update last read timestamp for a user
  Future<void> updateLastRead(String userId1, String userId2, String userId) async {
    final chatDoc = getChatDocRef(userId1, userId2);
    await chatDoc.set({
      'lastRead': {userId: FieldValue.serverTimestamp()},
    }, SetOptions(merge: true));
  }

  // Get last read timestamp for a user (returns a stream)
  Stream<Timestamp?> getLastRead(String userId1, String userId2, String userId) {
    final chatDoc = getChatDocRef(userId1, userId2);
    return chatDoc.snapshots().map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || data['lastRead'] == null) return null;
      final lastReadMap = data['lastRead'] as Map<String, dynamic>;
      final ts = lastReadMap[userId];
      if (ts is Timestamp) return ts;
      return null;
    });
  }
} 