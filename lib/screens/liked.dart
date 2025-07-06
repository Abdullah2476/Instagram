import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/likebottomsheet.dart';
import 'package:instagram/services/liked_services.dart';

class Likes extends StatefulWidget {
  final String postId;
  final String userId;
  final String userName;
  final String profileImage;
  final Axis direction;
  final TextStyle? style;
  final Color? color;

  const Likes({
    super.key,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.profileImage,
    this.direction = Axis.horizontal,
    this.style,
    this.color,
  });

  @override
  State<Likes> createState() => _LikesState();
}

class _LikesState extends State<Likes> {
  final likeDoc = LikedServices();

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      // Like/unlike button
      StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('like')
            .doc(widget.postId)
            .collection('liked users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          final userLiked = snapshot.data?.exists ?? false;

          return IconButton(
            onPressed: () async {
              if (userLiked) {
                // UNLIKE: remove user's like
                await FirebaseFirestore.instance
                    .collection('like')
                    .doc(widget.postId)
                    .collection('liked users')
                    .doc(widget.userId)
                    .delete();
              } else {
                // LIKE: add user's like
                await likeDoc.likeddoc(
                  widget.postId,
                  widget.userId,
                  widget.userName,
                  widget.profileImage,
                );
              }
            },
            onLongPress: () {
              // Show who liked the post
              showModalBottomSheet(
                isDismissible: true,
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return Likebottomsheet(
                    postId: widget.postId,
                    userId: widget.userId,
                    username: widget.userName,
                    profileImage: widget.profileImage,
                  );
                },
              );
            },
            icon: Icon(
              userLiked ? Icons.favorite : Icons.favorite_border_outlined,
              color: userLiked ? Colors.red : widget.color,
            ),
          );
        },
      ),

      const SizedBox(width: 7),

      // Likes count
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('like')
            .doc(widget.postId)
            .collection('liked users')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("0", style: widget.style);
          }
          return Text("${snapshot.data!.docs.length}", style: widget.style);
        },
      ),
    ];

    return widget.direction == Axis.horizontal
        ? Row(children: children)
        : Column(children: children);
  }
}
