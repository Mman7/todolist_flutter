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

/// Lightweight local data helper using `SharedPreferences`.
///
/// This class wraps JSON (de)serialization for `TodoData` and
/// provides small utility methods used across the app:
/// - `getData` / `saveData` for loading and storing lists
/// - `removeData` to remove by index
/// - `completeToggle` to move items between `todo` and `done`
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

  /// Remove the item at [index] from the given database and save.
  static Future<void> removeData(
      {required DatabaseName databaseName, required int index}) async {
    final List<TodoData> list = await getData(dataBaseName: databaseName);
    list.removeAt(index);
    await saveData(databaseName: databaseName, newList: list);
  }

  // Helper method to swap items between lists for complete toggle.
  // This moves the item at `index` from `todoList` into `doneList`.
  static _swapItem(
      {required List todoList, required List doneList, required int index}) {
    // Copy the item from the source list
    final item = todoList[index];
    // remove it from the first list and add it to the second list
    todoList.removeAt(index);
    doneList.add(item);
  }

  /// Toggle completion: move an item from `todo` to `done` or vice versa.
  /// The method reads both lists, swaps the item, then writes both lists back.
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

    // Persist both lists after the swap.
    await saveData(databaseName: DatabaseName.todo, newList: todoList);
    await saveData(databaseName: DatabaseName.done, newList: doneList);
  }

  /// Clear all completed tasks from storage.
  static cleanDoneTask() async {
    SharedPreferences.getInstance()
        .then((e) => e.remove(DatabaseName.done.toString()));
  }
}
