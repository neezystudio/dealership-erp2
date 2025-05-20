import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../pages/all.dart';
import '../../resources.dart';
import '../../services/all.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class BranchOrdersPage extends SambazaPage {
  static String route = '/branch/orders';

  static BranchOrdersPage create(BuildContext context) => BranchOrdersPage();

  BranchOrdersPage({super.key}) : super(body: _BranchOrdersView(), title: 'Branch Orders');
}

class _BranchOrdersView extends SambazaInjectableStatelessWidget {
  @override
  final List<Type> $inject = <Type>[SambazaAuth, SambazaStorage];

  @override
  Widget template(BuildContext context) =>
      FutureBuilder<SambazaListBuilder<Order, SambazaModel>>(
        builder: (BuildContext context,
            AsyncSnapshot<SambazaListBuilder<Order, SambazaModel>> snapshot) {
          if (snapshot.hasData) {
            SambazaListBuilder<Order, SambazaModel> listBuilder = snapshot.data;
            String endpoint = SambazaAPIEndpoints.withParams(
                listBuilder.resource.endpoint, listBuilder.requestParams);
            return RefreshIndicator(
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: 80,
                  top: 8,
                ),
                children: <Widget>[
                  listBuilder(context),
                ],
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

  List<Widget> _buildLeading(Order order, [SambazaModel oI]) => <Widget>[
        Text(
          'Items',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
          ),
        ),
        Text(
          order.orderItems.length.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ];

  Widget _buildTrailing(Order order, [SambazaModel oI]) => GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.edit,
              color: Colors.cyan,
              semanticLabel: 'Edit the order',
            ),
            Text(
              'Edit',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 10,
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, EditOrderPage.route, arguments: order);
        },
      );

  Future<SambazaListBuilder<Order, SambazaModel>> _prepareBuilder() async =>
      SambazaListBuilder<Order, SambazaModel>(
        listItemConfigBuilder:
            SambazaListItemConfigBuilder<Order, SambazaModel>(
          group: (Order order, [SambazaModel oI]) =>
              SambazaListItemConfigBuilder.strFromTime(order.createdAt),
          leading: _buildLeading,
          subtitle: (Order order, [SambazaModel oI]) {
            DateTime time = order.createdAt;
            return <String>[
              'KES ${order.value.toInt().toString()}',
              'Placed at ${time.hour.toString()}:${time.minute.toString()}',
            ];
          },
          title: (Order order, [SambazaModel oI]) => "#${order.orderNumber}",
          trailing: _buildTrailing,
        ),
        modelFactory: ([Map<String, dynamic> fields]) => Order.create(fields),
        requestParams: <String, dynamic>{
          'branch': $$<SambazaAuth>().user.profile.branch,
        },
        resource: OrderResource(),
      );
}
