import 'package:flutter/material.dart';
import 'package:simple_todo/abstract/widget/todo_item.dart';

import 'package:provider/provider.dart';
import 'package:simple_todo/model/todo_data.dart';
import '../providers/data_provider.dart';

class DoneTaskList extends StatelessWidget {
  const DoneTaskList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TodoData> _doneTask = context.watch<DataProvider>().doneTasks;
    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        itemCount: _doneTask.length,
        itemBuilder: (context, index) {
          return TodoItem(
              isTodoTask: false,
              index: index,
              opacity: 0.5,
              isHighlight: _doneTask[index].isHighlight,
              title: _doneTask[index].title);
        });
  }
}
