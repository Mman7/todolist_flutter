import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/src/provider.dart';
import 'package:simple_todo/abstract/providers/theme_provider.dart';
import 'package:tinycolor/tinycolor.dart';

class TodoItem extends StatefulWidget {
  const TodoItem(
      {Key? key,
      required this.opacity,
      required this.child,
      required,
      required this.isSpecial})
      : super(key: key);

  final Widget child;
  final double opacity;
  final String isSpecial;
  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    final themeMode = context.read<ThemeProvider>().themeMode;
    final normalGradientColor = [HexColor('#0500FF'), HexColor('#00D1FF')];
    final specialGradientColor = [HexColor('#FF1FB3'), HexColor('#FFA800')];

    return Opacity(
      opacity: widget.opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 15),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: widget.isSpecial == 'true'
                    ? specialGradientColor
                    : normalGradientColor,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
            boxShadow: [
              BoxShadow(
                  color: widget.isSpecial == 'true'
                      ? HexColor('#FFA506').withOpacity(0.65)
                      : HexColor('#0085FF').withOpacity(0.65),
                  spreadRadius: 0.25,
                  blurRadius: 20,
                  offset: const Offset(0, 0))
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
