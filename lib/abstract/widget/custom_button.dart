import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({Key? key, required this.callback, required this.iconData})
      : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  final callback;
  final IconData iconData;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        color: Colors.white, onPressed: callback, icon: Icon(iconData));
  }
}
