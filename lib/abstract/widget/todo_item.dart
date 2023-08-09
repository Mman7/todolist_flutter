import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/abstract/widget/custom_button.dart';
import 'package:simple_todo/abstract/widget/custom_pop_up_inside_layout.dart';

import '../providers/data_provider.dart';

class TodoItem extends StatefulWidget {
  const TodoItem(
      {Key? key,
      required this.index,
      required this.isTodoTask,
      required this.opacity,
      required this.isHighlight,
      required this.title})
      : super(key: key);

  final double opacity;
  final bool isTodoTask;
  final int index;
  final String isHighlight;
  final String title;

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> with TickerProviderStateMixin {
  late DataProvider dataContext;
  late TextEditingController _textFieldController;

  late AnimationController slideController;
  late Animation<Offset> slideAnimation;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _slideAniController;
  late Animation<Offset> _slideAniAnimation;

  late AnimationController _scaleAniController;
  late Animation<double> _scaleAniAnimation;

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    dataContext = context.read<DataProvider>();

    _scaleAniController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAniAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _scaleAniController, curve: Curves.easeIn));

    slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 50.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));

    _slideAniController = AnimationController(
      duration: const Duration(milliseconds: 0),
      vsync: this,
    )..forward();
    _slideAniAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideAniController,
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

  startScaleAnimation({callback}) {
    _scaleAniController.forward();
    _scaleAniAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scaleAniController.reset();
        callback();
      }
    });
  }

  startSlideAnimation({value, callback}) {
    setState(() {});
    _slideAniController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
    _slideAniAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: Offset(value, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideAniController,
      curve: Curves.fastEaseInToSlowEaseOut,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _slideAniController.reset();
          callback();
        }
      });
  }

  @override
  void dispose() {
    slideController.dispose();
    _scaleController.dispose();
    _textFieldController.dispose();
    _slideAniController.dispose();
    _scaleAniController.dispose();
    super.dispose();
  }

  editTask(int index) async {
    final _todoTask = dataContext.todoTasks;
    _textFieldController.text = _todoTask[index][1];
    final text = await openDialog('Edit Task', 'Edit');
    if (text == null) return;
    setState(() {
      _todoTask[index][1] = text;
    });
    _textFieldController.text = '';
    dataContext.saveData('todo', _todoTask);
    dataContext.showSnackBar(context: context, message: 'Successfully Edited');
    dataContext.updateValue();
  }

  openDialog(String _title, String _buttonText) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shadowColor: HexColor('#1C92FF').withAlpha(100),
              backgroundColor: HexColor('#040934'),
              title: Text(
                _title,
                style: TextStyle(
                    fontWeight:
                        Theme.of(context).textTheme.bodyLarge?.fontWeight,
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize),
              ),
              content: TextField(
                cursorColor: Colors.white,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                controller: _textFieldController,
              ),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: HexColor('#0057FF'),
                        foregroundColor: Colors.white),
                    onPressed: () =>
                        Navigator.of(context).pop(_textFieldController.text),
                    child: Text(
                      _buttonText,
                    ))
              ],
            ));
  }

  void _showPopupMenu() async {
    dynamic offset = dataContext.buttonPos;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    await showMenu(
      color: HexColor('#040934'),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy, width - offset.dx, height - offset.dy),
      items: [
        PopupMenuItem(
          ///* Solution of this
          ///* https://stackoverflow.com/questions/69939559/showdialog-bug-dialog-isnt-triggered-from-popupmenubutton-in-flutter
          onTap: () {
            Future.delayed(
                const Duration(seconds: 0), () => editTask(widget.index));
          },
          child: const CustomPopUpInside(text: 'Edit', iconData: Icons.edit),
        ),
        PopupMenuItem(
          onTap: () {
            startScaleAnimation(
                callback: () => dataContext.deleteTask(
                    list: dataContext.todoTasks,
                    removeIndex: widget.index,
                    databasename: 'todo',
                    context: context));
          },
          child:
              const CustomPopUpInside(text: 'Delete', iconData: Icons.delete),
        ),
      ],
      elevation: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColour = widget.isHighlight == 'true'
        ? HexColor('#1C92FF') // blue
        : HexColor('#0057FF'); // Darker blue

    final shadowColor =
        widget.isHighlight == 'true' ? HexColor('#1C92FF') : Colors.transparent;

    final textStyle =
        widget.isTodoTask ? TextDecoration.none : TextDecoration.lineThrough;
    var firstIcon = widget.isTodoTask ? Icons.done : Icons.keyboard_return;
    var secondIcon = widget.isTodoTask ? Icons.more_vert : Icons.delete;

    return ScaleTransition(
      scale: _scaleAniAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SlideTransition(
            position: _slideAniAnimation,
            child: Opacity(
              opacity: widget.opacity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
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
                  child: GestureDetector(
                    onDoubleTap: () {
                      if (widget.isTodoTask) {
                        dataContext.setAsSpecial(
                            index: widget.index, context: context);
                      }
                    },
                    child: ListTile(
                      title: Text(
                        widget.title,
                        style: TextStyle(
                            decoration: textStyle,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.fontSize),
                      ),
                      trailing: Wrap(
                        children: [
                          CustomButton(
                              callback: () {
                                if (widget.isTodoTask) {
                                  startSlideAnimation(
                                      value: 1.0,
                                      callback: () => dataContext.completeTask(
                                          context: context,
                                          completedIndex: widget.index));
                                } else {
                                  startSlideAnimation(
                                      value: -1.0,
                                      callback: () => dataContext.returnTask(
                                          context: context,
                                          returnItemIndex: widget.index));
                                }
                              },
                              iconData: firstIcon),
                          CustomButton(
                              callback: () {
                                if (widget.isTodoTask) {
                                  _showPopupMenu();
                                } else {
                                  startScaleAnimation(
                                      callback: () => dataContext.deleteTask(
                                          list: dataContext.doneTasks,
                                          removeIndex: widget.index,
                                          databasename: 'done',
                                          context: context));
                                }
                              },
                              iconData: secondIcon),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
