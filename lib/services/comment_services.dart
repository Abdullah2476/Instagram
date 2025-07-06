import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentServices {
  Future commentdoc(
    String postId,
    String commentText,
    String userId,
    String username,
    String profileImage,
  ) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final username = userDoc.data()?['username'] ?? '';
    final profileimage = userDoc.data()?['profileImage'] ?? '';
    final commentdoc = FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('posted comments')
        .doc();
    final commentid = FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('posted comments')
        .doc()
        .id;

    await commentdoc.set({
      'postId': postId,
      'commentId': commentid,
      'commentText': commentText,
      'userId': userId,
      'profileImage': profileimage,
      'username': username,
      'timeStamp': Timestamp.now(),
    });
  }
}
