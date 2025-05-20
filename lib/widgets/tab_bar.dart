import 'package:flutter/material.dart';

import '../utils/configs/tab.dart';

class SambazaTabBar extends StatelessWidget {
  final List<SambazaTabConfig> configs;
  final TabController controller;

  SambazaTabBar({required this.configs, required this.controller});

  @override
  Widget build(BuildContext context) => TabBar(
        controller: controller,
        indicator: Theme.of(context).tabBarTheme.indicator,
        labelColor: Colors.black87,
        labelPadding: EdgeInsets.only(bottom: 16, top: 16),
        tabs: configs
            .map<Widget>((SambazaTabConfig config) => Text(config.label))
            .toList(),
      );
}
