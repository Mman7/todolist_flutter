import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class TodoItem extends StatefulWidget {
  const TodoItem({
    Key? key,
    required this.opacity,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final double opacity;
  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.opacity,
      child: Padding(
        padding: const EdgeInsets.all(5.5),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(7.5),
              color: HexColor('#224064')),
          child: widget.child,
        ),
      ),
    );
  }
}
