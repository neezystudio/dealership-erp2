import 'package:flutter/material.dart';

class SambazaFieldRow extends StatelessWidget {

  final List<Widget> children;

  SambazaFieldRow({super.key, required this.children}) {
    for(var i = 1; i < children.length; i+=2) {
      children.insert(i, SizedBox(width: 8));
    }
  }

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: children,
      );

  static Widget child({required FormField<String> field, int flex = 1}) => Expanded(
    flex: flex,
    child: field,
  );

}
