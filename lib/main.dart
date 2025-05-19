import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'model.dart';
import 'pages.dart';

void main() => runApp(ScopedModel(
  model: SambazaModel(),
  child: Sambaza(),
));

class Sambaza extends StatelessWidget {
  const Sambaza({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sambaza',
    theme: ThemeData(
      primarySwatch: Colors.cyan,
      primaryTextTheme: Typography.whiteMountainView,
    ),
    home: Container(
      child: Center(
        child: Text('Karibu!'),
      ),
    ),
  );
}
