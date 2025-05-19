import 'package:flutter/material.dart';

import '../builders/inventory_list_item_config.dart';
import '../models/all.dart';
import '../services/all.dart';
import '../utils/all.dart';

class SambazaInventoryWidget<I extends Inventory>
    extends SambazaInjectableStatelessWidget {
  final List<Type> $inject = <Type>[SambazaAPI, SambazaAuth, SambazaStorage];
  final SambazaListBuilder<I, SambazaModel> _listBuilder;

  SambazaInventoryWidget(
      {SambazaModelFactory<I> modelFactory, SambazaResource resource})
      : _listBuilder = SambazaListBuilder<I, SambazaModel>(
          listItemConfigBuilder: SambazaInventoryListItemConfigBuilder<I>(),
          modelFactory: modelFactory,
          resource: resource,
        );

  @override
  Widget template(BuildContext context) => RefreshIndicator(
        child: ListView(
          children: <Widget>[_listBuilder(context)],
          padding: EdgeInsets.only(
            bottom: 8,
            top: 8,
          ),
          scrollDirection: Axis.vertical,
        ),
        onRefresh: _onRefresh,
      );

  Future<void> _onRefresh() => Future.sync(() {
        $$<SambazaStorage>().remove(_listBuilder.resource.endpoint);
      });
}
