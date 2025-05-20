import 'package:flutter/material.dart';

import '../utils/builders/latest_list.dart';

class SambazaLatestList extends StatelessWidget {
  final SambazaLatestListBuilder builder;
  final String title;

  SambazaLatestList({required this.builder, required this.title});

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          builder.buildTitle(context),
          SizedBox(height: 8.0),
          builder(context),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      );
}
