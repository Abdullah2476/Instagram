import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowServices {
  Future<void> follows(String followedId, String userId) async {
    final user = FirebaseAuth.instance.currentUser;
    final userdoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final username = userdoc.data()?['username'];
    final profileImage = userdoc.data()?['profileImage'];
    final followsdoc = FirebaseFirestore.instance
        .collection('follows')
        .doc(user.uid)
        .collection('follow users')
        .doc(followedId);

    await followsdoc.set({
      'followedId': followedId,
      'userId': userId,
      'username': username,
      'profileImage': profileImage,
      'timestamp': Timestamp.now(),
    });
  }
}
