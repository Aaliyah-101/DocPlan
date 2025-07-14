import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String country,
    required String role,
    String? specialty,
    Map<String, List<String>>? availability,
    String? profilePictureUrl,
    String? bio,
  }) async {
    try {
      print('DEBUG: Creating user with role: $role');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        print('DEBUG: User created with UID: ${result.user!.uid}');
        // Create user document in Firestore
        UserModel userModel = UserModel(
          uid: result.user!.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          country: country,
          role: role,
          createdAt: DateTime.now(),
          specialty: specialty,
          availability: availability,
          profilePictureUrl: profilePictureUrl,
          bio: bio,
        );

        print('DEBUG: Saving user model to Firestore with role: ${userModel.role}');
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toMap());

        // If doctor, create doctor document
        if (role == 'doctor') {
          print('DEBUG: Creating doctor document');
          await _firestore.collection('doctors').doc(result.user!.uid).set({
            'status': 'available',
            'userId': result.user!.uid,
            'name': name,
            'specialty': specialty ?? '',
            'availability': availability ?? {},
            'location': null,
            'radius': 1000, // Default radius in meters
          });
        }

        await saveFcmToken(result.user!.uid);
      }

      return result;
    } catch (e) {
      print('DEBUG: Error in signUp: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        await saveFcmToken(result.user!.uid);
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      print('DEBUG: Fetching user data for UID: $uid');
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      print('DEBUG: Document exists: ${doc.exists}');
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('DEBUG: Raw user data: $data');
        final userModel = UserModel.fromMap(data);
        print('DEBUG: Parsed user model role: ${userModel.role}');
        return userModel;
      }
      print('DEBUG: Document does not exist');
      return null;
    } catch (e) {
      print('DEBUG: Error fetching user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phoneNumber,
    required String country,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'phoneNumber': phoneNumber,
      'country': country,
    });
  }

  // Save FCM token to Firestore
  Future<void> saveFcmToken(String uid) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': fcmToken,
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Update user role (for fixing existing users)
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role,
      });
      print('DEBUG: Updated user role to: $role');
    } catch (e) {
      print('DEBUG: Error updating user role: $e');
      rethrow;
    }
  }
}
