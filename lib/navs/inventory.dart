import 'package:flutter/material.dart';

import '../builders/all.dart';
import '../models/all.dart';
import '../resources.dart';
import '../services/all.dart';
import '../utils/all.dart';
import '../widgets/all.dart';

class InventoryNav implements SambazaNav {
  final bool hasFab = false;
  final IconData icon = Icons.store_mall_directory;
  final String label = 'Inventory tab';
  final _InventoryNavView view = _InventoryNavView();
  final String title = 'Inventory';

  void Function() onFabPressed(
    BuildContext context,
  ) =>
      () {};
}

class _InventoryNavView extends StatefulWidget with SambazaInjectable {
  final List<Type> $inject = <Type>[
    SambazaAuth,
  ];
  final List<SambazaTabConfig> tabConfigs = <SambazaTabConfig>[];

  _InventoryNavView() {
    inject();
    tabConfigs.addAll(
      <SambazaTabConfig>[
        SambazaTabConfig(
          active: true,
          hasFab: false,
          listBuilder: SambazaListBuilder<DSAInventory, SambazaModel>(
            listItemConfigBuilder: SambazaInventoryListItemConfigBuilder(),
            modelFactory: ([Map<String, dynamic> fields]) =>
                DSAInventory.create(fields),
            resource: DSAInventoryResource(),
          ),
          label: 'Inventory',
        ),
        SambazaTabConfig(
          hasFab: false,
          listBuilder: SambazaListBuilder<StockTransfer, SambazaModel>(
            listItemConfigBuilder: SambazaStockTransferListItemConfigBuilder(
              $$<SambazaAuth>().user.id,
            ),
            modelFactory: ([Map<String, dynamic> fields]) =>
                StockTransfer.create(fields),
            resource: StockTransferResource(),
          ),
          label: 'Stock Transfers',
        ),
      ],
    );
  }

  SambazaTabConfig get activeTabConfig => tabConfigs.firstWhere(
        (SambazaTabConfig config) => config.active,
        orElse: () => tabConfigs[0],
      );

  bool get hasFab => activeTabConfig.hasFab;

  @override
  _InventoryNavViewState createState() => _InventoryNavViewState();

  void Function() onFabPressed(
    BuildContext context,
  ) =>
      activeTabConfig.onFabPressed(
        context,
      );
}

class _InventoryNavViewState extends SambazaWidgetState<_InventoryNavView>
    with
        SingleTickerProviderStateMixin,
        SambazaStateNotifier,
        SambazaWidgetStateStateNotifier {
  TabController _tabController;

  @override
  Widget template(
    BuildContext context,
  ) =>
      Column(
        children: <Widget>[
          Container(
            child: SambazaTabBar(
              configs: widget.tabConfigs,
              controller: _tabController,
            ),
            color: Colors.cyanAccent,
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
    _tabController.addListener(
      _onTabChanged,
    );
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
