import 'package:flutter/material.dart';
import 'package:simple_todo/abstract/widget/todo_item_view.dart';

import 'package:provider/provider.dart';
import 'package:simple_todo/model/todo_data.dart';
import '../providers/data_provider.dart';

class DoneTaskList extends StatelessWidget {
  final ScrollController? scrollController;

  const DoneTaskList({Key? key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TodoItem> _doneTask = context.watch<DataProvider>().doneTasks;
    return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        itemCount: _doneTask.length,
        itemBuilder: (context, index) {
          return TodoItemView(
            todoItem: _doneTask[index],
            index: index,
          );
        });
  }
}
