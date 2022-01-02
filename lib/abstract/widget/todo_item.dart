import 'package:flutter/material.dart';

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
    final brightness = MediaQuery.of(context).platformBrightness;

    return Opacity(
      opacity: widget.opacity,
      child: Padding(
        padding: const EdgeInsets.all(5.5),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.grey.withOpacity(0.65),
                    spreadRadius: 6,
                    blurRadius: 10,
                    offset: const Offset(0, 5))
              ],
              borderRadius: BorderRadius.circular(7.5),
              color: Theme.of(context).colorScheme.primary),
          child: widget.child,
        ),
      ),
    );
  }
}
