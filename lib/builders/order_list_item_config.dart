import 'package:flutter/material.dart';

import '../models/all.dart';
import '../resources.dart';
import '../utils/all.dart';

class SambazaOrderListItemConfigBuilder
    extends SambazaListItemConfigBuilder<Order, OrderItem> {
  static Future<SambazaModels<Telco>> _telcoFuture = SambazaModel.list<Telco>(
    TelcoResource(),
    ([Map<String, dynamic>? fields]) => Telco.create(fields!),
  );
  
  SambazaOrderListItemConfigBuilder()
      : super(
          group: (Order order, [OrderItem? orderItem]) =>
              SambazaListItemConfigBuilder.strFromTime(orderItem!.createdAt),
          leading: _buildLeading,
          subtitle: (Order order, [OrderItem? orderItem]) {
            DateTime time = orderItem!.createdAt;
            return <String>[
              'KES ${orderItem.value.toInt().toString()}',
              'Placed at ${time.hour.toString()}:${time.minute.toString()}',
            ];
          },
          title: (Order order, [OrderItem? orderItem]) =>
              '${orderItem!.quantity.toInt().toString()} Cards',
        );

  static List<Widget> _buildLeading(Order order, [OrderItem? orderItem]) =>
      <Widget>[
        Text(
          orderItem!.airtime.value.toInt().toString(),
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
                snapshot.data!.list
                    .firstWhere(
                      (Telco telco) => telco.id == orderItem.airtime.telco,
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
