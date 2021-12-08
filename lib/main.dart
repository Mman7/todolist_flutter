import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'abstract/button.dart';
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

class _TodoListState extends State<TodoList> {
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
  }

  completeTask(int index) async {
    List<String> _todoData = await getBackData('todo');
    List<String> _doneData = await getBackData('done');

    _doneData.add(_todoData[index]);
    _todoData.removeAt(index);

    setState(() {
      _doneTask = _doneData;
      _todoTask = _todoData;
    });

    saveData('todo', _todoData);
    saveData('done', _doneData);
  }

  deleteTask(int index, String databasename) async {
    List<String> data = await getBackData(databasename);
    data.removeAt(index);
    setState(() {
      if (databasename == 'todo') _todoTask = data;
      if (databasename == 'done') _doneTask = data;
    });
    saveData(databasename, data);
  }

  void changePage(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.jumpToPage(index);
    });
  }

  Future openDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
              'Todo task',
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
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ));

  Widget onDonePage() {
    if (_selectedIndex != 1) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.5, vertical: 0),
      child: IconButton(
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    backgroundColor: Colors.red[900],
                    title: Text(
                      'Delete Forever',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            List<String> cleanDone = [];
                            saveData('done', cleanDone);
                            setState(() {
                              _doneTask = cleanDone;
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Sure',
                              style: TextStyle(color: Colors.white))),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Nah',
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
        String? value = await openDialog();
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
          ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: _todoTask.length,
              itemBuilder: (context, index) {
                return TodoItem(
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
                            iconData: Icons.done),
                        CustomButton(
                            callback: () => deleteTask(index, 'todo'),
                            iconData: Icons.delete_outline),
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
                      trailing: CustomButton(
                        callback: () => deleteTask(index, 'done'),
                        iconData: Icons.delete_outline,
                      )),
                );
              }),
        ],
      ),
    );
  }
}
