import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CountServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get post count
  Future<int> getPostCount() async {
    final userId = _auth.currentUser!.uid;
    final snapshot = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.length;
  }

  // Get followers count
  Future<int> getFollowersCount() async {
    final userId = _auth.currentUser!.uid;
    final snapshot = await _firestore
        .collection('followers')
        .doc(userId)
        .collection('follower users')
        .get();
    return snapshot.docs.length;
  }

  // Get following count
  Future<int> getFollowingCount() async {
    final userId = _auth.currentUser!.uid;
    final snapshot = await _firestore
        .collection('follows')
        .doc(userId)
        .collection('follow users')
        .get();
    return snapshot.docs.length;
  }
}
