import 'package:flutter/material.dart';

import '../api.dart';
import '../builders/list.dart';
import '../injectable.dart';
import '../../services/storage.dart';

class SambazaTabConfig with SambazaInjectable {
  bool active;
  final bool hasFab;
  @override
  final List<Type> $inject = <Type>[SambazaStorage];
  final String label;
  final SambazaListBuilder listBuilder;
  final String redirectRoute;
  final String redirectRouteSuccessCallbackMessage;

  SambazaTabConfig({
    this.active = false,
    required this.hasFab,
    required this.label,
    required this.listBuilder,
    this.redirectRoute = '',
    this.redirectRouteSuccessCallbackMessage = '',
  }) {
    inject();
  }

  String get endpoint => SambazaAPIEndpoints.withParams(
      listBuilder.resource.endpoint, listBuilder.requestParams);

  void Function() onFabPressed(BuildContext context) => () {
        Navigator.pushNamed(
          context,
          redirectRoute,
        ).then(
          (Object? result) {
            if (result is Map<String, dynamic>) {
              Map<String, dynamic> newItem = Map<String, dynamic>.from(result);
              SambazaStorage $storage = $$<SambazaStorage>();
              if ($storage.has(endpoint)) {
                List<Map<String, dynamic>> items =
                    $storage.$get(endpoint);
                items[items.indexWhere(
                  (Map<String, dynamic> item) => item['id'] == newItem['id'],
                )] = newItem;
                $storage.$set(
                  endpoint,
                  items,
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: <Widget>[
                      Text('DONE'),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(redirectRouteSuccessCallbackMessage),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      };
}
