import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../pages/all.dart';
import '../../resources.dart';
import '../../services/all.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class BranchLPOsPage extends SambazaPage {
  static String route = '/branch/lpos';

  static BranchLPOsPage create(BuildContext context) => BranchLPOsPage();

  BranchLPOsPage() : super(body: _BranchLPOsView(), title: 'Branch LPOs');
}

class _BranchLPOsView extends SambazaInjectableStatelessWidget {
  final List<Type> $inject = <Type>[SambazaAuth, SambazaStorage];

  @override
  Widget template(BuildContext context) =>
      FutureBuilder<SambazaListBuilder<LPO, SambazaModel>>(
        builder: (BuildContext context,
            AsyncSnapshot<SambazaListBuilder<LPO, SambazaModel>> snapshot) {
          if (snapshot.hasData) {
            SambazaListBuilder<LPO, SambazaModel> listBuilder = snapshot.data;
            String endpoint = SambazaAPIEndpoints.withParams(
                listBuilder.resource.endpoint, listBuilder.requestParams);
            return RefreshIndicator(
              child: ListView(
                children: <Widget>[
                  listBuilder(context),
                ],
                padding: EdgeInsets.only(
                  bottom: 80,
                  top: 8,
                ),
              ),
              onRefresh: () => Future.sync(() {
                $$<SambazaStorage>().remove(endpoint);
              }),
            );
          } else if (snapshot.hasError) {
            return SambazaError(snapshot.error);
          }
          return SambazaLoader('Loading...');
        },
        future: _prepareBuilder(),
      );

  List<Widget> _buildLeading(LPO lpo, [SambazaModel lI]) => <Widget>[
        Text(
          'Items',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
          ),
        ),
        Text(
          lpo.lpoItems.length.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ];

  Widget _buildTrailing(LPO lpo, [SambazaModel lI]) => GestureDetector(
        child: Column(
          children: <Widget>[
            Icon(
              Icons.view_list,
              color: Colors.cyan,
              semanticLabel: 'Edit the order',
            ),
            Text(
              'View',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 10,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        onTap: () {
          Navigator.pushNamed(context, LPOItemsPage.route,
              arguments: lpo);
        },
      );

  Future<SambazaListBuilder<LPO, SambazaModel>> _prepareBuilder() async =>
      SambazaListBuilder<LPO, SambazaModel>(
        listItemConfigBuilder: SambazaListItemConfigBuilder<LPO, SambazaModel>(
          group: (LPO lpo, [SambazaModel lI]) =>
              SambazaListItemConfigBuilder.strFromTime(lpo.createdAt),
          leading: _buildLeading,
          subtitle: (LPO lpo, [SambazaModel lI]) {
            DateTime time = lpo.createdAt;
            int value = lpo.lpoItems
                .map<num>((LPOItem lI) => lI.value)
                .reduce((num p, num c) => p + c)
                .toInt();
            return <String>[
              'KES ${value.toString()}',
              'Placed at ${time.hour.toString()}:${time.minute.toString()}',
            ];
          },
          title: (LPO lpo, [SambazaModel lI]) => "#${lpo.lpoNumber}",
          trailing: _buildTrailing,
        ),
        modelFactory: ([Map<String, dynamic> fields]) => LPO.create(fields),
        requestParams: <String, dynamic>{
          'branch': $$<SambazaAuth>().user.profile.branch,
        },
        resource: LPOResource(),
      );
}
