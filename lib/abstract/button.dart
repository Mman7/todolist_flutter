import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatefulWidget {
  CustomButton({Key? key, required this.callback, required this.iconData})
      : super(key: key);

  final Function callback;
  IconData iconData;

  @override
  _CustomButtnState createState() => _CustomButtnState();
}

class _CustomButtnState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(),
        onPressed: () => widget.callback(),
        icon: Icon(
          widget.iconData,
          color: Colors.white,
        ),
      ),
    );
  }
}
