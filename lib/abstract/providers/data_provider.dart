import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider with ChangeNotifier {
  List<dynamic> _todoTasks = [];
  List<dynamic> _doneTasks = [];

  get todoTasks => _todoTasks;
  get doneTasks => _doneTasks;

  intializeData() async {
    _todoTasks = await getData(dataBaseName: 'todo');
    _doneTasks = await getData(dataBaseName: 'done');
    notifyListeners();
  }

  void deleteTask(
      {required List list,
      required int removeIndex,
      required String databasename,
      required BuildContext context,
      callback}) async {
    list.removeAt(removeIndex);
    saveData(databasename, list);
    showSnackBar(context: context, message: 'Successfully Deleted');
    notifyListeners();
  }

  addTask({required BuildContext context, required value}) async {
    _todoTasks.insert(0, ["false", value]);
    saveData('todo', _todoTasks);
    showSnackBar(context: context, message: 'Successfully Added');
    notifyListeners();
  }

  Future setAsSpecial({required index, required context}) async {
    var data = await getData(
        dataBaseName:
            'todo'); // TODO :using current data no need to get again from database
    data[index][0] = data[index][0] == 'false' ? 'true' : 'false';
    saveData('todo', data);
    showSnackBar(context: context, message: 'Successfully Set As Special');
  }

  showSnackBar({required BuildContext context, required String message}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 1000),
        content: Text(message)));
  }

  Future returnTask({
    required BuildContext context,
    required int returnItemIndex,
  }) async {
    final returnItem = _doneTasks[returnItemIndex];
    _todoTasks.add(returnItem);
    _doneTasks.removeAt(returnItemIndex);
    saveData('todo', _todoTasks);
    saveData('done', _doneTasks);
    showSnackBar(context: context, message: "Successfully Returned");
    notifyListeners();
  }

  Future completeTask({
    required BuildContext context,
    required int completedIndex,
  }) async {
    final completedItem = _todoTasks[completedIndex];
    _todoTasks.removeAt(completedIndex);
    _doneTasks.insert(0, completedItem);
    saveData('todo', _todoTasks);
    saveData('done', _doneTasks);
    showSnackBar(context: context, message: 'Successfully Completed');
    notifyListeners();
  }

  void saveData(String dataBaseName, List dataItemList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = json.encode(dataItemList);
    prefs.setString(dataBaseName, data);
  }

  Future getData({required String dataBaseName}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var hey = prefs.getString(dataBaseName) ?? '[]';
    // if it doesnt get any data return empty array
    List data = json.decode(hey);
    return data;
  }

  cleanDoneTask({
    required BuildContext context,
  }) {
    _doneTasks = [];
    saveData('done', _doneTasks);
    showSnackBar(context: context, message: 'Successfully Clean Done Task');
    notifyListeners();
  }

  Future<List> reOrderItem(
      {required List todoList,
      required int oldIndex,
      required int newIndex}) async {
    // if the newIndex is larger than oldIndex newIndex will decrease 1
    // because reorder widget newIndex is larger than the expected value
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var temp = todoList.removeAt(oldIndex);
    todoList.insert(newIndex, temp);
    saveData('todo', todoList);
    return todoList;
  }
}
