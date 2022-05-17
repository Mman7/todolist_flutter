import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'abstract/theme/theme.dart';
import 'abstract/widget/custom_pop_up_inside_layout.dart';
import 'abstract/widget/custom_button.dart';
import 'abstract/widget/todo_item.dart';
import 'abstract/todo_controller.dart';
import 'package:provider/provider.dart';
import 'abstract/providers/theme_provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TodoList(),
      title: 'Simple Todo',
      themeMode: context.watch<ThemeProvider>().themeMode,
      darkTheme: dark_theme(context),
      theme: lightTheme(context),
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
  List _doneTask = [];
  List _todoTask = [];
  String? _inputText;
  int _selectedIndex = 0;
  late TextEditingController _textFieldController;

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    intialTodo();
    intialTheme();
  }

  intialTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int intialTheme = prefs.getInt('theme') ?? 0;
    if (intialTheme == 0) return;
    if (intialTheme == 1) {
      context.read<ThemeProvider>().changeTheme(ThemeMode.light);
    }
    if (intialTheme == 2) {
      context.read<ThemeProvider>().changeTheme(ThemeMode.dark);
    }
  }

  intialTodo() async {
    List tododata = await TodoController().getData(dataBaseName: 'todo');
    List donedata = await TodoController().getData(dataBaseName: 'done');
    setState(() => {_todoTask = tododata, _doneTask = donedata});
  }

  changePage(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.jumpToPage(index);
    });
  }

  editTask(int index) async {
    _textFieldController.text = _todoTask[index][1];
    final text = await openDialog('Edit Task', 'Edit');
    if (text == null) return;
    setState(() {
      _todoTask[index][1] = text;
    });
    _textFieldController.text = '';
    TodoController().saveData('todo', _todoTask);
    TodoController()
        .showSnackBar(context: context, message: 'Successfully Edited');
    setState(() {});
  }

  openDialog(String _title, String _buttonText) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                _title,
                style: TextStyle(
                    fontWeight:
                        Theme.of(context).textTheme.bodyLarge?.fontWeight,
                    fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize),
              ),
              content: TextField(
                autofocus: true,
                style: TextStyle(
                    color: context.read<ThemeProvider>().themeMode ==
                            ThemeMode.dark
                        ? Colors.white
                        : Colors.black),
                controller: _textFieldController,
              ),
              actions: [
                TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_textFieldController.text),
                    child: Text(
                      _buttonText,
                    ))
              ],
            ));
  }

  Widget onDonePage() {
    if (_selectedIndex != 1) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.5, vertical: 0),
      child: IconButton(
        icon: Icon(Icons.delete_forever,
            size: 40, color: Theme.of(context).secondaryHeaderColor),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text(
                    'Are you sure delete forever?',
                    style: TextStyle(
                        color: context.read<ThemeProvider>().themeMode ==
                                ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                        fontWeight:
                            Theme.of(context).textTheme.bodyLarge?.fontWeight,
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge?.fontSize),
                  ),
                  actions: [
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No',
                            style: TextStyle(color: Colors.white))),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.redAccent)),
                        onPressed: () {
                          TodoController()
                              .cleanDoneTask(
                                  doneList: _doneTask, context: context)
                              .then((newList) =>
                                  setState(() => _doneTask = newList));
                          TodoController().showSnackBar(
                              context: context,
                              message: 'Successfully Clean Done Task');
                          Navigator.of(context).pop();
                        },
                        child: const Text('Sure',
                            style: TextStyle(color: Colors.white)))
                  ],
                )),
      ),
    );
  }

  saveTheme(ThemeMode currentTheme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (currentTheme == ThemeMode.light) {
      prefs.setInt('theme', 1);
    } else {
      // if currentTheme is dark
      prefs.setInt('theme', 2);
    }
  }

  Widget onTodoPage() {
    if (_selectedIndex != 0) return Container();
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: HexColor('#0085FF').withOpacity(0.65),
                spreadRadius: 0.25,
                blurRadius: 20,
                offset: const Offset(0, 0))
          ],
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(50)),
      child: FloatingActionButton(
        onPressed: () async {
          _textFieldController.text = '';
          String? value = await openDialog('Todo Task', 'Add');
          if (value == null) return;
          setState(() {
            _inputText = value;
          });
          TodoController()
              .addTask(context: context, todoList: _todoTask, value: _inputText)
              .then((newTodoList) => setState(() => _todoTask = newTodoList));
          _textFieldController.text = '';
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeMode currentTheme = context.read<ThemeProvider>().themeMode;

    final Icon themeIcon = currentTheme == ThemeMode.light
        ? const Icon(Icons.dark_mode)
        : const Icon(Icons.light_mode);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (currentTheme == ThemeMode.light) {
              context.read<ThemeProvider>().changeTheme(ThemeMode.dark);
              saveTheme(ThemeMode.dark);
            } else {
              context.read<ThemeProvider>().changeTheme(ThemeMode.light);
              saveTheme(ThemeMode.light);
            }
          },
          icon: themeIcon,
        ),
        actions: [
          onDonePage(),
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
      floatingActionButton: onTodoPage(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: PageView(
        onPageChanged: (index) => setState(() {
          _selectedIndex = index;
        }),
        controller: _controller,
        children: [
          ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) async => TodoController()
                  .reOrderItem(
                      todoList: _todoTask,
                      oldIndex: oldIndex,
                      newIndex: newIndex),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: _todoTask.length,
              itemBuilder: (context, index) {
                return TodoItem(
                  key: ValueKey(index),
                  opacity: 1.0,
                  isSpecial: _todoTask[index][0],
                  child: ListTile(
                    dense: true,
                    title: Text(
                      _todoTask[index][1],
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1?.color,
                          fontSize:
                              Theme.of(context).textTheme.bodyText1?.fontSize),
                    ),
                    trailing: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CustomButton(
                          callback: () async => {
                            TodoController()
                                .completeTask(
                                  context: context,
                                  completedIndex: index,
                                  doneList: _doneTask,
                                  todoList: _todoTask,
                                )
                                .then((value) =>
                                    setState(() => _todoTask = value))
                          },
                          iconData: Icons.done,
                        ),
                        PopupMenuButton(
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
                                      child: CustomPopUpInside(
                                        text: 'Edit',
                                        iconData: Icons.edit,
                                      )),
                                  PopupMenuItem(
                                      onTap: () {
                                        TodoController().setAsSpecial(
                                            index: index, context: context);
                                        setState(() {
                                          _todoTask[index][0] =
                                              _todoTask[index][0] == 'false'
                                                  ? 'true'
                                                  : 'false';
                                        });
                                      },
                                      child: CustomPopUpInside(
                                          text: 'Set as special',
                                          iconData: Icons.star)),
                                  PopupMenuItem(
                                      onTap: () {
                                        TodoController().deleteTask(
                                          databasename: 'todo',
                                          list: _todoTask,
                                          removeIndex: index,
                                          context: context,
                                        );
                                        setState(() {});
                                      },
                                      child: CustomPopUpInside(
                                          text: 'Delete',
                                          iconData: Icons.delete))
                                ])
                      ],
                    ),
                  ),
                );
              }),
          ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: _doneTask.length,
              itemBuilder: (context, index) {
                return TodoItem(
                  isSpecial: _doneTask[index][0],
                  opacity: 0.5,
                  child: ListTile(
                      dense: true,
                      title: Text(
                        _doneTask[index][1],
                        style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Theme.of(context).textTheme.bodyText1?.color,
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.fontSize),
                      ),
                      trailing: Wrap(children: [
                        CustomButton(
                          callback: () async => await TodoController()
                              .returnTask(
                                context: context,
                                todoList: _todoTask,
                                doneList: _doneTask,
                                returnItemIndex: index,
                              )
                              .then(
                                  (value) => setState(() => _doneTask = value)),
                          iconData: Icons.subdirectory_arrow_left,
                        ),
                        CustomButton(
                          callback: () => {
                            TodoController().deleteTask(
                                list: _doneTask,
                                removeIndex: index,
                                databasename: 'done',
                                context: context),
                            setState(() {})
                          },
                          iconData: Icons.delete_outline,
                        ),
                      ])),
                );
              }),
        ],
      ),
    );
  }
}
