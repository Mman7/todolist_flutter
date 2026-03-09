import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/abstract/localdatabase.dart';
import 'package:simple_todo/abstract/widget/custom_button.dart';
import 'package:simple_todo/abstract/widget/custom_pop_up_inside_layout.dart';
import 'package:simple_todo/model/todo_data.dart';

import '../providers/data_provider.dart';

enum SlideDirection { left, right }

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
  final bool isHighlight;
  final String title;

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> with TickerProviderStateMixin {
  late DataProvider dataContext;
  late TextEditingController _textFieldController;

  late AnimationController slideController;
  late Animation<Offset> slideAnimation;

  late AnimationController _completedAniController;
  late Animation<Offset> _completedAnimation;

  late AnimationController _deleteAniController;
  late Animation<double> _deleteAnimation;

  bool isIgnore = false;

  /// This feature is to prevent users from deleting items too quickly resulting in deleting items twice.
  setIgnore({required bool value}) {
    setState(() {
      isIgnore = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    dataContext = context.read<DataProvider>();

    _deleteAniController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _deleteAnimation = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _deleteAniController, curve: Curves.easeIn));

    slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward();
    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 50.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));

    _completedAniController = AnimationController(
      duration: const Duration(milliseconds: 0),
      vsync: this,
    )..forward();
    _completedAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _completedAniController,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));

    super.initState();
  }

  startDeleteAnimation({callback}) {
    setIgnore(value: true);
    // start animation
    _deleteAniController.forward().whenComplete(() {
      callback();
      _deleteAniController.reset();
    });
    setIgnore(value: false);
  }

  /// [slideDirection] can only be either "left" or "right"
  void _completedTodoAnimation(
      {required SlideDirection slideDirection, callback}) {
    double slideDirectToValue = 0;
    if (slideDirection == SlideDirection.right) slideDirectToValue = 1.0;
    if (slideDirection == SlideDirection.left) slideDirectToValue = -1.0;

    setIgnore(value: true);

    _completedAniController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
    _completedAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: Offset(slideDirectToValue, 0.0),
    ).animate(CurvedAnimation(
      parent: _completedAniController,
      curve: Curves.fastEaseInToSlowEaseOut,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _completedAniController.reset();
          callback();
          setIgnore(value: false);
        }
      });
  }

  @override
  void dispose() {
    slideController.dispose();
    _textFieldController.dispose();
    _completedAniController.dispose();
    _deleteAniController.dispose();
    super.dispose();
  }

  editTask(int index) async {
    final List<TodoData> _todoTask = dataContext.todoTasks;
    _textFieldController.text = _todoTask[index].title;
    final String? text = await openDialog();
    if (text == null) return;
    setState(() {
      _todoTask[index].title = text;
    });
    _textFieldController.text = '';
    Database.saveData(databaseName: DatabaseName.todo, newList: _todoTask);
    dataContext.updateValue();
    dataContext.showSnackBarFromMessenger(
        messenger: ScaffoldMessenger.maybeOf(context),
        backgroundColor: Theme.of(context).primaryColor,
        message: 'Successfully Edited');
  }

  openDialog() {
    return showDialog<String>(
        context: context,
        builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                shadowColor: HexColor('#1C92FF').withAlpha(100),
                backgroundColor: HexColor('#040934'),
                title: const Text(
                  'Edit Task',
                ),
                content: TextField(
                  cursorColor: Colors.white,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  controller: _textFieldController,
                ),
                actions: [
                  TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_textFieldController.text),
                      child: const Text(
                        'Edit',
                      )),
                ],
              ),
            ));
  }

  void _showPopupMenu(int index, String itemTitle) async {
    final dynamic offset = dataContext.buttonPos;
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

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
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: itemTitle));
            dataContext.showSnackBarFromMessenger(
                messenger: ScaffoldMessenger.maybeOf(context),
                backgroundColor: Theme.of(context).primaryColor,
                message: 'Task Copied');
          },
          child: const CustomPopUpInside(text: 'Copy ', iconData: Icons.copy),
        ),
        PopupMenuItem(
          onTap: () async {
            startDeleteAnimation(
                callback: () => dataContext.removeItem(
                    datalist: DatabaseName.todo,
                    index: index,
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
    final HexColor backgroundColour = widget.isHighlight
        ? HexColor('#0057FF') // blue
        : HexColor('#2d2a36'); // default color

    final Color shadowColor = widget.isHighlight
        ? HexColor('#0057FF')
        : HexColor('#0057FF').withAlpha(0);

    final TextDecoration textStyle =
        widget.isTodoTask ? TextDecoration.none : TextDecoration.lineThrough;
    final IconData firstIcon =
        widget.isTodoTask ? Icons.done : Icons.keyboard_return;
    final IconData secondIcon =
        widget.isTodoTask ? Icons.more_vert : Icons.delete;

    //
    return SlideTransition(
      position: slideAnimation,
      child: SlideTransition(
        position: _completedAnimation,
        child: ScaleTransition(
          scale: _deleteAnimation,
          child: Opacity(
            opacity: widget.opacity,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: backgroundColour,
                  boxShadow: [
                    BoxShadow(
                        color: shadowColor,
                        spreadRadius: 0,
                        blurRadius: 32,
                        offset: const Offset(0, 0)),
                    BoxShadow(
                        color: shadowColor,
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 0))
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Badge(
                  isLabelVisible: widget.isHighlight,
                  offset: const Offset(0, -5),
                  backgroundColor: shadowColor,
                  label: widget.isHighlight ? const Icon(Icons.star) : null,
                  child: IgnorePointer(
                    ignoring: isIgnore,
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
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.fontSize),
                        ),
                        contentPadding: const EdgeInsets.only(left: 10),
                        trailing: Wrap(
                          children: [
                            CustomButton(
                                callback: () {
                                  DatabaseName dataList = widget.isTodoTask
                                      ? DatabaseName.todo
                                      : DatabaseName.done;
                                  SlideDirection slideDirection =
                                      widget.isTodoTask
                                          ? SlideDirection.right
                                          : SlideDirection.left;

                                  _completedTodoAnimation(
                                      slideDirection: slideDirection,
                                      callback: () =>
                                          dataContext.completeToggle(
                                              context: context,
                                              datalist: dataList,
                                              index: widget.index));
                                },
                                iconData: firstIcon),
                            CustomButton(
                                callback: () {
                                  if (widget.isTodoTask) {
                                    _showPopupMenu(widget.index, widget.title);
                                  } else {
                                    startDeleteAnimation(
                                        callback: () => dataContext.removeItem(
                                            datalist: DatabaseName.done,
                                            context: context,
                                            index: widget.index));
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
      ),
    );
  }
}
