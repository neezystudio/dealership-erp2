import 'package:flutter/material.dart';
import 'package:sambaza/widgets/tab_bar.dart';

import '../builders/all.dart';
import '../models/all.dart';
import '../services/all.dart';
import '../pages/all.dart';
import '../resources.dart';
import '../utils/all.dart';
import '../widgets/all.dart';

class BankingNav implements SambazaNav {
  @override
  final IconData icon = Icons.monetization_on;
  @override
  final String label = 'Banking tab';
  @override
  final _BankingNavView view = _BankingNavView();
  @override
  final String title = 'Banking';

  @override
  bool get hasFab => view.hasFab;

  @override
  void Function() onFabPressed(BuildContext context) =>
      view.onFabPressed(context);
}

class _BankingNavView extends StatefulWidget {
  final List<SambazaTabConfig> tabConfigs = <SambazaTabConfig>[
    SambazaTabConfig(
      hasFab: false,
      listBuilder: SambazaListBuilder<Rollup, SambazaModel>(
        listItemConfigBuilder: SambazaRollupListItemConfigBuilder(),
        listName: '',
        modelFactory: ([Map<String, dynamic>? fields]) => Rollup.create(fields!),
        resource: RollupResource(),
      ),
      label: 'Rollups',
    ),
    SambazaTabConfig(
      active: true,
      hasFab: true,
      listBuilder: SambazaListBuilder<Sale, SaleItem>(
        listItemConfigBuilder: SambazaSaleListItemConfigBuilder(),
        listName: 'sale_items',
        modelFactory: ([Map<String, dynamic>? fields]) => Sale.create(fields!),
        resource: SaleResource(),
      ),
      label: 'Sales',
      redirectRoute: CreateSalePage.route,
      redirectRouteSuccessCallbackMessage:
          'Your sale was created successfully!',
    ),
    SambazaTabConfig(
      hasFab: true,
      listBuilder: SambazaListBuilder<Transaction, SambazaModel>(
        listItemConfigBuilder: SambazaTransactionListItemConfigBuilder(),
        listName: '',
        modelFactory: ([Map<String, dynamic>? fields]) =>
            Transaction.create(fields!),
        resource: TransactionResource(),
      ),
      label: 'Transactions',
      redirectRoute: CreateTransactionPage.route,
      redirectRouteSuccessCallbackMessage:
          'The transaction was created successfully!',
    ),
  ];

  SambazaTabConfig get activeTabConfig =>
      tabConfigs.firstWhere((SambazaTabConfig config) => config.active,
          orElse: () => tabConfigs[0]);

  bool get hasFab => activeTabConfig.hasFab;

  @override
  _BankingNavViewState createState() => _BankingNavViewState();

  void Function() onFabPressed(BuildContext context) =>
      activeTabConfig.onFabPressed(context);
}

class _BankingNavViewState extends SambazaInjectableWidgetState<_BankingNavView>
    with
        SingleTickerProviderStateMixin,
        SambazaStateNotifier,
        SambazaWidgetStateStateNotifier {
  @override
  final List<Type> $inject = <Type>[SambazaAPI, SambazaStorage];
  late TabController _tabController;

  @override
  Widget template(BuildContext context) => Column(
        children: <Widget>[
          Container(
            color: Colors.cyanAccent,
            child: SambazaTabBar(
                configs: widget.tabConfigs, controller: _tabController),
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
      initialIndex: widget.tabConfigs
          .indexWhere((SambazaTabConfig config) => config.active),
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
