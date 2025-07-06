// comment_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/services/comment_services.dart';
import 'package:instagram/widgets/mytextfield.dart';

class CommentBottomSheet extends StatelessWidget {
  final TextEditingController commentController;
  final commentDoc = CommentServices();
  final String postId;
  final String userId;
  final String username;
  final String profileImage;

  CommentBottomSheet({
    super.key,

    required this.commentController,
    required this.postId,
    required this.userId,
    required this.username,
    required this.profileImage,
  });
  Stream<QuerySnapshot> getcomments(String postId) {
    return FirebaseFirestore.instance
        .collection('comments')
        .doc(postId)
        .collection('posted comments')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: 350,
        child: StreamBuilder<QuerySnapshot>(
          stream: getcomments(postId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 100),
                    Center(child: Text("No coments yet")),
                    SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Mytextfield(
                              controller: commentController,
                              hintText: 'Type Comment...',
                              labeltext: 'Comment',
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              commentDoc.commentdoc(
                                postId,
                                commentController.text.toString(),
                                userId,
                                username,
                                profileImage,
                              );
                            },
                            icon: Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final comments = snapshot.data!.docs;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final commentStream =
                          comments[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              commentStream['profileImage'],
                            ),
                          ),

                          title: Text(commentStream['username'] ?? 'No Name'),
                          subtitle: Text(commentStream['commentText']),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Mytextfield(
                          controller: commentController,
                          hintText: 'Type Comment...',
                          labeltext: 'Comment',
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          commentDoc.commentdoc(
                            postId,
                            commentController.text.toString(),
                            userId,
                            username,
                            profileImage,
                          );
                        },
                        icon: Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
