import 'package:flutter/material.dart';
import 'package:instagram/screens/login.dart';
import 'package:instagram/services/auth_services.dart';

class SettingPopup extends StatelessWidget {
  SettingPopup({super.key});
  final logout = AuthServices();
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: Offset(40, 40),
      icon: Icon(Icons.menu),
      initialValue: 1,
      onSelected: (value) {
        if (value == 1) {
          logout.signout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Login();
              },
            ),
          );
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Icon(Icons.logout_outlined), Text("Log out")],
            ),
          ),
        ];
      },
    );
  }
}
