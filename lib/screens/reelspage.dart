import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/comment.dart';
import 'package:instagram/screens/liked.dart';
import 'package:instagram/widgets/video_player.dart';

class Reelspage extends StatelessWidget {
  Reelspage({super.key});

  final stream = FirebaseFirestore.instance
      .collection('posts')
      .where('mediaType', isEqualTo: 'video')
      .snapshots();
  final TextEditingController _commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final postDocs = snapshot.data!.docs;

          if (postDocs.isEmpty) {
            return Center(
              child: Text(
                "No reels to show.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: postDocs.length + 1,
            itemBuilder: (context, index) {
              if (index == postDocs.length) {
                return Center(
                  child: Text(
                    "No more reels.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }
              final post = postDocs[index].data() as Map<String, dynamic>;
              final videoUrl = post['mediaUrl'] as String? ?? '';

              return Stack(
                children: [
                  Positioned.fill(child: VideoPlayerWidget(videoUrl: videoUrl)),
                  Positioned(
                    top: 40,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Reels",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.camera_alt_outlined, color: Colors.white),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 80,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(
                                post['profileImage'] ?? post['defaultImage'],
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              post['username'] ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          post['caption'] ?? '',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 5,
                    bottom: 5,

                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Likes(
                            direction: Axis.vertical,
                            postId: post['postId'] ?? "",
                            userId: post['userId'] ?? '',
                            userName: post['username'] ?? '',
                            profileImage: post['profileImage'] ?? '',
                            style: TextStyle(color: Colors.white),
                            color: Colors.white,
                          ),
                          CommentButton(
                            direction: Axis.vertical,
                            commentController: _commentController,
                            postId: post['postId'] ?? "",
                            userId: post['userId'] ?? '',
                            userName: post['username'] ?? '',
                            profileImage: post['profileImage'] ?? '',
                            style: TextStyle(color: Colors.white),
                            color: Colors.white,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Icon(Icons.share, color: Colors.white),
                                Text(
                                  '0',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(Icons.more_horiz, color: Colors.white),
                          ),
                          SizedBox(height: 10, width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
