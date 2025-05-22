import 'package:flutter/material.dart';

import 'list.dart';
import '../configs/list_item.dart';
import '../model.dart';
import '../../widgets/list.dart';

class SambazaLatestListBuilder<M extends SambazaModel, I extends SambazaModel>
    extends SambazaListBuilder<M, I> {
  final String title;

  SambazaLatestListBuilder({
    required super.listItemConfigBuilder,
    required super.listName,
    required super.modelFactory,
    required super.requestParams,
    required super.resource,
    required this.title,
  });

  @override
  SambazaList buildList(List<M> models) => SambazaList(
        models
            .map<List<SambazaListItemConfig<M, I>>>(addDisplay)
            .expand<SambazaListItemConfig<M, I>>(
                (List<SambazaListItemConfig<M, I>> x) => x)
            .toList(),
        groupBy: 'createdAt',
        limit: 10,
      );

  Widget buildTitle(BuildContext context) => Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      );
}
