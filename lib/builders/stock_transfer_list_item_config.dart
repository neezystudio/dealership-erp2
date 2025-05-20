import 'package:flutter/material.dart';

import '../models/all.dart';
import '../resources.dart';
import '../utils/all.dart';
import '../widgets/all.dart';

class SambazaStockTransferListItemConfigBuilder
    extends SambazaListItemConfigBuilder<StockTransfer, SambazaModel> {
  static Future<SambazaModels<Airtime>> _airtimeFuture = SambazaModel.list(
    AirtimeResource(),
    ([
      Map<String, dynamic>? f,
    ]) =>
        Airtime.create(
      f!,
    ),
  );
  static Future<SambazaModels<Telco>> _telcoFuture = SambazaModel.list(
    TelcoResource(),
    ([
      Map<String, dynamic>? f,
    ]) =>
        Telco.create(
      f!,
    ),
  );

  SambazaStockTransferListItemConfigBuilder(
    String entity,
  ) : super(
          group: (
            StockTransfer sT, [
            SambazaModel? i,
          ]) =>
              SambazaListItemConfigBuilder.strFromTime(
            sT.createdAt,
          ),
          leading: _buildLeading,
          subtitle: (
            StockTransfer sT, [
            SambazaModel? i,
          ]) =>
              <String>[
            '${sT.$originType} - ${sT.$destinationType}',
          ],
          title: (
            StockTransfer sT, [
            SambazaModel? i,
          ]) =>
              '${sT.quantity.toString()} Cards @ KES ${sT.value.toInt().toString()}',
          trailing: (
            StockTransfer sT, [
            SambazaModel? i,
          ]) =>
              StockTransferTrailing(
            entity,
            sT,
          ),
        );

  static List<Widget> _buildLeading(
    StockTransfer sT, [
    SambazaModel? i,
  ]) =>
      <Widget>[
        _airtimeDependentBuilder(
          sT,
          _airtimeValueBuilder,
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
        _airtimeDependentBuilder(
          sT,
          _telcoNameBuilder,
          LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ];

  static FutureBuilder<SambazaModels<Airtime>> _airtimeDependentBuilder(
    StockTransfer stockTransfer,
    Widget Function(Airtime) _fulfilledWidgetBuilder,
    Widget _progressWidget,
  ) =>
      FutureBuilder<SambazaModels<Airtime>>(
        builder: (
          BuildContext context,
          AsyncSnapshot<SambazaModels<Airtime>> snapshot,
        ) {
          if (snapshot.hasData) {
            Airtime airtime = snapshot.data!.list.firstWhere(
              (Airtime a) => stockTransfer.airtime == a.id,
            );
            return _fulfilledWidgetBuilder(
              airtime,
            );
          } else if (snapshot.hasError) {
            print(
              snapshot.error,
            );
            return Icon(
              Icons.warning,
              semanticLabel: 'error',
            );
          }
          return _progressWidget;
        },
        future: _airtimeFuture,
      );

  static Text _airtimeValueBuilder(
    Airtime airtime,
  ) =>
      Text(
        airtime.value.toInt().toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      );

  static FutureBuilder<SambazaModels<Telco>> _telcoNameBuilder(
    Airtime airtime,
  ) =>
      FutureBuilder<SambazaModels<Telco>>(
        builder: (
          BuildContext context,
          AsyncSnapshot<SambazaModels<Telco>> snapshot,
        ) {
          if (snapshot.hasData) {
            return Text(
              snapshot.data!.list
                  .firstWhere(
                    (Telco t) => airtime.telco == t.id,
                  )
                  .name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 7,
              ),
            );
          } else if (snapshot.hasError) {
            print(
              snapshot.error,
            );
            return Icon(
              Icons.warning,
              semanticLabel: 'error',
            );
          }
          return LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
              Colors.white,
            ),
          );
        },
        future: _telcoFuture,
      );
}
