import 'package:flutter/material.dart';

import '../builders/inventory_list_item_config.dart';
import '../models/all.dart';
import '../services/all.dart';
import '../utils/all.dart';

class SambazaInventoryWidget<I extends Inventory>
    extends SambazaInjectableStatelessWidget {
  @override
  final List<Type> $inject = <Type>[SambazaAPI, SambazaAuth, SambazaStorage];
  final SambazaListBuilder<I, SambazaModel> _listBuilder;

  SambazaInventoryWidget({
    super.key,
    required SambazaModelFactory<I> modelFactory,
    required SambazaResource resource,
  }) : _listBuilder = SambazaListBuilder<I, SambazaModel>(
         listItemConfigBuilder: SambazaInventoryListItemConfigBuilder<I>(),
         modelFactory: modelFactory,
         resource: resource,
         requestParams: const {}, // Provide appropriate params if needed
       );

  @override
  Widget template(BuildContext context) => RefreshIndicator(
    onRefresh: _onRefresh,
    child: ListView(
      padding: EdgeInsets.only(bottom: 8, top: 8),
      scrollDirection: Axis.vertical,
      children: <Widget>[_listBuilder(context)],
    ),
  );

  Future<void> _onRefresh() => Future.sync(() {
    $$<SambazaStorage>().remove(_listBuilder.resource.endpoint);
  });
}
