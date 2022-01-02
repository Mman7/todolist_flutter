import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'abstract/widget/custom_pop_up_inside_layout.dart';
import 'abstract/widget/custom_button.dart';
import 'abstract/widget/todo_item.dart';
import 'abstract/todo_controller.dart';

//TODo Theme problem
// ? how to change thememode via something
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoList(),
      title: 'Simple Todo',
      darkTheme: ThemeData(
          dialogTheme: DialogTheme(
              contentTextStyle: TextStyle(color: Colors.white),
              backgroundColor: Colors.black.withAlpha(1000),
              titleTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.secondary)),
          popupMenuTheme: PopupMenuThemeData(
            color: Colors.black.withAlpha(1000),
          ),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black38),
          textTheme: const TextTheme(
            bodyText1: TextStyle(color: Colors.white, fontSize: 20),
          ),
          primaryColor: Colors.blue,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.black38,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey.withOpacity(0.5)),
          backgroundColor: Colors.white.withOpacity(0.1)),
      theme: ThemeData(
          textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      Theme.of(context).bottomAppBarColor),
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).primaryColor))),
          primaryColor: HexColor('#39A0FF'),
          backgroundColor: HexColor('#E5EEF5'),
          canvasColor: HexColor('#ffffff').withOpacity(0.35),
          dialogTheme: DialogTheme(
              backgroundColor: Theme.of(context).bottomAppBarColor,
              titleTextStyle: TextStyle(color: Theme.of(context).primaryColor)),
          popupMenuTheme: PopupMenuThemeData(
              color: Theme.of(context).bottomAppBarColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)))),
          appBarTheme: AppBarTheme(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor),
          bottomNavigationBarTheme:
              const BottomNavigationBarThemeData(backgroundColor: Colors.white),
          textTheme: const TextTheme(
            bodyText1: TextStyle(color: Colors.white, fontSize: 20),
          )),
    );
  }
}

class TodoList extends StatefulWidget {
  TodoList({
    Key? key,
  }) : super(key: key);
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final PageController _controller = PageController();
  List<String> _doneTask = [];
  String? _inputText;
  int _selectedIndex = 0;
  late TextEditingController _textFieldController;
  List<String> _todoTask = [];

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
  }

  intialTodo() async {
    List<String> tododata =
        await TodoController().getData(dataBaseName: 'todo');
    List<String> donedata =
        await TodoController().getData(dataBaseName: 'done');
    setState(() => {_todoTask = tododata, _doneTask = donedata});
  }

  changePage(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.jumpToPage(index);
    });
  }

  editTask(int index) async {
    _textFieldController.text = _todoTask[index];
    final text = await openDialog('Edit Task', 'Edit');
    if (text == null) return;
    setState(() {
      _todoTask[index] = text;
    });
    _textFieldController.text = '';
    TodoController().saveData('todo', _todoTask);
    TodoController()
        .showSnackBar(context: context, message: 'Successfully Edited');
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
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
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
                  backgroundColor: Theme.of(context).bottomAppBarColor,
                  title: Text(
                    'Are you sure delete forever?',
                    style: TextStyle(
                        color: Colors.black,
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

  Widget onTodoPage() {
    if (_selectedIndex != 0) return Container();
    return FloatingActionButton(
      onPressed: () async {
        _textFieldController.text = '';
        String? value = await openDialog('Todo Task', 'Add');
        if (value == null) return;
        setState(() {
          _inputText = value;
        });
        TodoController()
            .addTask(todoList: _todoTask, value: _inputText)
            .then((newTodoList) => setState(() => _todoTask = newTodoList));
        _textFieldController.text = '';
      },
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Theme.of(context).bottomAppBarColor,
      child: const Icon(
        Icons.add,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Icon themeIcon =
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? Icon(Icons.light_mode)
            : Icon(Icons.dark_mode);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: themeIcon,
        ),
        actions: [
          onDonePage(),
        ],
        centerTitle: true,
        title: Text(
          'Todo List',
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
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
              onReorder: (oldIndex, newIndex) async => await TodoController()
                  .reOrderItem(
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                      todoList: _todoTask)
                  .then((newList) => setState(() => _todoTask = newList)),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: _todoTask.length,
              itemBuilder: (context, index) {
                return TodoItem(
                  key: ValueKey(index),
                  opacity: 1.0,
                  child: ListTile(
                    dense: true,
                    title: Text(
                      _todoTask[index],
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
                                      textStyle: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
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
                  opacity: 0.5,
                  child: ListTile(
                      dense: true,
                      title: Text(
                        _doneTask[index],
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
                          callback: () => TodoController().deleteTask(
                              list: _doneTask,
                              removeIndex: index,
                              databasename: 'done',
                              context: context),
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
