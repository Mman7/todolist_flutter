import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'abstract/custom_pop_up_inside_layout.dart';
import 'abstract/custom_button.dart';
import 'abstract/todo_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TodoList(),
      title: 'Simple Todo',
      theme: ThemeData(
          canvasColor: HexColor('#ffffff').withOpacity(0.35),
          popupMenuTheme: const PopupMenuThemeData(
              color: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)))),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: HexColor('#224064')),
          textTheme: const TextTheme(
              bodyText2: TextStyle(color: Colors.white),
              bodyText1: TextStyle(color: Colors.white, fontSize: 20))),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> with TickerProviderStateMixin {
  final Color _baseTextColor = Colors.white;
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
    List<String> tododata = await getBackData('todo');
    List<String> donedata = await getBackData('done');
    setState(() => {_todoTask = tododata, _doneTask = donedata});
  }

  saveData(String dataBaseName, List<String> dataItemList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(dataBaseName, dataItemList);
  }

  Future<List<String>> getBackData(String _dataBaseName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getStringList(_dataBaseName);
    return data ?? [];
  }

  addTask() async {
    if (_inputText == null) return;
    setState(() {
      _todoTask.add(_inputText.toString());
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todo', _todoTask);
    showSnackBar('Successfully Added');
  }

  completeTask(int index) async {
    List<String> _todoData = await getBackData('todo');
    List<String> _doneData = await getBackData('done');

    _doneData.insert(0, _todoData[index]);
    _todoData.removeAt(index);

    setState(() {
      _doneTask = _doneData;
      _todoTask = _todoData;
    });

    saveData('todo', _todoData);
    saveData('done', _doneData);
    showSnackBar('Successfully Completed');
  }

  deleteTask(int index, String databasename) async {
    List<String> data = await getBackData(databasename);
    data.removeAt(index);
    setState(() {
      if (databasename == 'todo') _todoTask = data;
      if (databasename == 'done') _doneTask = data;
    });
    saveData(databasename, data);
    showSnackBar('Successfully Deleted');
  }

  returnTask(int index) async {
    List<String> _todoData = await getBackData('todo');
    List<String> _doneData = await getBackData('done');

    _todoData.add(_doneData[index]);
    _doneData.removeAt(index);

    setState(() {
      _doneTask = _doneData;
      _todoTask = _todoData;
    });

    saveData('todo', _todoData);
    saveData('done', _doneData);
    showSnackBar('Successfully Returned');
  }

  changePage(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.jumpToPage(index);
    });
  }

  editTask(int index) async {
    final editvalue = _todoTask[index];
    _textFieldController.text = editvalue;
    final text = await openDialog('Edit Task', 'Edit');
    if (text == null) return;
    setState(() {
      _todoTask[index] = text;
    });
    saveData('todo', _todoTask);
    _textFieldController.text = '';
    showSnackBar('Successfully Edited');
  }

  openDialog(String _title, String _buttonText) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                _title,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              backgroundColor: HexColor('#224064'),
              content: TextField(
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                controller: _textFieldController,
              ),
              actions: [
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(HexColor('#008282'))),
                    onPressed: () =>
                        Navigator.of(context).pop(_textFieldController.text),
                    child: Text(
                      _buttonText,
                      style: const TextStyle(color: Colors.white),
                    ))
              ],
            ));
  }

  cleanDoneTask() {
    List<String> cleanDone = [];
    saveData('done', cleanDone);
    setState(() {
      _doneTask = cleanDone;
    });
  }

  Widget onDonePage() {
    if (_selectedIndex != 1) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.5, vertical: 0),
      child: IconButton(
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    backgroundColor: HexColor('#224064'),
                    title: Text(
                      'Are you sure delete forever?',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    actions: [
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  HexColor('#008282'))),
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
                            cleanDoneTask();
                            showSnackBar('Successfully Clean Done Task');
                            Navigator.of(context).pop();
                          },
                          child: const Text('Sure',
                              style: TextStyle(color: Colors.white)))
                    ],
                  )),
          icon: const Icon(
            Icons.delete_forever,
            size: 40,
          )),
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
        addTask();
        _textFieldController.text = '';
      },
      backgroundColor: HexColor('#008282'),
      foregroundColor: Colors.white,
      child: const Icon(
        Icons.add,
      ),
    );
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: HexColor('#008282'),
        duration: const Duration(milliseconds: 1000),
        content: Text(message)));
  }

  reOrderItem(oldindex, newIndex) {
    // print(_todoTask);
    final String changeItem = _todoTask[oldindex];
    setState(() {
      _todoTask.removeAt(oldindex);
      _todoTask.insert(newIndex, changeItem);
    });
    saveData('todo', _todoTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          onDonePage(),
        ],
        centerTitle: true,
        title: const Text('Todo List'),
        backgroundColor: HexColor('#224064'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.white30,
        selectedItemColor: HexColor('#008282'),
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
      backgroundColor: HexColor("#112139"),
      body: PageView(
        onPageChanged: (index) => setState(() {
          _selectedIndex = index;
        }),
        controller: _controller,
        children: [
          ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) {
                reOrderItem(oldIndex, newIndex);
              },
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
                      style: TextStyle(color: _baseTextColor, fontSize: 20),
                    ),
                    trailing: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CustomButton(
                          callback: () => completeTask(index),
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
                                      onTap: () => deleteTask(index, 'todo'),
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
                  opacity: 0.65,
                  child: ListTile(
                      dense: true,
                      title: Text(
                        _doneTask[index],
                        style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: _baseTextColor,
                            fontSize: 20),
                      ),
                      trailing: Wrap(children: [
                        CustomButton(
                          callback: () => returnTask(index),
                          iconData: Icons.subdirectory_arrow_left,
                        ),
                        CustomButton(
                          // callback: () => deleteTask(index, 'done'),
                          callback: () => deleteTask(index, 'done'),
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
