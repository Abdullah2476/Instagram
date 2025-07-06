import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram/services/follow_services.dart';

class FollowButton extends StatefulWidget {
  final String followedId; // The user to follow

  const FollowButton({super.key, required this.followedId});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  Future<void> checkIfFollowing() async {
    final doc = await FirebaseFirestore.instance
        .collection('follows')
        .doc(currentUser.uid)
        .collection('follow users')
        .doc(widget.followedId)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  Future<void> toggleFollow() async {
    if (isFollowing) {
      // Unfollow
      await FirebaseFirestore.instance
          .collection('follows')
          .doc(currentUser.uid)
          .collection('follow users')
          .doc(widget.followedId)
          .delete();
    } else {
      // Follow
      final followService = FollowServices();
      await followService.follows(widget.followedId, currentUser.uid);
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: toggleFollow,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
      child: Text(isFollowing ? "Following" : "Follow"),
    );
  }
}
