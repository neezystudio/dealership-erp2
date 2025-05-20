import 'package:flutter/material.dart';

import '../builders/all.dart';
import '../models/all.dart';
import '../pages/all.dart';
import '../resources.dart';
import '../utils/all.dart';
import '../widgets/all.dart';

class OrdersNav implements SambazaNav {
  @override
  final IconData icon = Icons.local_shipping;
  @override
  final String label = 'Orders tab';
  @override
  final _OrdersNavView view = _OrdersNavView();
  @override
  final String title = 'Ordering';

  @override
  bool get hasFab => view.hasFab;

  @override
  void Function() onFabPressed(BuildContext context) =>
      view.onFabPressed(context);
}

class _OrdersNavView extends StatefulWidget {
  final List<SambazaTabConfig> tabConfigs = <SambazaTabConfig>[
    SambazaTabConfig(
      hasFab: false,
      listBuilder: SambazaListBuilder<DSADispatch, DSADispatchItem>(
        listItemConfigBuilder: SambazaDispatchListItemConfigBuilder<
          DSADispatch,
          DSADispatchItem
        >(
          subtitle: (DSADispatch dispatch, [DSADispatchItem? dispatchItem]) {
            dispatchItem!.serialFirst ??= 0;
            dispatchItem!.serialLast ??= 0;
            return <String>[
              '${DSADispatchItem.serialFormatter(dispatchItem.serialFirst)} - ${DSADispatchItem.serialFormatter(dispatchItem.serialLast)}',
            ];
          },
          title:
              (DSADispatch dispatch, [DSADispatchItem? dispatchItem]) =>
                  '${dispatchItem!.quantity.toString()} Cards - ${dispatchItem.value.toInt().toString()}/=',
        ),
        listName: 'dispatch_items',
        modelFactory:
            ([Map<String, dynamic>? fields]) => DSADispatch.create(fields),
        resource: DSADispatchResource(),
        requestParams: {},
      ),
      label: 'Dispatch',
    ),
    SambazaTabConfig(
      active: true,
      hasFab: true,
      listBuilder: SambazaListBuilder<Order, OrderItem>(
        listItemConfigBuilder: SambazaOrderListItemConfigBuilder(),
        listName: 'order_items',
        modelFactory: ([Map<String, dynamic>? fields]) => Order.create(fields!),
        resource: OrderResource(),
        requestParams: {},
      ),
      label: 'Orders',
      redirectRoute: CreateOrderPage.route,
      redirectRouteSuccessCallbackMessage:
          'Your order has been placed and is awaiting approval.',
    ),
  ];

  SambazaTabConfig get activeTabConfig => tabConfigs.firstWhere(
    (SambazaTabConfig config) => config.active,
    orElse: () => tabConfigs[0],
  );

  bool get hasFab => activeTabConfig.hasFab;

  @override
  _OrdersNavViewState createState() => _OrdersNavViewState();

  void Function() onFabPressed(BuildContext context) =>
      activeTabConfig.onFabPressed(context);
}

class _OrdersNavViewState extends SambazaWidgetState<_OrdersNavView>
    with
        SingleTickerProviderStateMixin,
        SambazaStateNotifier,
        SambazaWidgetStateStateNotifier {
  late TabController _tabController;

  @override
  Widget template(BuildContext context) => Column(
    children: <Widget>[
      Container(
        color: Colors.cyanAccent,
        child: SambazaTabBar(
          configs: widget.tabConfigs,
          controller: _tabController,
        ),
      ),
      Expanded(
        child: SambazaTabBarView(
          configs: widget.tabConfigs,
          controller: _tabController,
        ),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget.tabConfigs.indexWhere(
        (SambazaTabConfig config) => config.active,
      ),
      length: widget.tabConfigs.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    widget.tabConfigs[_tabController.previousIndex].active = false;
    widget.tabConfigs[_tabController.index].active = true;
    notifyState();
  }
}
