import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_todo/model/todo_data.dart';

enum DatabaseName {
  todo,
  done,
}

class Database {
  static dynamic prefs;
  static Future<void> intializeData() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<List<TodoData>> getData(
      {required DatabaseName dataBaseName}) async {
    await intializeData();
    // if it doesnt get any data return empty list
    final String rawData = prefs.getString(dataBaseName.toString()) ?? '[]';
    final List<dynamic> parsed = json.decode(rawData);

    // Convert the dynamic list to a list of TodoData objects.
    final List<TodoData> decoded = parsed
        .whereType<Map>()
        .map((item) => TodoData.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return decoded;
  }

  static Future<void> saveData(
      {required List<TodoData> newList,
      required DatabaseName databaseName}) async {
    await intializeData();
    final String data =
        json.encode(newList.map((item) => item.toJson()).toList());
    await prefs.setString(databaseName.toString(), data);
  }

  static Future<void> removeData(
      {required DatabaseName databaseName, required int index}) async {
    final List<TodoData> list = await getData(dataBaseName: databaseName);
    list.removeAt(index);
    await saveData(databaseName: databaseName, newList: list);
  }

  // Helper method to swap items between lists for complete toggle.
  static _swapItem(
      {required List todoList, required List doneList, required int index}) {
    // Copy the item from the list
    final item = todoList[index];
    // remove it from the first list and add it to the second list
    todoList.removeAt(index);
    doneList.add(item);
  }

  static Future<void> completeToggle({
    required DatabaseName dataList,
    required int index,
  }) async {
    final List<TodoData> todoList =
        await getData(dataBaseName: DatabaseName.todo);
    final List<TodoData> doneList =
        await getData(dataBaseName: DatabaseName.done);

    if (dataList == DatabaseName.todo) {
      _swapItem(todoList: todoList, doneList: doneList, index: index);
    }

    if (dataList == DatabaseName.done) {
      _swapItem(todoList: doneList, doneList: todoList, index: index);
    }

    await saveData(databaseName: DatabaseName.todo, newList: todoList);
    await saveData(databaseName: DatabaseName.done, newList: doneList);
  }

  static cleanDoneTask() async {
    SharedPreferences.getInstance()
        .then((e) => e.remove(DatabaseName.done.toString()));
  }
}
