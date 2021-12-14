import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton({Key? key, required this.callback, required this.iconData})
      : super(key: key);
  final callback;
  IconData iconData;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        color: Colors.white, onPressed: callback, icon: Icon(iconData));
  }
}
