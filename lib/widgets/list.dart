import 'package:flutter/material.dart';

import '../utils/configs/list_item.dart';

class SambazaList extends StatelessWidget {
  final Map<String, List<SambazaListItemConfig>> _groupedLists =
      <String, List<SambazaListItemConfig>>{};
  final List<SambazaListItemConfig> list;
  final List<SambazaListItemConfig> _list;
  final String groupBy;
  final int limit;
  final bool reverse;

  SambazaList(this.list, {this.groupBy, this.limit, this.reverse = false})
      : _list = (reverse ? list.reversed : list)
            .take(limit == null || limit > list.length ? list.length : limit)
            .toList() {
    if (groupBy != null) {
      _list.forEach((SambazaListItemConfig listItemConfig) {
        String groupKey = listItemConfig.group;
        _groupedLists.update(
            groupKey,
            (List<SambazaListItemConfig> current) =>
                current..add(listItemConfig),
            ifAbsent: () => <SambazaListItemConfig>[listItemConfig]);
      });
    }
  }

  @override
  Widget build(BuildContext context) => list.length > 0
      ? Column(
          children: groupBy == null
              ? _buildListItemsfromList(_list)
              : _groupedLists
                  .map<String, List<Widget>>(
                      (String key, List<SambazaListItemConfig> list) =>
                          MapEntry(
                              key,
                              <Widget>[
                                Text(
                                  key,
                                  style: Theme.of(context).textTheme.subtitle,
                                )
                              ]..addAll(_buildListItemsfromList(list))))
                  .values
                  .expand((List<Widget> list) => list)
                  .toList(),
        )
      : Center(
          child: Text(
            'No records here yet.',
            style: Theme.of(context).textTheme.overline,
          ),
        );

  List<_SambazaListItem> _buildListItemsfromList(
          List<SambazaListItemConfig> list) =>
      list.map<_SambazaListItem>(_buildListItem).toList();

  _SambazaListItem _buildListItem(SambazaListItemConfig listItemConfig) =>
      _SambazaListItem(listItemConfig);
}

class _SambazaListItem extends StatelessWidget {
  final SambazaListItemConfig config;

  _SambazaListItem(this.config)
      : assert(config.leading != null),
        assert(config.leading.length == 2),
        assert(config.subtitle != null),
        assert(config.subtitle.length > 0),
        assert(config.title != null);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return ListTile(
      leading: Container(
        child: Column(
          children: config.leading,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          color: themeData.primaryColor,
        ),
        height: 48.0,
        width: 48.0,
      ),
      subtitle: Row(
        children: List.generate(
                config.subtitle.length,
                (int index) => <Widget>[
                      Text(config.subtitle[index]),
                      SizedBox(width: 8.0),
                    ])
            .expand((List<Widget> pair) => pair)
            .take(config.subtitle.length * 2 - 1)
            .toList(),
      ),
      title: Text(config.title),
      trailing: config.trailing,
    );
  }
}
