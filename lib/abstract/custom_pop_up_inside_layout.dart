import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomPopUpInside extends StatelessWidget {
  CustomPopUpInside({Key? key, required this.text, required this.iconData})
      : super(key: key);

  IconData iconData;
  String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        Icon(iconData, color: Colors.white)
      ],
    );
  }
}
