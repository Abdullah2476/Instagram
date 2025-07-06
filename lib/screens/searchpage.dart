import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/widgets/mytextfield.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final TextEditingController _searchController = TextEditingController();
  Stream<QuerySnapshot>? _searchResultsStream;

  Stream<QuerySnapshot> searchStream(String searchText) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: searchText.trim())
        .snapshots();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _searchResultsStream = searchStream(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Mytextfield(
                  controller: _searchController,
                  hintText: 'Search',
                  labeltext: 'Search',
                ),
              ),
              IconButton(onPressed: _onSearch, icon: Icon(Icons.search)),
            ],
          ),
          Expanded(
            child: _searchResultsStream == null
                ? Center(child: Text("Search for users"))
                : StreamBuilder<QuerySnapshot>(
                    stream: _searchResultsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("No users found"));
                      }

                      final users = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                user['profileImage'] ?? '',
                              ),
                            ),
                            title: Text(user['username'] ?? ''),
                            subtitle: Text(user['email'] ?? ''),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
