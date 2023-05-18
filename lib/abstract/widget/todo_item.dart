import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class TodoItem extends StatefulWidget {
  const TodoItem(
      {Key? key,
      required this.opacity,
      required this.child,
      required this.isHighlight})
      : super(key: key);

  final Widget child;
  final double opacity;
  final String isHighlight;

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> with TickerProviderStateMixin {
  late AnimationController slideController;
  late Animation<Offset> slideAnimation;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    slideController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    )..forward();
    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, (50.0)),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(
        milliseconds: 900,
      ),
      vsync: this,
      value: 0.1,
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.fastEaseInToSlowEaseOut,
    );
  }

  @override
  void dispose() {
    slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColour = widget.isHighlight == 'true'
        ? HexColor('#1C92FF') // blue
        : HexColor('#0057FF'); // Darker blue

    final shadowColor =
        widget.isHighlight == 'true' ? HexColor('#1C92FF') : Colors.transparent;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Opacity(
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
        ),
      ),
    );
  }
}
