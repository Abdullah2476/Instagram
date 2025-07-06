// comment_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/services/comment_services.dart';

class Likebottomsheet extends StatelessWidget {
  final commentDoc = CommentServices();
  final String postId;
  final String userId;
  final String username;
  final String profileImage;

  Likebottomsheet({
    super.key,
    required this.postId,
    required this.userId,
    required this.username,
    required this.profileImage,
  });
  Stream<QuerySnapshot> likes(String postId) {
    return FirebaseFirestore.instance
        .collection('like')
        .doc(postId)
        .collection('liked users')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: StreamBuilder<QuerySnapshot>(
        stream: likes(postId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No likes"));
          }

          final likes = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    'Liked By',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: likes.length,
                  itemBuilder: (context, index) {
                    final commentStream =
                        likes[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          commentStream['profileImage'] ??
                              commentStream['defaultImage'],
                        ),
                      ),

                      title: Text(commentStream['username'] ?? 'No Name'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
