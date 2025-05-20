import 'package:flutter/material.dart';

import '../builders/dispatch_list_item_config.dart';
import '../models/all.dart';
import '../services/all.dart';
import '../utils/all.dart';

class SambazaDispatchWidget<D extends Dispatch, DI extends DispatchItem>
    extends SambazaInjectableStatelessWidget {
  final List<Type> $inject = <Type>[SambazaAPI, SambazaAuth, SambazaStorage];
  final SambazaListBuilder<D, SambazaModel> _listBuilder;

  SambazaDispatchWidget({
    required SambazaModelFactory<D> modelFactory,
    required SambazaResource resource,
    required List<String> Function(D, [DI]) subtitle,
    required String Function(D, [DI]) title,
  }) : _listBuilder = SambazaListBuilder<D, DI>(
          listItemConfigBuilder: SambazaDispatchListItemConfigBuilder<D, DI>(
            subtitle: subtitle,
            title: title,
          ),
          listName: 'dispatch_items',
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
