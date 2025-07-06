import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:instagram/screens/edit_profile.dart';
import 'package:instagram/screens/imagesTab.dart';
import 'package:instagram/widgets/myelevatedbutton.dart';
import 'package:instagram/widgets/setting_popup.dart';
import 'package:instagram/services/count_services.dart';

class Profilepage extends StatelessWidget {
  const Profilepage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final countService = CountServices();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Profile"),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.add)),
            SettingPopup(),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final profileImage =
                (userData['profileImage'] as String?)?.isNotEmpty == true
                ? userData['profileImage']
                : 'https://ui-avatars.com/api/?name=User&background=random';
            final username = userData['username'] as String? ?? 'No Username';
            final bio = userData['bio'] as String? ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            profileImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                username,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FutureBuilder(
                              future: Future.wait([
                                countService.getPostCount(),
                                countService.getFollowersCount(),
                                countService.getFollowingCount(),
                              ]),
                              builder:
                                  (context, AsyncSnapshot<List<int>> snapshot) {
                                    if (!snapshot.hasData) {
                                      return CircularProgressIndicator();
                                    }
                                    final posts = snapshot.data![0];
                                    final followers = snapshot.data![1];
                                    final following = snapshot.data![2];
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              posts.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Posts',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              followers.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Follower',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              following.toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Following',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if ((userData['bio'] ?? '').trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      bio,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Myelevatedbutton(
                      text: 'Edit profile',
                      ontap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(),
                          ),
                        );
                      },
                    ),
                    Myelevatedbutton(text: 'Share profile', ontap: () {}),
                    Container(
                      height: 40,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[300],
                      ),
                      child: Icon(Icons.person_add),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TabBar(
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(icon: Icon(Icons.menu_outlined)),
                    Tab(icon: Icon(Icons.video_collection_outlined)),
                    Tab(icon: Icon(Icons.contacts_outlined)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Imagestab(),
                      Center(child: Text("Coming Soon")),
                      Center(child: Text("Coming Soon")),
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
