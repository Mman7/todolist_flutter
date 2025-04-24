import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

Widget customFloatingButton({required BuildContext context, required onPress}) {
  return Container(
    decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: HexColor('#0085FF').withValues(alpha: 0.5),
              spreadRadius: 0.25,
              blurRadius: 20,
              offset: const Offset(0, 0))
        ],
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(50)),
    child: FloatingActionButton(
      onPressed: onPress,
      child: const Icon(
        Icons.add,
      ),
    ),
  );
}
