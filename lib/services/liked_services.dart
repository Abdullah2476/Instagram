import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikedServices {
  Future<void> likeddoc(
    String postId,
    String userId,
    String username,
    String profileImage,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final username = userDoc.data()?['username'] ?? '';
    final profileimage = userDoc.data()?['profileImage'] ?? '';

    final likedDocRef = FirebaseFirestore.instance
        .collection('like')
        .doc(postId)
        .collection('liked users')
        .doc(userId);

    await likedDocRef.set({
      'postId': postId,
      'userId': userId,
      'username': username,
      'profileImage': profileimage,
      'timeStamp': Timestamp.now(),
    });
  }
}
