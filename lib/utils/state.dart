import 'package:flutter/material.dart';

import '../state.dart';

abstract class SambazaWidgetState<T extends StatefulWidget> extends State<T> {
  SambazaState get state => SambazaState.of(context);

  @override
  Widget build(BuildContext context) => template(context);

  void showSnackBar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          Text(title),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
    ));
  }

  Widget template(BuildContext context);
}
