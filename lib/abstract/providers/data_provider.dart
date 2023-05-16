import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider with ChangeNotifier {
  List<dynamic> _todoTasks = [];
  List<dynamic> _doneTasks = [];
  dynamic prefs;

  get todoTasks => _todoTasks;
  get doneTasks => _doneTasks;

  intializeData() async {
    prefs = await SharedPreferences.getInstance();
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
    var value = json.decode(_todoTasks[index][0]);
    _todoTasks[index][0] = '${!value}';
    saveData('todo', _todoTasks);
    showSnackBar(context: context, message: 'Successfully Set As Special');
    notifyListeners();
  }

  showSnackBar({required BuildContext context, required String message}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 800),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        )));
  }

  returnTask({
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

  completeTask({
    required BuildContext context,
    required int completedIndex,
  }) {
    final completedItem = _todoTasks[completedIndex];
    _todoTasks.removeAt(completedIndex);
    _doneTasks.insert(0, completedItem);
    saveData('todo', _todoTasks);
    saveData('done', _doneTasks);
    showSnackBar(context: context, message: 'Successfully Completed');
    notifyListeners();
  }

  saveData(String dataBaseName, List dataItemList) {
    var data = json.encode(dataItemList);
    prefs.setString(dataBaseName, data);
  }

  Future getData({required String dataBaseName}) async {
    //* if it doesnt get any data return empty array
    var rawData = prefs.getString(dataBaseName) ?? '[]';
    List data = json.decode(rawData);
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
      {required int oldIndex, required int newIndex}) async {
    // if the newIndex is larger than oldIndex newIndex will decrease 1
    // because reorder widget newIndex is larger than the expected value
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var temp = _todoTasks.removeAt(oldIndex);
    _todoTasks.insert(newIndex, temp);
    saveData('todo', _todoTasks);
    return _todoTasks;
  }
}
