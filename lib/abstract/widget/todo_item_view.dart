import 'dart:ui';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:simple_todo/model/localdatabase.dart';
import 'package:simple_todo/model/todo_data.dart';
import 'package:simple_todo/abstract/widget/custom_button.dart';
import 'package:simple_todo/abstract/widget/custom_pop_up_inside_layout.dart';
import 'package:simple_todo/abstract/widget/todo_item_transition.dart';

import '../providers/data_provider.dart';

/// A single list item widget used in the todo app.
///
/// Responsibilities:
/// - Display the task title and action buttons
/// - Support editing, copying, deleting, and marking as complete
/// - Run entry, completion and deletion animations
class TodoItemView extends StatefulWidget {
  const TodoItemView({
    Key? key,
    required this.todoItem,
    required this.index,
  }) : super(key: key);

  final TodoItem todoItem;
  final int index;

  @override
  State<TodoItemView> createState() => _TodoItemViewState();
}

class _TodoItemViewState extends State<TodoItemView>
    with SingleTickerProviderStateMixin {
  // Provider that holds the app state and helper methods
  late DataProvider dataContext;

  // Controller used for the inline edit TextField in the edit dialog
  late TextEditingController _textFieldController;

  final GlobalKey<TodoItemTransitionState> _transitionKey =
      GlobalKey<TodoItemTransitionState>();

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    dataContext = context.read<DataProvider>();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  editTask() async {
    _textFieldController.text = widget.todoItem.title;
    final String? text = await openDialog();
    if (text == null) return;
    setState(() {
      widget.todoItem.title = text;
    });
    _textFieldController.text = '';
    Database.saveData(
        databaseName: DatabaseName.todo, newList: dataContext.todoTasks);
    dataContext.updateValue();
    dataContext.showSnackBarFromMessenger(
        messenger: ScaffoldMessenger.maybeOf(context),
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
            Future.delayed(const Duration(seconds: 0), () => editTask());
          },
          child: const CustomPopUpInside(text: 'Edit', iconData: Icons.edit),
        ),
        PopupMenuItem(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: itemTitle));
            dataContext.showSnackBarFromMessenger(
                messenger: ScaffoldMessenger.maybeOf(context),
                message: 'Task Copied');
          },
          child: const CustomPopUpInside(text: 'Copy ', iconData: Icons.copy),
        ),
        PopupMenuItem(
          onTap: () async {
            _transitionKey.currentState?.startDeleteAnimation();
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
    final HexColor backgroundColour = widget.todoItem.isHighlight
        ? HexColor('#0057FF') // blue
        : HexColor('#2d2a36'); // default color

    final Color shadowColor = widget.todoItem.isHighlight
        ? HexColor('#0057FF')
        : HexColor('#0057FF').withAlpha(0);
    final bool isTodoTask = !widget.todoItem.isCompleted;
    final isOpcacity = widget.todoItem.isCompleted ? 0.5 : 1.0;

    final TextDecoration textStyle =
        isTodoTask ? TextDecoration.none : TextDecoration.lineThrough;
    final IconData firstIcon = isTodoTask ? Icons.done : Icons.keyboard_return;
    final IconData secondIcon = isTodoTask ? Icons.more_vert : Icons.delete;

    //
    return TodoItemTransition(
      key: _transitionKey,
      onComplete: () => dataContext.completeToggle(
          item: widget.todoItem,
          index: widget.index,
          context: ScaffoldMessenger.maybeOf(context)!),
      onDelete: () => dataContext.removeItem(
          datalist: isTodoTask ? DatabaseName.todo : DatabaseName.done,
          index: widget.index,
          context: ScaffoldMessenger.maybeOf(context)!),
      child: Opacity(
        opacity: isOpcacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
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
              isLabelVisible: widget.todoItem.isHighlight,
              offset: const Offset(0, -5),
              backgroundColor: shadowColor,
              label:
                  widget.todoItem.isHighlight ? const Icon(Icons.star) : null,
              child: GestureDetector(
                onDoubleTap: () {
                  if (isTodoTask) {
                    dataContext.setAsSpecial(
                        index: widget.index, context: context);
                  }
                },
                child: ListTile(
                  title: Text(
                    widget.todoItem.title,
                    style: TextStyle(
                        decoration: textStyle,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge?.fontSize),
                  ),
                  subtitle: Text(
                    'Last Updated ${DateFormat('yyyy-MM-dd').format(widget.todoItem.dateTime.toLocal())}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize:
                          Theme.of(context).textTheme.bodyMedium?.fontSize,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(left: 10),
                  trailing: Wrap(
                    children: [
                      CustomButton(
                          callback: () {
                            SlideDirection slideDirection = isTodoTask
                                ? SlideDirection.right
                                : SlideDirection.left;
                            _transitionKey.currentState?.startCompleteAnimation(
                                direction: slideDirection);
                          },
                          iconData: firstIcon),
                      CustomButton(
                          callback: () {
                            if (isTodoTask) {
                              _showPopupMenu(
                                  widget.index, widget.todoItem.title);
                            } else {
                              _transitionKey.currentState
                                  ?.startDeleteAnimation();
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
    );
  }
}
