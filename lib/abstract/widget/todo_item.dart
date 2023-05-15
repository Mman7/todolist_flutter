import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class TodoItem extends StatefulWidget {
  const TodoItem(
      {Key? key,
      required this.opacity,
      required this.child,
      required,
      required this.isHighlight})
      : super(key: key);

  final Widget child;
  final double opacity;
  final String isHighlight;

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    final backgroundColour = widget.isHighlight == 'true'
        ? HexColor('#1C92FF') // blue
        : HexColor('#0057FF'); // Darker blue

    final shadowColor =
        widget.isHighlight == 'true' ? HexColor('#1C77FF') : Colors.transparent;

    return Opacity(
      opacity: widget.opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: backgroundColour,
            boxShadow: [
              BoxShadow(
                  color: shadowColor,
                  spreadRadius: 0,
                  blurRadius: 45,
                  offset: const Offset(0, 0)),
              BoxShadow(
                  color: shadowColor,
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 0))
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
