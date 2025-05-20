import 'package:flutter/material.dart';

import '../builders/dispatch_list_item_config.dart';
import '../models/all.dart';
import '../services/all.dart';
import '../utils/all.dart';

class SambazaDispatchWidget<D extends Dispatch, DI extends DispatchItem>
    extends SambazaInjectableStatelessWidget {
  @override
  final List<Type> $inject = <Type>[SambazaAPI, SambazaAuth, SambazaStorage];
  final SambazaListBuilder<D, SambazaModel> _listBuilder;

  SambazaDispatchWidget({super.key, 
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
          resource: resource, requestParams: {},
        );

  @override
  Widget template(BuildContext context) => RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          children: <Widget>[_listBuilder(context)],
          padding: EdgeInsets.only(
            bottom: 8,
            top: 8,
          ),
          scrollDirection: Axis.vertical,
        ),
      );

  Future<void> _onRefresh() => Future.sync(() {
        $$<SambazaStorage>().remove(_listBuilder.resource.endpoint);
      });
}
