import 'package:flutter/material.dart';

import '../models/all.dart';
import '../resources.dart';
import '../utils/all.dart';

class SambazaSaleListItemConfigBuilder
    extends SambazaListItemConfigBuilder<Sale, SaleItem> {
  static Future<SambazaModels<Telco>> _telcoFuture = SambazaModel.list<Telco>(
    TelcoResource(),
    ([Map<String, dynamic> fields]) => Telco.create(fields),
  );
  
  SambazaSaleListItemConfigBuilder()
      : super(
          group: (Sale sale, [SaleItem saleItem]) =>
              SambazaListItemConfigBuilder.strFromTime(saleItem.createdAt),
          leading: _buildLeading,
          subtitle: (Sale sale, [SaleItem saleItem]) {
            DateTime time = saleItem.createdAt;
            return <String>[
              'KES ${saleItem.value.toInt().toString()}',
              'Placed at ${time.hour.toString()}:${time.minute.toString()}',
            ];
          },
          title: (Sale sale, [SaleItem saleItem]) =>
              '${saleItem.quantity.toInt().toString()} Cards',
        );

  static List<Widget> _buildLeading(Sale sale, [SaleItem saleItem]) => <Widget>[
        Text(
          saleItem.airtime.value.toInt().toString(),
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
                      (Telco telco) => telco.id == saleItem.airtime.telco,
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
}
