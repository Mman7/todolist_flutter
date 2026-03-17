import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_todo/abstract/localdatabase.dart';
import 'package:simple_todo/model/todo_data.dart';

class DataProvider with ChangeNotifier {
  List<TodoData> _todoTasks = [];
  List<TodoData> _doneTasks = [];
  Offset? buttonPos;
  updatePos(Offset offset) => buttonPos = offset;

  SharedPreferences? prefs;
  List<TodoData> get todoTasks => _todoTasks;
  List<TodoData> get doneTasks => _doneTasks;
  List<List<TodoData>> _historyData = [];

  _updateHistory() {
    _historyData = [_cloneTaskList(_todoTasks), _cloneTaskList(_doneTasks)];
  }

  // Keep in-memory task rows normalized as TodoData objects.
  List<TodoData> _normalizeTaskList(List<TodoData> tasks) {
    return tasks
        .map((item) => TodoData(
              isHighlight: item.isHighlight,
              title: item.title.toString(),
            ))
        .toList();
  }

  Future<void> intializeData() async {
    prefs = await SharedPreferences.getInstance();
    final loadedTodo = await Database.getData(dataBaseName: DatabaseName.todo);
    final loadedDone = await Database.getData(dataBaseName: DatabaseName.done);

    _todoTasks = _normalizeTaskList(loadedTodo);
    _doneTasks = _normalizeTaskList(loadedDone);

    // Persist normalized values to migrate older string-based data.
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
    await Database.saveData(
        databaseName: DatabaseName.done, newList: _doneTasks);
    notifyListeners();
  }

  Future<void> addTask({required BuildContext context, required value}) async {
    _updateHistory();
    _todoTasks.add(TodoData(isHighlight: false, title: value.toString()));
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
    showSnackBarFromMessenger(
        messenger: ScaffoldMessenger.maybeOf(context),
        message: 'Successfully Added');

    notifyListeners();
  }

  Future<void> setAsSpecial(
      {required int index, required BuildContext context}) async {
    _updateHistory();

    final bool value = _todoTasks[index].isHighlight;
    _todoTasks[index].isHighlight = !value;

    showSnackBarFromMessenger(
        messenger: ScaffoldMessenger.maybeOf(context),
        message: 'Successfully Highlighted');
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);

    notifyListeners();
  }

  void showSnackBarFromMessenger({
    required ScaffoldMessengerState? messenger,
    required String message,
  }) {
    if (messenger == null) return;
    // Clear any existing snack bars before showing a new one.
    messenger.hideCurrentSnackBar();
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(SnackBar(
        backgroundColor: Theme.of(messenger.context).primaryColor,
        duration: const Duration(milliseconds: 1500),
        persist: false,
        action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () => restorePrevState()),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        )));
  }

  static void _swapItem(
      {required List todoList, required List doneList, required int index}) {
    // Copy the item from the source list
    final item = todoList[index];
    // remove it from the first list and add it to the second list
    todoList.removeAt(index);
    doneList.add(item);
  }

  Future<void> completeToggle({
    required DatabaseName datalist,
    required int index,
    required ScaffoldMessengerState context,
  }) async {
    // Update history before making changes for undo functionality.
    _updateHistory();

    if (datalist == DatabaseName.todo) {
      _swapItem(todoList: _todoTasks, doneList: _doneTasks, index: index);
      notifyListeners();
      showSnackBarFromMessenger(
          messenger: context, message: 'Successfully completed task');
      try {
        await Database.saveAll(_todoTasks, _doneTasks);
      } catch (_) {
        // Restore from storage if persistence fails.
        await intializeData();
      }
    } else {
      _swapItem(todoList: _doneTasks, doneList: _todoTasks, index: index);
      notifyListeners();
      showSnackBarFromMessenger(
          messenger: context, message: 'Successfully undo donetask');
      try {
        await Database.saveAll(_todoTasks, _doneTasks);
      } catch (_) {
        // Restore from storage if persistence fails.
        await intializeData();
      }
    }
  }

  Future<void> removeItem(
      {required DatabaseName datalist,
      required int index,
      required ScaffoldMessengerState context}) async {
    _updateHistory();
    final List<TodoData> targetList =
        datalist == DatabaseName.todo ? _todoTasks : _doneTasks;
    final TodoData removedItem = targetList.removeAt(index);
    notifyListeners();
    try {
      await Database.removeData(databaseName: datalist, index: index);
      showSnackBarFromMessenger(
          messenger: context, message: 'Successfully Deleted');
    } catch (_) {
      targetList.insert(index, removedItem);
      notifyListeners();
      await intializeData();
    }
  }

  void cleanDoneTask() {
    _updateHistory();
    _doneTasks = [];
    Database.cleanDoneTask();
    notifyListeners();
  }

  Future<void> reOrderItem(
      {required int oldIndex, required int newIndex}) async {
    // if the newIndex is larger than oldIndex newIndex will decrease 1
    // because reorder widget newIndex is larger than the expected value
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    TodoData temp = _todoTasks.removeAt(oldIndex);
    _todoTasks.insert(newIndex, temp);
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
  }

  // Helper to create a deep copy of a task list for history snapshots.
  List<TodoData> _cloneTaskList(List<TodoData> tasks) => tasks
      .map((item) => TodoData(
            isHighlight: item.isHighlight,
            title: item.title,
          ))
      .toList();

  // Store a snapshot of the current state for undo functionality.

  //  Restore the most recent snapshot from history, if available.
  Future<void> restorePrevState() async {
    if (_historyData.isEmpty) return;

    _todoTasks = _cloneTaskList(_historyData[0]);
    _doneTasks = _cloneTaskList(_historyData[1]);
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
    await Database.saveData(
        databaseName: DatabaseName.done, newList: _doneTasks);
    notifyListeners();
  }

  updateValue() {
    notifyListeners();
  }
}
