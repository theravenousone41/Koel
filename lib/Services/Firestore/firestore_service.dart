import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  /// Save user data to Firestore under 'users/{uid}'
  static Future<void> saveUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime? dob,
    required String gender,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
      'dob': dob != null ? dob.toIso8601String() : null,
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  /// Fetch all users except the current one
  static Future<List<Map<String, dynamic>>> getAllOtherUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final snapshot = await _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUser.uid)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
  /// Stream all other users
  static Stream<QuerySnapshot> streamOtherUsers() {
    final currentUser = FirebaseAuth.instance.currentUser!;
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUser.uid)
        .snapshots();
  }


  /// Send a chat message to 'messages' collection
  static Future<void> sendMessage({
    required String messageText,
    required String senderId,
    required String senderEmail,
  }) async {
    await _firestore.collection('messages').add({
      'text': messageText.trim(),
      'senderId': senderId,
      'senderEmail': senderEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Stream chat messages ordered by timestamp ascending
  static Stream<QuerySnapshot> getMessagesStream() {
    return _firestore
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
