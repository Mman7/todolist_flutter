import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_todo/model/localdatabase.dart';
import 'package:simple_todo/model/todo_data.dart';

class DataProvider with ChangeNotifier {
  List<TodoItem> _todoTasks = [];
  List<TodoItem> _doneTasks = [];
  Offset? buttonPos;
  updatePos(Offset offset) => buttonPos = offset;

  SharedPreferences? prefs;
  List<TodoItem> get todoTasks => _todoTasks;
  List<TodoItem> get doneTasks => _doneTasks;
  List<List<TodoItem>> _historyData = [];

  _updateHistory() {
    _historyData = [_cloneTaskList(_todoTasks), _cloneTaskList(_doneTasks)];
  }

  // Keep in-memory task rows normalized as TodoData objects.
  List<TodoItem> _normalizeTaskList(List<TodoItem> tasks) {
    return tasks
        .map((item) => TodoItem(
              isHighlight: item.isHighlight,
              title: item.title.toString(),
              dateTime: item.dateTime,
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
    _todoTasks.add(TodoItem(
        isHighlight: false, title: value.toString(), dateTime: DateTime.now()));
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
    showSnackBarFromMessenger(
        messenger: ScaffoldMessenger.maybeOf(context),
        message: 'Successfully Added');

    notifyListeners();
  }

  Future<void> updateTask(
      {required BuildContext context,
      required int index,
      required String value}) async {
    // Update history before making changes for undo functionality.
    _updateHistory();
    // Update the title of the task at the specified index
    _todoTasks[index].title = value;
    // Update the dateTime to reflect the modification time
    DateTime now = DateTime.now();
    _todoTasks[index].dateTime = now;
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
    showSnackBarFromMessenger(
        messenger: ScaffoldMessenger.maybeOf(context),
        message: 'Successfully Updated');
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
    required TodoItem item,
    required int index,
    required ScaffoldMessengerState context,
  }) async {
    // Update history before making changes for undo functionality.
    _updateHistory();

    if (!item.isCompleted) {
      // update item to completed
      item.isCompleted = true;
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
      // update item to not completed
      item.isCompleted = false;
      _swapItem(todoList: _doneTasks, doneList: _todoTasks, index: index);
      notifyListeners();
      showSnackBarFromMessenger(
          messenger: context, message: 'Successfully undo completed task');
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
    final List<TodoItem> targetList =
        datalist == DatabaseName.todo ? _todoTasks : _doneTasks;
    final TodoItem removedItem = targetList.removeAt(index);
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
    TodoItem temp = _todoTasks.removeAt(oldIndex);
    _todoTasks.insert(newIndex, temp);
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
  }

  // Helper to create a deep copy of a task list for history snapshots.
  List<TodoItem> _cloneTaskList(List<TodoItem> tasks) => tasks
      .map((item) => TodoItem(
            isHighlight: item.isHighlight,
            title: item.title,
            dateTime: item.dateTime,
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
