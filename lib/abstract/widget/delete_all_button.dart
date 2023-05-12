import 'package:flutter/material.dart';
import "package:provider/provider.dart";

/// Providers
import '../providers/theme_provider.dart';
import '../providers/data_provider.dart';

Widget deleteAllButton({selectedIndex, context, doneTask, callback}) {
  if (selectedIndex != 1) return Container();
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 13.5, vertical: 0),
    child: IconButton(
      icon: Icon(Icons.delete_forever,
          size: 40, color: Theme.of(context).secondaryHeaderColor),
      onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                  'Are you sure delete forever?',
                  style: TextStyle(
                      color: context.read<ThemeProvider>().themeMode ==
                              ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight:
                          Theme.of(context).textTheme.bodyLarge?.fontWeight,
                      fontSize:
                          Theme.of(context).textTheme.bodyLarge?.fontSize),
                ),
                actions: [
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
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
                              MaterialStateProperty.all(Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('No',
                          style: TextStyle(color: Colors.white)))
                ],
              )),
    ),
  );
}
