import 'package:flutter/material.dart';

import '../api.dart';
import '../builders/list.dart';
import '../injectable.dart';
import '../../services/storage.dart';

class SambazaTabConfig with SambazaInjectable {
  bool active;
  final bool hasFab;
  final List<Type> $inject = <Type>[SambazaStorage];
  final String label;
  final SambazaListBuilder listBuilder;
  final String redirectRoute;
  final String redirectRouteSuccessCallbackMessage;

  SambazaTabConfig({
    this.active = false,
    @required this.hasFab,
    @required this.label,
    @required this.listBuilder,
    this.redirectRoute = '',
    this.redirectRouteSuccessCallbackMessage = '',
  }) {
    inject();
  }

  String get endpoint => SambazaAPIEndpoints.withParams(
      listBuilder.resource.endpoint, listBuilder.requestParams);

  void Function() onFabPressed(BuildContext context) => () {
        Navigator.pushNamed(context, redirectRoute).then((Object result) {
          if (result != null) {
            if ($$<SambazaStorage>().has(endpoint)) {
              Map<String, dynamic> stored = Map<String, dynamic>.from(
                  $$<SambazaStorage>().$get(endpoint));
              List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(stored['results'], growable: true,);
              results.add(result);
              stored['results'] = results;
              $$<SambazaStorage>().$set(endpoint, stored);
            }
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Row(
                children: <Widget>[
                  Text('DONE'),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(redirectRouteSuccessCallbackMessage),
                  ),
                ],
              ),
            ));
          }
        });
      };
}
