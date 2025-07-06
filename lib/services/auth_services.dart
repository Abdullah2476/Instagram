import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  //firebase initialization
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //sign up method
  Future<UserCredential> signup(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }

  //sign in
  Future<UserCredential> signin(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }

  Future<void> signout() async {
    final userCredential = await _firebaseAuth.signOut();
    return userCredential;
  }

  //users docs

  Future<void> createUserDocument(User user, String username) async {
    final defaultImageUrl =
        'https://ui-avatars.com/api/?name=User&background=random';
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'username': username,
      'profileImage': defaultImageUrl,
      'defaultImage': defaultImageUrl,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateUserDocument(
    User user,
    String username,
    String name,
    String bio,
    String? imageUrl,
  ) async {
    final updateData = {
      'username': username,
      'name': name,
      'bio': bio,
      'updatedAt': Timestamp.now(),
    };

    if (imageUrl != null) {
      updateData['profileImage'] = imageUrl;
    }

    await _firestore.collection('users').doc(user.uid).update(updateData);
  }
}
