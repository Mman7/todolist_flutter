import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  CustomButton({Key? key, required this.callback, required this.iconData})
      : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  final callback;
  IconData iconData;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        color: Colors.white, onPressed: callback, icon: Icon(iconData));
  }
}
