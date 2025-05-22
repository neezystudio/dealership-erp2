import 'package:flutter/material.dart';

import '../pages/branch/all.dart';
import '../services/all.dart';
import '../utils/all.dart';
import '../widgets/all.dart';

class BranchNav implements SambazaNav {
  @override
  final bool hasFab = false;
  @override
  final IconData icon = Icons.business;
  @override
  final String label = 'Branch tab';
  @override
  final _BranchNavView view = _BranchNavView();
  @override
  final String title = 'Branch';

  @override
  void Function() onFabPressed(BuildContext context) => () {};
}

class _BranchNavView extends SambazaInjectableStatelessWidget {
  final List<SambazaFiguresConfig> _figuresConfigs = <SambazaFiguresConfig>[
    SambazaFiguresConfig(
      'Sales',
      SambazaAPIEndpoints.sales('/total/'),
      SambazaFiguresPeriod.daily,
      <String, dynamic>{'branch': true},
    ),
    SambazaFiguresConfig(
      'Sales',
      SambazaAPIEndpoints.sales('/total/'),
      SambazaFiguresPeriod.monthly,
      <String, dynamic>{'branch': true},
    ),
    SambazaFiguresConfig(
      'Commission',
      SambazaAPIEndpoints.sales('/total-commission/'),
      SambazaFiguresPeriod.daily,
      <String, dynamic>{'branch': true},
    ),
    SambazaFiguresConfig(
      'Commission',
      SambazaAPIEndpoints.sales('/total-commission/'),
      SambazaFiguresPeriod.monthly,
      <String, dynamic>{'branch': true},
    ),
  ];
  final List<_BranchManagementCard> _menu = <_BranchManagementCard>[
    _BranchManagementCard(
      icon: Icons.store,
      route: BranchInventoryPage.route,
      title: 'Inventory',
    ),
    _BranchManagementCard(
      icon: Icons.playlist_add_check,
      route: ServiceRequestsPage.route,
      title: 'Service requests',
    ),
    _BranchManagementCard(
      icon: Icons.local_shipping,
      route: BranchDispatchPage.route,
      title: 'Dispatch',
    ),
    _BranchManagementCard(
      icon: Icons.swap_horizontal_circle,
      route: BranchStockTransfersPage.route,
      title: 'Stock Transfers',
    ),
    _BranchManagementCard(
      icon: Icons.shopping_cart,
      route: BranchOrdersPage.route,
      title: 'Orders',
    ),
    _BranchManagementCard(
      icon: Icons.assignment,
      route: BranchLPOsPage.route,
      title: 'LPOs',
    ),
  ];
  @override
  final List<Type> $inject = <Type>[SambazaStorage];

  MediaQueryData get mediaQuery => MediaQuery.of(context);

  @override
  Widget template(BuildContext context) => RefreshIndicator(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            GridView.count(
              childAspectRatio: mediaQuery.orientation == Orientation.portrait ? 1 / mediaQuery.size.aspectRatio : mediaQuery.size.aspectRatio,
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              padding: EdgeInsets.all(4),
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              shrinkWrap: true,
              children: _figuresConfigs
                  .map<Widget>(
                    (SambazaFiguresConfig c) => SambazaFiguresCard(c),
                  )
                  .toList(),
            ),
            SizedBox(height: 8.0),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              padding: EdgeInsets.all(4),
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              shrinkWrap: true,
              children: _menu,
            ),
          ],
        ),
        onRefresh: () => Future.microtask(() {
          for (var config in _figuresConfigs) {
            $$<SambazaStorage>().remove(config.endpointWithParams, false);
          }
        }),
      );
}

class _BranchManagementCard extends StatelessWidget {
  final IconData icon;
  final String route;
  final String title;

  const _BranchManagementCard({required this.icon, required this.route, required this.title});

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Card(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              semanticLabel: title,
              size: 48,
            ),
            Text(title),
          ],
        )),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      );
}
