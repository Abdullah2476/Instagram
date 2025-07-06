import 'package:flutter/material.dart';

class Myelevatedbutton extends StatelessWidget {
  final VoidCallback? ontap;
  final String text;
  const Myelevatedbutton({super.key, required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: 40,
        width: size.width * .400,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey[300],
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
