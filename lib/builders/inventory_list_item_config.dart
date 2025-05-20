import 'package:flutter/material.dart';

import '../models/all.dart';
import '../resources.dart';
import '../utils/all.dart';

class SambazaInventoryListItemConfigBuilder<I extends Inventory>
    extends SambazaListItemConfigBuilder<I, SambazaModel> {
  static final Future<SambazaModels<Telco>> _telcoFuture = SambazaModel.list<Telco>(
    TelcoResource(),
    ([Map<String, dynamic>? fields]) => Telco.create(fields!),
  );

  SambazaInventoryListItemConfigBuilder()
      : super(
          leading: (I inventory, [SambazaModel? li]) =>
              _buildLeadingIcon(inventory),
          subtitle: (I inventory, [SambazaModel? li]) =>
              <String>['KES ${inventory.value.toString()}'],
          title: (I inventory, [SambazaModel? li]) =>
              '${inventory.quantity} Cards',
          trailing: (I inventory, [SambazaModel? li]) =>
              _buildTrailingIcon(inventory),
        );

  static List<Widget> _buildLeadingIcon<I extends Inventory>(I inventory) =>
      <Widget>[
        Text(
          inventory.airtime.value.toInt().toString(),
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
                      (Telco telco) => telco.id == inventory.airtime.telco,
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

  static Widget _buildTrailingIcon<I extends Inventory>(I inventory) {
    bool stocked = inventory.quantity > 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.fiber_manual_record,
          color: stocked ? Colors.green : Colors.red,
          semanticLabel:
              stocked ? 'Inventory is stocked' : 'Inventory is not stocked',
        ),
      ],
    );
  }
}
