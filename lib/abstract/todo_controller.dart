import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
export './todo_controller.dart' show TodoController;

class TodoController {
  void deleteTask(
      {required List<String> list,
      required int removeIndex,
      required String databasename,
      required BuildContext context,
      callback}) async {
    list.removeAt(removeIndex);
    saveData(databasename, list);
    TodoController()
        .showSnackBar(context: context, message: 'Successfully Deleted');
  }

  Future<List<String>> addTask(
      {required BuildContext context,
      required List<String> todoList,
      required value}) async {
    todoList.add(value);
    saveData('todo', todoList);
    showSnackBar(context: context, message: 'Successfully Added');
    return todoList;
  }

  Future returnTask({
    required BuildContext context,
    required List<String> todoList,
    required List<String> doneList,
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

  Future<List<String>> completeTask({
    required BuildContext context,
    required int completedIndex,
    required List<String> todoList,
    required List<String> doneList,
  }) async {
    final completedItem = todoList[completedIndex];
    todoList.removeAt(completedIndex);
    doneList.insert(0, completedItem);
    saveData('todo', todoList);
    saveData('done', doneList);
    showSnackBar(context: context, message: 'Successfully Completed');
    return todoList;
  }

  void saveData(String dataBaseName, List<String> dataItemList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(dataBaseName, dataItemList);
  }

  showSnackBar({required BuildContext context, required String message}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 1000),
        content: Text(message)));
  }

  Future<List<String>> getData({required String dataBaseName}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getStringList(dataBaseName);
    return data ?? [];
  }

  Future<List<String>> cleanDoneTask({
    required BuildContext context,
    required List<String> doneList,
  }) async {
    doneList = [];
    TodoController().saveData('done', doneList);
    showSnackBar(context: context, message: 'Successfully Clean Done Task');
    return doneList;
  }

  Future<List<String>> reOrderItem(
      {required List<String> todoList,
      required int oldIndex,
      required int newIndex}) async {
    final moveItem = todoList[oldIndex];

    todoList.insert(newIndex, moveItem);
    todoList.removeAt(oldIndex);
    saveData('todo', todoList);
    return todoList;
  }
}
