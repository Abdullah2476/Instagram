import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePostServies {
  Stream<QuerySnapshot> getImagePosts() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .where('mediaType', isEqualTo: 'image')
        .snapshots();
  }
}
