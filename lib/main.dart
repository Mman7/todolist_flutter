import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:simple_todo/abstract/widget/delete_all_button.dart';
import 'package:simple_todo/abstract/widget/done_task_list.dart';

import 'abstract/theme/theme.dart';
import 'abstract/widget/custom_floating_button.dart';
import 'abstract/widget/custom_pop_up_inside_layout.dart';
import 'abstract/widget/custom_button.dart';
import 'abstract/widget/todo_item.dart';

import 'package:provider/provider.dart';
import 'abstract/providers/data_provider.dart';
//build command: flutter build apk --split-per-abi --no-shrink --no-sound-null-safety

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<DataProvider>(create: (_) => DataProvider())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TodoList(),
      title: 'Simple Todo',
      darkTheme: darkTheme(context),
      themeMode: ThemeMode.dark,
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({
    Key? key,
  }) : super(key: key);
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final PageController _controller = PageController();
  String? _inputText;
  int _selectedIndex = 0;
  late TextEditingController _textFieldController;
  late DataProvider dataContext;

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    dataContext = context.read<DataProvider>();
    dataContext.intializeData();
    //intialize theme
  }

  changePage(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.jumpToPage(index);
    });
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
    setState(() {});
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
                        foregroundColor: Theme.of(context).primaryColor),
                    onPressed: () =>
                        Navigator.of(context).pop(_textFieldController.text),
                    child: Text(
                      _buttonText,
                    ))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    var _todoTask = context.watch<DataProvider>().todoTasks;
    var _doneTask = context.watch<DataProvider>().doneTasks;

    return Scaffold(
      appBar: AppBar(
        actions: [
          deleteAllButton(
              selectedIndex: _selectedIndex,
              context: context,
              doneTask: _doneTask,
              callback: () {
                dataContext.cleanDoneTask(context: context);

                setState(() {
                  _doneTask = [];
                });

                dataContext.showSnackBar(
                    context: context, message: 'Successfully Clean Done Task');
                // close pop menu
              }),
        ],
        centerTitle: true,
        title: const Text(
          'Todo List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted), label: 'Todo'),
          BottomNavigationBarItem(icon: Icon(Icons.done_all), label: 'Done')
        ],
        currentIndex: _selectedIndex,
        onTap: changePage,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _selectedIndex == 0
          ? customFloatingButton(
              context: context,
              onPress: () async {
                _textFieldController.text = '';
                String? value = await openDialog('Todo Task', 'Add');
                if (value == null) return;
                setState(() {
                  _inputText = value;
                });
                dataContext.addTask(context: context, value: _inputText);
              })
          : Container(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: PageView(
        onPageChanged: (index) => setState(() {
          _selectedIndex = index;
        }),
        controller: _controller,
        children: [
          ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) async => dataContext.reOrderItem(
                  oldIndex: oldIndex, newIndex: newIndex),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: _todoTask.length,
              itemBuilder: (context, index) {
                return TodoItem(
                  key: ValueKey(index),
                  opacity: 1.0,
                  isHighlight: _todoTask[index][0],
                  child: XGestureDetector(
                    onDoubleTap: (e) => dataContext.setAsSpecial(
                        index: index, context: context),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        _todoTask[index][1],
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.fontSize),
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CustomButton(
                            callback: () => dataContext.completeTask(
                              context: context,
                              completedIndex: index,
                            ),
                            iconData: Icons.done,
                          ),
                          PopupMenuButton(
                              shadowColor: Colors.transparent,
                              splashRadius: 20,
                              color: HexColor('#040934').withAlpha(185),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(

                                        /// Solution of this
                                        /// https://stackoverflow.com/questions/69939559/showdialog-bug-dialog-isnt-triggered-from-popupmenubutton-in-flutter
                                        onTap: () {
                                          Future.delayed(
                                              const Duration(seconds: 0),
                                              () => editTask(index));
                                        },
                                        child: const CustomPopUpInside(
                                          text: 'Edit',
                                          iconData: Icons.edit,
                                        )),
                                    PopupMenuItem(
                                        onTap: () {
                                          dataContext.deleteTask(
                                            databasename: 'todo',
                                            list: _todoTask,
                                            removeIndex: index,
                                            context: context,
                                          );
                                          setState(() {});
                                        },
                                        child: const CustomPopUpInside(
                                            text: 'Delete',
                                            iconData: Icons.delete))
                                  ])
                        ],
                      ),
                    ),
                  ),
                );
              }),
          const DoneTaskList(),
        ],
      ),
    );
  }
}
