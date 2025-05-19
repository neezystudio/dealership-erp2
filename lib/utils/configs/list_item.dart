import 'package:flutter/widgets.dart';

import '../builders/list_item_config.dart';
import '../../utils/model.dart';

class SambazaListItemConfig<M extends SambazaModel, I extends SambazaModel> {
  final String group;
  final List<Widget> leading;
  final List<String> subtitle;
  final String title;
  final Widget trailing;

  SambazaListItemConfig({
    this.group = '',
    @required this.leading,
    @required this.subtitle,
    @required this.title,
    this.trailing,
  });

  SambazaListItemConfig.from(
      SambazaListItemConfigBuilder<M, I> builder, M model,
      [I listItem])
      : this(
          group: builder.group(model, listItem),
          leading: builder.leading(model, listItem),
          subtitle: builder.subtitle(model, listItem),
          title: builder.title(model, listItem),
          trailing: builder.trailing(model, listItem),
        );
}
