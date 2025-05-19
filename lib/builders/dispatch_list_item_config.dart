import 'package:flutter/material.dart';

import '../models/all.dart';
import '../resources.dart';
import '../utils/all.dart';
import '../widgets/all.dart';

class SambazaDispatchListItemConfigBuilder<D extends Dispatch,
    DI extends DispatchItem> extends SambazaListItemConfigBuilder<D, DI> {
  static Future<SambazaModels<Telco>> _telcoFuture = SambazaModel.list<Telco>(
    TelcoResource(),
    ([Map<String, dynamic> fields]) => Telco.create(fields),
  );
  final List<String> Function(D, [DI]) subtitle;
  final String Function(D, [DI]) title;

  SambazaDispatchListItemConfigBuilder(
      {@required this.subtitle, @required this.title})
      : super(
          group: (D dispatch, [DI dispatchItem]) =>
              SambazaListItemConfigBuilder.strFromTime(dispatchItem.createdAt),
          leading: _buildLeading,
          subtitle: subtitle,
          title: title,
          trailing: _buildTrailing,
        );

  static List<Widget>
      _buildLeading<D extends Dispatch, DI extends DispatchItem>(D dispatch,
              [DI dispatchItem]) =>
          <Widget>[
            Text(
              dispatchItem.airtime.value.toInt().toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            FutureBuilder<SambazaModels<Telco>>(
              builder: (
                BuildContext context,
                AsyncSnapshot<SambazaModels<Telco>> snapshot,
              ) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data.list
                        .firstWhere(
                          (Telco telco) => telco.id == dispatchItem.airtime.telco,
                        )
                        .name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Container();
                }
                return LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                );
              },
              future: _telcoFuture,
            ),
          ];

  static Widget _buildTrailing<D extends Dispatch, DI extends DispatchItem>(
          D dispatch,
          [DI dispatchItem]) =>
      DispatchItemTrailing(dispatchItem);
}
