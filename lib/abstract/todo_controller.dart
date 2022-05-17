import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
export './todo_controller.dart' show TodoController;

class TodoController {
  void deleteTask(
      {required List list,
      required int removeIndex,
      required String databasename,
      required BuildContext context,
      callback}) async {
    list.removeAt(removeIndex);
    saveData(databasename, list);
    TodoController()
        .showSnackBar(context: context, message: 'Successfully Deleted');
  }

  Future<List> addTask(
      {required BuildContext context,
      required List todoList,
      required value}) async {
    todoList.add(['false', value]);
    saveData('todo', todoList);
    showSnackBar(context: context, message: 'Successfully Added');
    return todoList;
  }

  Future setAsSpecial({required index, required context}) async {
    var data = await getData(dataBaseName: 'todo');
    data[index][0] = data[index][0] == 'false' ? 'true' : 'false';
    saveData('todo', data);
    showSnackBar(context: context, message: 'Successfully Set As Special');
  }

  Future returnTask({
    required BuildContext context,
    required List todoList,
    required List doneList,
    required int returnItemIndex,
  }) async {
    final returnItem = doneList[returnItemIndex];
    todoList.add(returnItem);
    doneList.removeAt(returnItemIndex);
    saveData('todo', todoList);
    saveData('done', doneList);
    showSnackBar(context: context, message: "Successfully Returned");
    return doneList;
  }

  Future<List> completeTask({
    required BuildContext context,
    required int completedIndex,
    required List todoList,
    required List doneList,
  }) async {
    final completedItem = todoList[completedIndex];
    todoList.removeAt(completedIndex);
    doneList.insert(0, completedItem);
    saveData('todo', todoList);
    saveData('done', doneList);
    showSnackBar(context: context, message: 'Successfully Completed');
    return todoList;
  }

  void saveData(String dataBaseName, List dataItemList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = json.encode(dataItemList);
    prefs.setString(dataBaseName, data);
  }

  showSnackBar({required BuildContext context, required String message}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 1000),
        content: Text(message)));
  }

  Future<List> getData({required String dataBaseName}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var hey = prefs.getString(dataBaseName) ?? '[]';
    List data = json.decode(hey);
    // ignore: prefer_typing_uninitialized_variables
    var newData;
    isStringOrNot(value) => value.runtimeType == String ? true : false;
    for (var i in data) {
      if (isStringOrNot(i)) {
        newData = [
          ...?newData,
          ['false', i]
        ];
      } else {
        newData = [...?newData, i];
      }
    }
    return newData ?? [];
  }

  Future<List> cleanDoneTask({
    required BuildContext context,
    required List doneList,
  }) async {
    doneList = [];
    TodoController().saveData('done', doneList);
    showSnackBar(context: context, message: 'Successfully Clean Done Task');
    return doneList;
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
