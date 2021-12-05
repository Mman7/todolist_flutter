import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      theme: ThemeData(textTheme: const TextTheme()),
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
  String? _inputText;
  late TextEditingController _textFieldController;
  List<String> _todoTask = [];

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    intialTodo();
  }

  Future<List<String>> _getBackData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getStringList('todo');
    return data ?? [];
  }

  intialTodo() async {
    var data = await _getBackData();
    setState(() => _todoTask = data);
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future openDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text(
              'Todo task',
              style: TextStyle(color: Colors.white, fontSize: 22.5),
            ),
            backgroundColor: HexColor('#224064'),
            content: TextField(
              style: TextStyle(color: Colors.white),
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

  addTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_inputText == null) return;
    setState(() {
      _todoTask.add(_inputText.toString());
    });
    prefs.setStringList('todo', _todoTask);
  }

  deleteTask(index) async {
    var data = await _getBackData();
    data.removeAt(index);
    setState(() {
      _todoTask = data;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todo', data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Todo List'),
        backgroundColor: HexColor('#224064'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? value = await openDialog();
          if (value == null) return;
          setState(() {
            _inputText = value;
          });
          addTask();
          _textFieldController.text = '';
        },
        backgroundColor: HexColor('#096380'),
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add,
        ),
      ),
      backgroundColor: HexColor("#112139"),
      body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          itemCount: _todoTask.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(7.5),
                    color: HexColor('#096380')),
                child: ListTile(
                  dense: true,
                  title: Text(
                    _todoTask[index],
                    style: TextStyle(color: _baseTextColor, fontSize: 20),
                  ),
                  trailing: IconButton(
                    onPressed: () => deleteTask(index),
                    icon: const Icon(
                      Icons.delete_outline_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
