import 'package:flutter/material.dart';

import '../services/storage.dart';
import '../utils/configs/tab.dart';
import '../utils/injectable/widget.dart';

class SambazaTabBarView extends SambazaInjectableStatelessWidget {
  final List<SambazaTabConfig> configs;
  final TabController controller;
  @override
  final List<Type> $inject = <Type>[SambazaStorage];

  SambazaTabBarView({super.key, required this.configs, required this.controller});

  @override
  Widget template(BuildContext context) => TabBarView(
        controller: controller,
        children: configs
            .map<Widget>((SambazaTabConfig config) => RefreshIndicator(
                  child: ListView(
                    children: <Widget>[
                      config.listBuilder(context),
                    ],
                    padding: EdgeInsets.only(
                      bottom: 80,
                      top: 8,
                    ),
                  ),
                  onRefresh: () => Future.sync(() {
                    $$<SambazaStorage>().remove(config.endpoint);
                  }),
                ))
            .toList(),
      );
}
