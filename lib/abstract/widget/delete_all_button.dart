import 'package:flutter/material.dart';

Widget deleteAllButton({selectedIndex, context, callback}) {
  if (selectedIndex != 1) return Container();
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 13.5, vertical: 0),
    child: IconButton(
      splashColor: Colors.white,
      icon: Icon(Icons.delete_forever,
          size: 40, color: Theme.of(context).primaryColor),
      onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                  'Are you sure remove all done tasks?',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          Theme.of(context).textTheme.bodyLarge?.fontWeight,
                      fontSize:
                          Theme.of(context).textTheme.bodyLarge?.fontSize),
                ),
                actions: [
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).primaryColor)),
                      onPressed: () {
                        callback();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Sure',
                          style: TextStyle(color: Colors.white))),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.grey[800])),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child:
                        const Text('No', style: TextStyle(color: Colors.white)),
                  )
                ],
              )),
    ),
  );
}
