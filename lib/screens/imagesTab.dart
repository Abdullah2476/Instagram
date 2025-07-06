import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/services/profile_post_servies.dart';

class Imagestab extends StatelessWidget {
  Imagestab({super.key});

  final profilePostServices = ProfilePostServies();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: profilePostServices.getImagePosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final posts = snapshot.data!.docs;

        if (posts.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Icon(Icons.image), Text("No Images")],
          );
        }

        return GridView.builder(
          itemCount: posts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            final data = posts[index].data() as Map<String, dynamic>;
            final imageUrl = data['mediaUrl'];

            return Image.network(imageUrl, fit: BoxFit.cover);
          },
        );
      },
    );
  }
}
