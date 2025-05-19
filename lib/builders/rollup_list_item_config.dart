import 'package:flutter/material.dart';

import '../models/all.dart';
import '../utils/all.dart';

class SambazaRollupListItemConfigBuilder
    extends SambazaListItemConfigBuilder<Rollup, SambazaModel> {
  SambazaRollupListItemConfigBuilder()
      : super(
          group: (Rollup rollup, [SambazaModel listItem]) =>
              SambazaListItemConfigBuilder.strFromTime(rollup.createdAt),
          leading: (Rollup rollup, [SambazaModel listItem]) =>
              _buildLeadingIcon(rollup),
          subtitle: (Rollup rollup, [SambazaModel listItem]) {
            DateTime time = rollup.createdAt;
            return <String>[
              'KES ${rollup.value.toInt().toString()}',
              'Placed at ${time.hour.toString()}:${time.minute.toString()}',
            ];
          },
          title: (Rollup rollup, [SambazaModel listItem]) =>
              rollup.referenceNumber.toString(),
        );

  static List<Widget> _buildLeadingIcon(Rollup rollup) => <Widget>[
        Text(
          '#Ref',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
          ),
        ),
        Text(
          rollup.referenceNumber.toString().substring(0, 4),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ];
}
