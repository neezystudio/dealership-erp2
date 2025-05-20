import 'package:flutter/material.dart';

import '../utils/builders/latest_list.dart';

class SambazaLatestList extends StatelessWidget {
  final SambazaLatestListBuilder builder;
  final String title;

  const SambazaLatestList({super.key, required this.builder, required this.title});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          builder.buildTitle(context),
          SizedBox(height: 8.0),
          builder(context),
        ],
      );
}
