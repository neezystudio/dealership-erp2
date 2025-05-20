import 'dart:async';
import 'package:flutter/material.dart';

import '../../builders/all.dart';
import '../../models/all.dart';
import '../../pages/create/all.dart';
import '../../resources.dart';
import '../../services/all.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class ServiceRequestsPage extends SambazaPage {
  static String route = '/branch/requests';

  static ServiceRequestsPage create(BuildContext context) =>
      ServiceRequestsPage(context);

  ServiceRequestsPage(BuildContext context)
      : super(
            body: _ServiceRequestsView(),
            fab: FloatingActionButton(
              child: Icon(
                Icons.playlist_add,
                semanticLabel: 'Make a new service request',
              ),
              onPressed: () {
                Navigator.pushNamed(context, CreateServiceRequestPage.route);
              },
            ),
            title: 'Service Requests');
}

class _ServiceRequestsView extends StatefulWidget {
  @override
  _ServiceRequestsViewState createState() => _ServiceRequestsViewState();
}

class _ServiceRequestsViewState extends SambazaInjectableWidgetState {
  @override
  final List<Type> $inject = <Type>[SambazaAuth, SambazaStorage];
  late SambazaListBuilder _listBuilder;

  @override
  void initState() {
    super.initState();
    _listBuilder = SambazaListBuilder<ServiceRequest, SambazaModel>(
      listItemConfigBuilder: SambazaServiceRequestListItemConfigBuilder(),
      modelFactory: ([Map<String, dynamic>? fields]) =>
          ServiceRequest.create(fields),
      requestParams: {'branch': $$<SambazaAuth>().user!.profile.branch},
      resource: ServiceRequestResource(),
    );
  }

  @override
  Widget template(BuildContext context) => RefreshIndicator(
        child: ListView(
          padding: EdgeInsets.only(
            bottom: 8,
            top: 8,
          ),
          scrollDirection: Axis.vertical,
          children: <Widget>[_listBuilder(context)],
        ),
        onRefresh: () => Future.sync(() {
          $$<SambazaStorage>().remove(_listBuilder.resource.endpoint);
        }),
      );
}
