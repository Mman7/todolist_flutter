import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_todo/abstract/localdatabase.dart';

class DataProvider with ChangeNotifier {
  List<dynamic> _todoTasks = [];
  List<dynamic> _doneTasks = [];
  dynamic buttonPos;
  dynamic prefs;
  get todoTasks => _todoTasks;
  get doneTasks => _doneTasks;
  intializeData() async {
    prefs = await SharedPreferences.getInstance();
    _todoTasks = await Database.getData(dataBaseName: 'todo');
    _doneTasks = await Database.getData(dataBaseName: 'done');
    notifyListeners();
  }

  updatePos(Offset offset) => buttonPos = offset;

  addTask({required BuildContext context, required value}) async {
    _todoTasks.add(["false", value]);
    Database.saveData(dataBaseList: DataList.todo, newList: todoTasks);
    showSnackBar(context: context, message: 'Successfully Added');
    notifyListeners();
  }

  Future setAsSpecial({required index, required context}) async {
    if (index == null) return;
    bool value = json.decode(_todoTasks[index][0]);
    _todoTasks[index][0] = '${!value}';
    showSnackBar(context: context, message: 'Successfully Highlighted');
    Database.saveData(dataBaseList: DataList.todo, newList: _todoTasks);
    notifyListeners();
  }

  showSnackBar({required BuildContext context, required String message}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 800),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        )));
  }

  void completeToggle({
    required String datalist,
    required int index,
    required context,
  }) {
    if (datalist == DataList.todo) {
      todoTasks.removeAt(index);
      Database.completeToggle(dataList: datalist, index: index);
      showSnackBar(context: context, message: 'Successfully completed task');
    } else {
      doneTasks.removeAt(index);
      Database.completeToggle(dataList: datalist, index: index);
      showSnackBar(context: context, message: 'Successfully undo donetask');
    }
    intializeData();
    notifyListeners();
  }

  void removeItem({required String datalist, required int index}) {
    if (datalist == DataList.todo) {
      Database.removeData(databaseName: datalist, index: index);
    }
    if (datalist == DataList.done) {
      Database.removeData(databaseName: datalist, index: index);
    }
    intializeData();
    notifyListeners();
  }

  void cleanDoneTask() {
    _doneTasks = [];
    Database.cleanDoneTask();
    notifyListeners();
  }

  reOrderItem({required int oldIndex, required int newIndex}) async {
    // if the newIndex is larger than oldIndex newIndex will decrease 1
    // because reorder widget newIndex is larger than the expected value
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var temp = _todoTasks.removeAt(oldIndex);
    _todoTasks.insert(newIndex, temp);
    Database.saveData(dataBaseList: DataList.todo, newList: _todoTasks);
  }

  updateValue() {
    notifyListeners();
  }
}
