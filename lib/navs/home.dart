import 'dart:async';
import 'package:flutter/material.dart';

import '../builders/all.dart';
import '../models/all.dart';
import '../pages/all.dart';
import '../resources.dart';
import '../services/all.dart';
import '../utils/all.dart';
import '../widgets/all.dart';

class HomeNav with SambazaInjectable implements SambazaNav {
  @override
  final bool hasFab = true;
  @override
  final IconData icon = Icons.home;
  @override
  final List<Type> $inject = <Type>[SambazaStorage];
  @override
  final String label = 'Home tab';
  @override
  final Widget view = _HomeNavView();
  @override
  final String title = 'Home';

  HomeNav() {
    inject();
  }

  @override
  void Function() onFabPressed(BuildContext context) => () {
        Navigator.pushNamed(
          context,
          CreateSalePage.route,
        ).then(
          (Object? result) {
            if (result is Map<String, dynamic>) {
              Map<String, dynamic> newSale = Map<String, dynamic>.from(result);
              SaleResource resource = SaleResource();
              SambazaStorage $storage = $$<SambazaStorage>();
              if ($storage.has(resource.endpoint)) {
                List<Map<String, dynamic>> sales =
                    $storage.$get(resource.endpoint);
                sales[sales.indexWhere(
                  (Map<String, dynamic> sale) => sale['id'] == newSale['id'],
                )] = newSale;
                $storage.$set(
                  resource.endpoint,
                  sales,
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: <Widget>[
                      Text('DONE'),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Your sale was created successfully!'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      };
}

class _HomeNavView extends SambazaInjectableStatelessWidget {
  @override
  final List<Type> $inject = <Type>[
    SambazaAuth,
    SambazaStorage,
  ];
  final List<SambazaFiguresConfig> _figuresConfigs = <SambazaFiguresConfig>[
    SambazaFiguresConfig(
      'Sales',
      SambazaAPIEndpoints.sales('/total/'),
      SambazaFiguresPeriod.daily,
    ),
    SambazaFiguresConfig(
      'Sales',
      SambazaAPIEndpoints.sales('/total/'),
      SambazaFiguresPeriod.monthly,
    ),
    SambazaFiguresConfig(
      'Commission',
      SambazaAPIEndpoints.sales('/total-commission/'),
      SambazaFiguresPeriod.daily,
    ),
    SambazaFiguresConfig(
      'Commission',
      SambazaAPIEndpoints.sales('/total-commission/'),
      SambazaFiguresPeriod.monthly,
    ),
  ];
  final List<SambazaLatestListBuilder> _latestListBuilders =
      _makeLatestListBuilders();

  MediaQueryData get mediaQuery => MediaQuery.of(context);

  static List<SambazaLatestListBuilder> _makeLatestListBuilders() =>
      
    <SambazaLatestListBuilder>[
      SambazaLatestListBuilder<DSADispatch, DSADispatchItem>(
        listItemConfigBuilder: SambazaDispatchListItemConfigBuilder<
            DSADispatch, DSADispatchItem>(
          subtitle: (
            DSADispatch dispatch, [
            DSADispatchItem? dispatchItem,
          ]) {
      final item = dispatchItem ?? DSADispatchItem.empty();
      return <String>[
        '${DSADispatchItem.serialFormatter(item.serialFirst)} - ${DSADispatchItem.serialFormatter(item.serialLast)}',
      ];
          },
          title: (
            DSADispatch dispatch, [
            DSADispatchItem? dispatchItem,
          ]) {
            final item = dispatchItem ?? DSADispatchItem.empty();
            return '${item.quantity.toString()} Cards - ${item.value.toInt().toString()}/=';
          },
        ),
        listName: 'dispatch_items',
        modelFactory: ([
          Map<String, dynamic> fields = const {},
        ]) =>
            DSADispatch.create(fields),
        resource: DSADispatchResource(),
        title: 'Latest Dispatches',
        requestParams: const <String, dynamic>{},
      ),
      SambazaLatestListBuilder<Sale, SaleItem>(
        listItemConfigBuilder: SambazaSaleListItemConfigBuilder(),
        listName: 'sale_items',
        modelFactory: ([
          Map<String, dynamic> fields = const {},
        ]) =>
            Sale.create(fields),
        resource: SaleResource(),
        title: 'Latest Sales',
        requestParams: const <String, dynamic>{},
      ),
    ];
  @override
  Widget template(BuildContext context) => RefreshIndicator(
        child: ListView(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 80),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: SambazaDebtCard(),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
            SizedBox(height: 8.0),
            GridView.count(
              children: _figuresConfigs
                  .map<Widget>(
                    (SambazaFiguresConfig c) => SambazaFiguresCard(c),
                  )
                  .toList(),
              childAspectRatio: mediaQuery.orientation == Orientation.portrait
                  ? 1 / mediaQuery.size.aspectRatio
                  : mediaQuery.size.aspectRatio,
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
            SizedBox(height: 8.0), ..._latestListBuilders.map(
                (SambazaLatestListBuilder builder) => Card(
                  child: Container(
                    child: SambazaLatestList(
                        builder: builder, title: builder.title),
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
          ],
        ),
        onRefresh: () => Future.microtask(
          () {
            User? user = $$<SambazaAuth>().user;
            if (user != null) {
              $$<SambazaStorage>()
                  .remove('${user.resource.endpoint}${user.id}/', false);
            }
            for (var config in _figuresConfigs) {
                $$<SambazaStorage>().remove(config.endpointWithParams, false);
              }
            for (var builder in _latestListBuilders) {
                $$<SambazaStorage>().remove(builder.resource.endpoint, false);
              }
          },
        ),
      );
}
