import 'package:flutter/material.dart';

class SambazaFieldRow extends StatelessWidget {

  final List<Widget> children;

  SambazaFieldRow({required this.children}) {
    for(var i = 1; i < children.length; i+=2) {
      children.insert(i, SizedBox(width: 8));
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
      );

  static Widget child({required FormField<String> field, int flex = 1}) => Expanded(
    child: field,
    flex: flex,
  );

}
