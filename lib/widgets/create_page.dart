import 'package:flutter/material.dart';

import 'page.dart';

class SambazaCreatePage extends StatelessWidget {
  final Widget form;
  final String title;

  const SambazaCreatePage({super.key, required this.form, required this.title});

  @override
  Widget build(BuildContext context) => SambazaPage(
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(height: 8),
            Padding(
              child: Text(
                'Fill in the form below',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
              ),
            ),
            Container(
              child: form,
              padding: EdgeInsets.all(16.0),
            ),
          ],
        ),
        title: title, fab:form
        ,
      );
}
