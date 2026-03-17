import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_todo/model/todo_data.dart';

/// Names for the two persistent lists used by the app.
/// Stored as string keys in `SharedPreferences`.
enum DatabaseName {
  // Active todo tasks
  todo,
  // Completed/done tasks
  done,
}

class Database {
  // Cached SharedPreferences instance (initialized on first use)
  static dynamic prefs;

  // Ensure SharedPreferences is initialized before any read/write.
  static Future<void> intializeData() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Load a list of `TodoData` from storage for the given `dataBaseName`.
  /// Returns an empty list when no data is present.
  static Future<List<TodoData>> getData(
      {required DatabaseName dataBaseName}) async {
    await intializeData();
    // if it doesn't get any data return empty list
    final String rawData = prefs.getString(dataBaseName.toString()) ?? '[]';
    final List<dynamic> parsed = json.decode(rawData);

    // Convert the dynamic list to a list of TodoData objects.
    final List<TodoData> decoded = parsed
        .whereType<Map>()
        .map((item) => TodoData.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    return decoded;
  }

  /// Persist `newList` for the provided `databaseName`.
  static Future<void> saveData(
      {required List<TodoData> newList,
      required DatabaseName databaseName}) async {
    await intializeData();
    final String data =
        json.encode(newList.map((item) => item.toJson()).toList());
    await prefs.setString(databaseName.toString(), data);
  }

  static saveAll(List<TodoData> todoList, List<TodoData> doneList) async {
    await saveData(newList: todoList, databaseName: DatabaseName.todo);
    await saveData(newList: doneList, databaseName: DatabaseName.done);
  }

  /// Remove the item at [index] from the given database and save.
  static Future<void> removeData(
      {required DatabaseName databaseName, required int index}) async {
    final List<TodoData> list = await getData(dataBaseName: databaseName);
    list.removeAt(index);
    await saveData(databaseName: databaseName, newList: list);
  }

  /// Clear all completed tasks from storage.
  static cleanDoneTask() async {
    SharedPreferences.getInstance()
        .then((e) => e.remove(DatabaseName.done.toString()));
  }
}
