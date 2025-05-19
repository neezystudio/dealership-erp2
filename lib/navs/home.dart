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
  final bool hasFab = true;
  final IconData icon = Icons.home;
  final List<Type> $inject = <Type>[SambazaStorage];
  final String label = 'Home tab';
  final Widget view = _HomeNavView();
  final String title = 'Home';

  HomeNav() {
    inject();
  }

  void Function() onFabPressed(BuildContext context) => () {
        Navigator.pushNamed(
          context,
          CreateSalePage.route,
        ).then(
          (Object result) {
            if (result != null) {
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
              Scaffold.of(context).showSnackBar(
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
              DSADispatchItem dispatchItem,
            ]) {
              dispatchItem.serialFirst ??= 0;
              dispatchItem.serialLast ??= 0;
              return <String>[
                '${DSADispatchItem.serialFormatter(dispatchItem.serialFirst)} - ${DSADispatchItem.serialFormatter(dispatchItem.serialLast)}',
              ];
            },
            title: (
              DSADispatch dispatch, [
              DSADispatchItem dispatchItem,
            ]) =>
                '${dispatchItem.quantity.toString()} Cards - ${dispatchItem.value.toInt().toString()}/=',
          ),
          listName: 'dispatch_items',
          modelFactory: ([
            Map<String, dynamic> fields,
          ]) =>
              DSADispatch.create(fields),
          resource: DSADispatchResource(),
          title: 'Latest Dispatches',
        ),
        SambazaLatestListBuilder<Sale, SaleItem>(
          listItemConfigBuilder: SambazaSaleListItemConfigBuilder(),
          listName: 'sale_items',
          modelFactory: ([
            Map<String, dynamic> fields,
          ]) =>
              Sale.create(fields),
          resource: SaleResource(),
          title: 'Latest Sales',
        ),
      ];

  @override
  Widget template(BuildContext context) => RefreshIndicator(
        child: ListView(
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
              physics: new NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
            SizedBox(height: 8.0),
          ]..addAll(
              _latestListBuilders.map(
                (SambazaLatestListBuilder builder) => Card(
                  child: Container(
                    child: SambazaLatestList(
                        builder: builder, title: builder.title),
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          padding: EdgeInsets.fromLTRB(8, 8, 8, 80),
        ),
        onRefresh: () => Future.microtask(
          () {
            User user = $$<SambazaAuth>().user;
            $$<SambazaStorage>()
                .remove('${user.resource.endpoint}${user.id}/', false);
            _figuresConfigs.forEach(
              (SambazaFiguresConfig config) {
                $$<SambazaStorage>().remove(config.endpointWithParams, false);
              },
            );
            _latestListBuilders.forEach(
              (SambazaLatestListBuilder builder) {
                $$<SambazaStorage>().remove(builder.resource.endpoint, false);
              },
            );
          },
        ),
      );
}
