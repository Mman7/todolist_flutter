import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'todo_item.dart';

import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class DoneTaskList extends StatelessWidget {
  const DoneTaskList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _doneTask = context.watch<DataProvider>().doneTasks;
    var dataContext = context.watch<DataProvider>();

    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        itemCount: _doneTask.length,
        itemBuilder: (context, index) {
          return TodoItem(
            isHighlight: _doneTask[index][0],
            opacity: 0.5,
            child: ListTile(
                dense: true,
                title: Text(
                  _doneTask[index][1],
                  style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize:
                          Theme.of(context).textTheme.bodyLarge?.fontSize),
                ),
                trailing: Wrap(children: [
                  CustomButton(
                    callback: () => dataContext.returnTask(
                      context: context,
                      returnItemIndex: index,
                    ),
                    iconData: Icons.subdirectory_arrow_left,
                  ),
                  CustomButton(
                    callback: () => {
                      dataContext.deleteTask(
                          list: _doneTask,
                          removeIndex: index,
                          databasename: 'done',
                          context: context),
                    },
                    iconData: Icons.delete_outline,
                  ),
                ])),
          );
        });
  }
}
