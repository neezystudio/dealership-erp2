import 'package:flutter/material.dart';

class SambazaPage extends StatelessWidget {
  final Widget body;
  final Widget fab;
  final String title;

  SambazaPage({required this.body, required this.fab, required this.title});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: body,
        floatingActionButton: fab,
      );
}
