import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../pages/all.dart';
import '../../resources.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class LPOItemsPage extends SambazaPage {
  static String route = '/branch/lpos/items';

  static LPOItemsPage create(BuildContext context) => LPOItemsPage();

  LPOItemsPage({super.key})
      : super(
          body: _LPOItemsView(),
          title: 'LPO Items',
          fab: FloatingActionButton(
            onPressed: () {
              // TODO: Implement your action here
            },
          ), // Replace null with your desired FloatingActionButton if needed
        );
}

class _LPOItemsView extends StatefulWidget {
  @override
  _LPOItemsViewState createState() => _LPOItemsViewState();
}

class _LPOItemsViewState extends State<_LPOItemsView> {
  late LPO _lpo;
  late SambazaModels<Telco> _telcos;

  SambazaListItemConfigBuilder<LPOItem, SambazaModel>
      get _listItemConfigBuilder =>
          SambazaListItemConfigBuilder<LPOItem, SambazaModel>(
            group: (LPOItem lpoItem, [SambazaModel? lI]) =>
                SambazaListItemConfigBuilder.strFromTime(lpoItem.createdAt),
            leading: _buildLeading,
            subtitle: (LPOItem lpoItem, [SambazaModel? lI]) {
              DateTime time = lpoItem.createdAt;
              return <String>[
                'KES ${lpoItem.value.toString()}',
                'Placed at ${time.hour.toString()}:${time.minute.toString()}',
              ];
            },
            title: (LPOItem lpoItem, [SambazaModel? lI]) =>
                '${lpoItem.quantity.toInt().toString()} Cards',
            trailing: _buildTrailing,
          );

  @override
  Widget build(BuildContext context) => FutureBuilder<List<LPOItem>>(
        builder: (BuildContext context, AsyncSnapshot<List<LPOItem>> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              padding: EdgeInsets.only(
                bottom: 80,
                top: 8,
              ),
              children: <Widget>[
                _buildList(snapshot.data!),
              ],
            );
          } else if (snapshot.hasError) {
            return SambazaError(
              snapshot.error is SambazaException
                  ? snapshot.error as SambazaException
                  : SambazaException(snapshot.error.toString()), onButtonPressed: () {  },
            );
          }
          return SambazaLoader('Loading...');
        },
        future: _prepareItems(),
      );

  SambazaListItemConfig<LPOItem, SambazaModel> _addDisplay(LPOItem item) =>
      _buildListItemConfig(item);

  List<Widget> _buildLeading(LPOItem lpoItem, [SambazaModel? lI]) => <Widget>[
        Text(
          'Bamba',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
          ),
        ),
        Text(
          lpoItem.airtime.value.toInt().toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ];

  SambazaList _buildList(List<LPOItem> items) => SambazaList(
        items
            .map<SambazaListItemConfig<LPOItem, SambazaModel>>(_addDisplay)
            .toList(),
        groupBy: items.isNotEmpty
            ? SambazaListItemConfigBuilder.strFromTime(items.first.createdAt)
            : '',
        limit: items.length,
      );

  SambazaListItemConfig<LPOItem, SambazaModel> _buildListItemConfig(
          LPOItem item) =>
      SambazaListItemConfig<LPOItem, SambazaModel>.from(
          _listItemConfigBuilder, item);

  Widget _buildTrailing(LPOItem lpoItem, [SambazaModel? lI]) =>
      _lpo.status == LPOStatus.approved
          ? SizedBox(height: 8)
          : GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.assignment,
                    color: Colors.cyan,
                    semanticLabel: 'Assign serial numbers',
                  ),
                  Text(
                    'Assign Serial',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, AssignSerialsPage.route,
                    arguments: lpoItem);
              },
            );

  Future<SambazaModels<Telco>> _listTelcos() => SambazaModel.list<Telco>(
        TelcoResource(),
        ([Map<String, dynamic> fields = const {}]) => Telco.create(fields),
      );

  Future<List<LPOItem>> _prepareItems() async {
    _telcos = await _listTelcos();                                                                
    final modalRoute = ModalRoute.of(context);
    if (modalRoute?.settings.arguments is! LPO) {
      throw SambazaException('Expected LPO Items to be passed to this page.');
    }
    _lpo = modalRoute!.settings.arguments as LPO;
    return _lpo.lpoItems;
  }
}
