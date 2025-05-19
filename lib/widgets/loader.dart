import 'package:flutter/material.dart';

class SambazaLoader extends StatelessWidget {

  final String label;

  SambazaLoader([this.label = 'Loading']);

  @override
  Widget build(BuildContext context) => Center(
    child: CircularProgressIndicator(
      semanticsLabel: label,
    ),
  );
}
