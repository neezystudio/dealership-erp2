import 'dart:async';
import 'package:flutter/material.dart';

import '../create/all.dart';
import '../../builders/all.dart';
import '../../models/all.dart';
import '../../resources.dart';
import '../../services/all.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class BranchStockTransfersPage extends SambazaPage with SambazaInjectable {
  static String route = '/branch/transfers';

  BranchStockTransfersPage(
    BuildContext context, {super.key}
  ) : super(
          body: _BranchStockTransfersView(),
          fab: FloatingActionButton(
            child: Icon(
              Icons.swap_horiz,
              semanticLabel: 'Add new stock transfer',
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                CreateStockTransferPage.route,
              );
            },
          ),
          title: 'Stock Transfers',
        );

  static BranchStockTransfersPage create(
    BuildContext context,
  ) =>
      BranchStockTransfersPage(
        context,
      );
}

class _BranchStockTransfersView extends StatefulWidget {
  @override
  _BranchStockTransfersViewState createState() =>
      _BranchStockTransfersViewState();
}

class _BranchStockTransfersViewState extends SambazaInjectableWidgetState {
  @override
  final List<Type> $inject = <Type>[
    SambazaAuth,
    SambazaStorage,
  ];
  late SambazaListBuilder _listBuilder;

  @override
  void initState() {
    super.initState();
    _listBuilder = SambazaListBuilder<StockTransfer, SambazaModel>(
      listItemConfigBuilder: SambazaStockTransferListItemConfigBuilder(
        $$<SambazaAuth>().user!.profile.branch,
      ),
      modelFactory: ([
        Map<String, dynamic>? fields,
      ]) =>
          StockTransfer.create(
        fields,
      ),
      requestParams: {
        'branch': $$<SambazaAuth>().user!.profile.branch,
      },
      resource: StockTransferResource(),
    );
  }

  @override
  Widget template(
    BuildContext context,
  ) =>
      RefreshIndicator(
        child: ListView(
          padding: EdgeInsets.only(
            bottom: 8,
            top: 8,
          ),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            _listBuilder(context),
          ],
        ),
        onRefresh: () => Future.sync(
          () {
            $$<SambazaStorage>().remove(
              _listBuilder.resource.endpoint,
            );
          },
        ),
      );
}
