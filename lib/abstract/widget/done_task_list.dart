import 'package:flutter/material.dart';
import 'package:simple_todo/abstract/widget/todo_item.dart';

import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class DoneTaskList extends StatelessWidget {
  const DoneTaskList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _doneTask = context.watch<DataProvider>().doneTasks;
    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        itemCount: _doneTask.length,
        itemBuilder: (context, index) {
          return TodoItem(
              isTodoTask: false,
              index: index,
              opacity: 0.5,
              isHighlight: _doneTask[index][0],
              title: _doneTask[index][1]);
        });
  }
}
