import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:simple_todo/abstract/providers/theme_provider.dart';
import 'package:tinycolor/tinycolor.dart';

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
    final themeMode = context.read<ThemeProvider>().themeMode;
    isDarkTheme(Color color) {
      if (themeMode == ThemeMode.dark) return color.darken(30);
      return color.darken(13);
    }

    return Opacity(
      opacity: widget.opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 7.5),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: themeMode == ThemeMode.dark
                        ? Colors.black26
                        : Colors.grey,
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 5))
              ],
              borderRadius: BorderRadius.circular(7.5),
              color: isDarkTheme(
                  Theme.of(context).colorScheme.primary.withBlue(500))),
          child: widget.child,
        ),
      ),
    );
  }
}
