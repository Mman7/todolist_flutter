import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataList {
  static const String todo = 'todo';
  static const String done = 'done';
}

class Database {
  static dynamic prefs;
  static intializeData() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future getData({required String dataBaseName}) async {
    await intializeData();
    //* if it doesnt get any data return empty list
    var rawData = prefs.getString(dataBaseName) ?? '[]';
    List data = json.decode(rawData);
    return data;
  }

  static saveData({newList, dataBaseList}) {
    var data = json.encode(newList);
    prefs.setString(dataBaseList, data);
  }

  static removeData({required String databaseName, required int index}) async {
    List list = await getData(dataBaseName: databaseName);
    list.removeAt(index);
    saveData(dataBaseList: databaseName, newList: list);
  }

  static completeToggle({dataList, index}) async {
    List todoList = await getData(dataBaseName: DataList.todo);
    List doneList = await getData(dataBaseName: DataList.done);
    dynamic item;
    if (dataList == DataList.todo) {
      item = todoList[index];
      todoList.removeAt(index);
      doneList.add(item);
    }
    if (dataList == DataList.done) {
      item = doneList[index];
      doneList.removeAt(index);
      todoList.add(item);
    }
    saveData(dataBaseList: DataList.todo, newList: todoList);
    saveData(dataBaseList: DataList.done, newList: doneList);
  }

  static cleanDoneTask() async {
    SharedPreferences.getInstance().then((e) => e.remove(DataList.done));
  }
}
