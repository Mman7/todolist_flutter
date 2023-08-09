import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({Key? key, required this.iconData, required this.callback})
      : super(key: key);
  final IconData iconData;
  final Function callback;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  Offset buttonPosition = const Offset(0, 0);
  late DataProvider dataContext;
  @override
  void initState() {
    super.initState();
    dataContext = context.read<DataProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        setState(() {
          buttonPosition = e.position;
        });
      },
      onPointerUp: (e) {
        if (buttonPosition != e.position) return;
        dataContext.updatePos(e.position);
        widget.callback();
      },
      child: IconButton(
          color: Colors.white, onPressed: () {}, icon: Icon(widget.iconData)),
    );
  }
}
