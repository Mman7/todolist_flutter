import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_todo/abstract/localdatabase.dart';
import 'package:simple_todo/model/todo_data.dart';

class DataProvider with ChangeNotifier {
  List<TodoData> _todoTasks = [];
  List<TodoData> _doneTasks = [];
  Offset? buttonPos;
  SharedPreferences? prefs;
  List<TodoData> get todoTasks => _todoTasks;
  List<TodoData> get doneTasks => _doneTasks;

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

  updatePos(Offset offset) => buttonPos = offset;

  Future<void> addTask({required BuildContext context, required value}) async {
    _todoTasks.add(TodoData(isHighlight: false, title: value.toString()));
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
    showSnackBarFromMessenger(
        messenger: ScaffoldMessenger.maybeOf(context),
        backgroundColor: Theme.of(context).primaryColor,
        message: 'Successfully Added');
    notifyListeners();
  }

  Future<void> setAsSpecial(
      {required int? index, required BuildContext context}) async {
    if (index == null) return;
    final bool value = _todoTasks[index].isHighlight;
    _todoTasks[index].isHighlight = !value;

    showSnackBarFromMessenger(
        messenger: ScaffoldMessenger.maybeOf(context),
        backgroundColor: Theme.of(context).primaryColor,
        message: 'Successfully Highlighted');
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
    notifyListeners();
  }

  void showSnackBarFromMessenger({
    required ScaffoldMessengerState? messenger,
    required Color backgroundColor,
    required String message,
  }) {
    if (messenger == null) return;
    messenger.showSnackBar(SnackBar(
      backgroundColor: backgroundColor,
      duration: const Duration(milliseconds: 800),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ));
  }

  Future<void> completeToggle({
    required DatabaseName datalist,
    required int index,
    required BuildContext context,
  }) async {
    final ScaffoldMessengerState? messenger =
        ScaffoldMessenger.maybeOf(context);
    final Color snackBarColor = Theme.of(context).primaryColor;
    TodoData movedItem;
    if (datalist == DatabaseName.todo) {
      movedItem = _todoTasks.removeAt(index);
      _doneTasks.add(movedItem);
      notifyListeners();
      showSnackBarFromMessenger(
          messenger: messenger,
          backgroundColor: snackBarColor,
          message: 'Successfully completed task');
      try {
        await Database.completeToggle(dataList: datalist, index: index);
      } catch (_) {
        // Restore from storage if persistence fails.
        await intializeData();
      }
    } else {
      movedItem = _doneTasks.removeAt(index);
      _todoTasks.add(movedItem);
      notifyListeners();
      showSnackBarFromMessenger(
          messenger: messenger,
          backgroundColor: snackBarColor,
          message: 'Successfully undo donetask');
      try {
        await Database.completeToggle(dataList: datalist, index: index);
      } catch (_) {
        // Restore from storage if persistence fails.
        await intializeData();
      }
    }
  }

  Future<void> removeItem(
      {required DatabaseName datalist,
      required int index,
      required context}) async {
    final ScaffoldMessengerState? messenger =
        ScaffoldMessenger.maybeOf(context);
    final Color snackBarColor = Theme.of(context).primaryColor;
    final List<TodoData> targetList =
        datalist == DatabaseName.todo ? _todoTasks : _doneTasks;
    final TodoData removedItem = targetList.removeAt(index);
    notifyListeners();
    try {
      await Database.removeData(databaseName: datalist, index: index);
      showSnackBarFromMessenger(
          messenger: messenger,
          backgroundColor: snackBarColor,
          message: 'Successfully Deleted');
    } catch (_) {
      targetList.insert(index, removedItem);
      notifyListeners();
      await intializeData();
    }
  }

  void cleanDoneTask() {
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
    var temp = _todoTasks.removeAt(oldIndex);
    _todoTasks.insert(newIndex, temp);
    await Database.saveData(
        databaseName: DatabaseName.todo, newList: _todoTasks);
  }

  updateValue() {
    notifyListeners();
  }
}
