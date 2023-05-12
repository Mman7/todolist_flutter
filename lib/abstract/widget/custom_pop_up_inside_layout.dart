import 'package:flutter/material.dart';

class CustomPopUpInside extends StatelessWidget {
  const CustomPopUpInside(
      {Key? key, required this.text, required this.iconData})
      : super(key: key);

  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
        Icon(iconData, color: Theme.of(context).secondaryHeaderColor)
      ],
    );
  }
}
