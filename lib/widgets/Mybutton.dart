// ignore_for_file: file_names

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Mybutton extends StatelessWidget {
  final String text;
  final Color color;
  final Border? border;
  final TextStyle? style;
  final VoidCallback ontap;
  bool isloading = false;
  Mybutton({
    super.key,
    required this.text,
    required this.color,
    required this.border,
    this.style,
    required this.isloading,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          height: 50,
          width: double.infinity,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            border: border,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: isloading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(text, style: style),
          ),
        ),
      ),
    );
  }
}
