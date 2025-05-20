import 'package:flutter/material.dart';

import '../state.dart';

abstract class SambazaStatelessWidget extends StatelessWidget {
  final Map<String, dynamic> vars = <String, dynamic>{};

  const SambazaStatelessWidget({super.key});

  BuildContext get context => vars['context'];

  SambazaState get state => vars['state'];

  @override
  Widget build(BuildContext context) {
    vars['context'] = context;
    vars['state'] = SambazaState.of(context);
    return template(context);
  }

  void showSnackBar(String title, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
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
