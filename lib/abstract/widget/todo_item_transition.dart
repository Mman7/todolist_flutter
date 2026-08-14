import 'package:flutter/material.dart';

enum SlideDirection { left, right }

class TodoItemTransition extends StatefulWidget {
  const TodoItemTransition({
    Key? key,
    required this.child,
    required this.onComplete,
    required this.onDelete,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  State<TodoItemTransition> createState() => TodoItemTransitionState();
}

class TodoItemTransitionState extends State<TodoItemTransition>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<Offset> _entryAnimation;
  late final AnimationController _deleteController;
  late final Animation<double> _deleteAnimation;
  AnimationController? _completeController;
  Animation<Offset>? _completeAnimation;
  bool _isIgnoring = false;

  bool get isIgnoring => _isIgnoring;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward();
    _entryAnimation = Tween<Offset>(
      begin: const Offset(0.0, 50.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));

    _deleteController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _deleteAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _deleteController, curve: Curves.easeIn),
    );
  }

  void startDeleteAnimation() {
    if (_isIgnoring) return;
    setState(() => _isIgnoring = true);
    _deleteController.forward().whenComplete(() {
      widget.onDelete();
      _deleteController.reset();
      if (mounted) setState(() => _isIgnoring = false);
    });
  }

  void startCompleteAnimation({required SlideDirection direction}) {
    if (_isIgnoring) return;
    final double end = direction == SlideDirection.right ? 1.0 : -1.0;
    setState(() => _isIgnoring = true);

    _completeController?.dispose();
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _completeController = controller;
    _completeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(end, 0.0),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));

    controller.forward().whenComplete(() {
      controller.reset();
      widget.onComplete();
      if (mounted) setState(() => _isIgnoring = false);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _deleteController.dispose();
    _completeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget animatedChild = SlideTransition(
      position: _entryAnimation,
      child: SlideTransition(
        position:
            _completeAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
        child: ScaleTransition(
          scale: _deleteAnimation,
          child: widget.child,
        ),
      ),
    );

    return IgnorePointer(
      ignoring: _isIgnoring,
      child: animatedChild,
    );
  }
}
