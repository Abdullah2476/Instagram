import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/commentpage.dart';

class CommentButton extends StatelessWidget {
  final TextEditingController commentController;
  final String postId;
  final String userId;
  final String userName;
  final String profileImage;
  final Axis direction;
  final TextStyle? style;
  final Color? color;

  const CommentButton({
    super.key,
    required this.commentController,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.profileImage,
    this.direction = Axis.horizontal,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      IconButton(
        onPressed: () {
          showModalBottomSheet(
            isDismissible: true,
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return CommentBottomSheet(
                commentController: commentController,
                postId: postId,
                userId: userId,
                username: userName,
                profileImage: profileImage,
              );
            },
          );
        },
        icon: Icon(Icons.message, color: color),
      ),
      SizedBox(width: 7),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('comments')
            .doc(postId)
            .collection('posted comments')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("0", style: style);
          }
          return Text("${snapshot.data!.docs.length}", style: style);
        },
      ),
    ];
    return direction == Axis.horizontal
        ? Row(children: children)
        : Column(children: children);
  }
}
