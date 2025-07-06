import 'package:flutter/material.dart';
import 'package:instagram/screens/homepage.dart';
import 'package:instagram/screens/profilepage.dart';
import 'package:instagram/screens/reelspage.dart';
import 'package:instagram/screens/searchpage.dart';
import 'package:instagram/screens/udloadpage.dart';

class MianNavigation extends StatefulWidget {
  const MianNavigation({super.key});

  @override
  State<MianNavigation> createState() => MianNavigationState();
}

class MianNavigationState extends State<MianNavigation> {
  int currentindex = 0;
  late final List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    _screens = [
      Homepage(),
      Searchpage(),
      Uploadpage(
        onUploadComplete: () {
          setState(() {
            currentindex = 0;
          });
        },
      ),
      Reelspage(),
      Profilepage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: currentindex,
        onTap: (value) {
          setState(() {
            currentindex = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Post'),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            label: 'Reels',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: _screens[currentindex],
    );
  }
}
