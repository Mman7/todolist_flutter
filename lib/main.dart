import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:simple_todo/abstract/widget/delete_all_button.dart';
import 'package:simple_todo/abstract/widget/done_task_list.dart';
import 'abstract/theme/theme.dart';
import 'abstract/widget/custom_floating_button.dart';
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
  late TextEditingController _textFieldController;
  late DataProvider dataContext;
  String? _inputText;
  int _selectedIndex = 0;
  final ScrollController scrollController = ScrollController();
  Offset completeButtonPos = const Offset(0, 0);
  Offset optionsButtonPos = const Offset(0, 0);

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
  }

  changePage(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.jumpToPage(index);
    });
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

  void _scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    var _todoTask = context.watch<DataProvider>().todoTasks;
    var _doneTask = context.watch<DataProvider>().doneTasks;
    String appBarHeaderText = _selectedIndex == 0 ? "Todo List" : "Done List";

    return Scaffold(
      appBar: AppBar(
        actions: [
          deleteAllButton(
              selectedIndex: _selectedIndex,
              context: context,
              doneTask: _doneTask,
              callback: () {
                dataContext.cleanDoneTask(context: context);
                dataContext.showSnackBar(
                    context: context, message: 'Successfully Clean Done Task');
              }),
        ],
        centerTitle: true,
        title: Text(
          appBarHeaderText,
          style: const TextStyle(color: Colors.white),
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
                _scrollDown();
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
              scrollController: scrollController,
              onReorder: (oldIndex, newIndex) async => dataContext.reOrderItem(
                  oldIndex: oldIndex, newIndex: newIndex),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              itemCount: _todoTask.length,
              itemBuilder: (context, index) {
                return TodoItem(
                    isTodoTask: true,
                    key: ValueKey(index),
                    index: index,
                    opacity: 1.0,
                    isHighlight: _todoTask[index][0],
                    title: _todoTask[index][1]);
              }),
          const DoneTaskList(),
        ],
      ),
    );
  }
}
