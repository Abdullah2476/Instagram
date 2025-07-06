// ignore_for_file: use_build_context_synchronously, invalid_use_of_protected_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:instagram/screens/comment.dart';
import 'package:instagram/screens/folllow.dart';
import 'package:instagram/screens/liked.dart';
import 'package:instagram/screens/main_navigation.dart';
import 'package:instagram/screens/postUpdatepage.dart';
import 'package:instagram/services/post_servies.dart';
import 'package:instagram/widgets/video_player.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});
  final stream = FirebaseFirestore.instance.collection('posts').snapshots();

  bool isVideo(String url) => url.toLowerCase().endsWith('.mp4');
  final TextEditingController _commentcontroller = TextEditingController();
  final postServices = PostServies();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Instagram",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: const [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(Icons.favorite_outline),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(Icons.messenger_outlined),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final postDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: postDocs.length,
            itemBuilder: (context, index) {
              final posts = postDocs[index].data();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                posts['profileImage'] ?? posts['profileImage'],
                              ),
                              radius: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              posts['username'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            FollowButton(followedId: posts['userId']),

                            const SizedBox(width: 10),
                            PopupMenuButton(
                              offset: const Offset(60, 40),
                              onSelected: (value) async {
                                if (value == 1) {
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser!;
                                  final postOwnerSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(posts['postId'])
                                          .get();
                                  final postOwnerId = postOwnerSnapshot
                                      .data()?['userId'];
                                  if (currentUser.uid == postOwnerId) {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) => UpdatePost(
                                              postId: posts['postId'],
                                            ),
                                          ),
                                        )
                                        .then((updated) {
                                          if (updated == true) {
                                            final navState = context
                                                .findAncestorStateOfType<
                                                  MianNavigationState
                                                >();
                                            navState?.setState(() {
                                              navState.currentindex = 0;
                                            });
                                          }
                                        });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Only post admin can edit!",
                                        ),
                                      ),
                                    );
                                  }
                                }
                                if (value == 2) {
                                  postServices.deletePost(
                                    posts['postId'],
                                    context,
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text(
                                        'Edit',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Container(
                      color: Colors.black12,
                      child: posts['mediaUrl'] == null
                          ? const Center(child: Text("Media not found"))
                          : isVideo(posts['mediaUrl'])
                          ? VideoPlayerWidget(videoUrl: posts['mediaUrl']!)
                          : Image.network(
                              posts['mediaUrl']!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Likes(
                          postId: posts['postId'] ?? '',
                          userId: posts['userId'] ?? '',
                          userName: posts['username'] ?? '',
                          profileImage: posts['profileImage'] ?? '',
                          style: const TextStyle(color: Colors.black),
                          color: Colors.black,
                        ),
                        const SizedBox(width: 12),
                        CommentButton(
                          commentController: _commentcontroller,
                          postId: posts['postId'] ?? "",
                          userId: posts['userId'] ?? '',
                          userName: posts['username'] ?? '',
                          profileImage: posts['profileImage'] ?? '',
                          style: const TextStyle(color: Colors.black),
                          color: Colors.black,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.share_outlined, size: 22),
                        const SizedBox(width: 4),
                        const Text('23'),
                        const Spacer(),
                        const Icon(Icons.bookmark_border_outlined),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Text(
                          posts['username'] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            posts['caption'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(thickness: 0.5),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
