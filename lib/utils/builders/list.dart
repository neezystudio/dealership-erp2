import 'package:dealership_erp_sambaza_app/utils/exception.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../builders/list_item_config.dart';
import '../configs/list_item.dart';
import '../model.dart';
import '../resource.dart';
import '../../state.dart';
import '../../widgets/error.dart';
import '../../widgets/loader.dart';
import '../../widgets/list.dart';

class SambazaListBuilder<M extends SambazaModel, I extends SambazaModel> {
  final Future<SambazaModels<M>> Function() listFuture;
  final SambazaListItemConfigBuilder<M, I> listItemConfigBuilder;
  final String listName;
  final SambazaModelFactory<M> modelFactory;
  final Map<String, dynamic> requestParams;
  final SambazaResource resource;

  SambazaListBuilder({
    required this.listItemConfigBuilder,
    this.listName = '',
    required this.modelFactory,
    required this.requestParams,
    required this.resource,
  }) : listFuture =
           (() => SambazaModel.list<M>(resource, modelFactory, requestParams));

  List<SambazaListItemConfig<M, I>> addDisplay(M model) =>
      listName.isEmpty
          ? <SambazaListItemConfig<M, I>>[buildListItemConfig(model)()]
          : model
              .listFor<I>(listName)!
              .list
              .map<SambazaListItemConfig<M, I>>(
                (item) => buildListItemConfig(model)(item as I),
              )
              .toList();

  SambazaList buildList(List<M> models) => SambazaList(
    models
        .map<List<SambazaListItemConfig<M, I>>>(addDisplay)
        .expand<SambazaListItemConfig<M, I>>(
          (List<SambazaListItemConfig<M, I>> x) => x,
        )
        .toList(),
    groupBy: 'createdAt',
    limit: requestParams['limit'] ?? 20,
  );

  SambazaListItemConfig<M, I> Function([I]) buildListItemConfig(M model) =>
      ([I? listItem]) => SambazaListItemConfig<M, I>.from(
        listItemConfigBuilder,
        model,
        listItem as I,
      );

  Widget call(BuildContext context) => ScopedModelDescendant<SambazaState>(
    builder:
        (
          BuildContext context,
          Widget? child,
          SambazaState state,
        ) => FutureBuilder<SambazaModels<M>>(
          builder: (
            BuildContext context,
            AsyncSnapshot<SambazaModels<M>> snapshot,
          ) {
            if (snapshot.hasData) {
              return buildList(snapshot.data!.list);
            } else if (snapshot.hasError) {
              return SambazaError(
                SambazaException(
                  snapshot.error.toString(),
                  'Error loading ${resource.endpoint}',
                ),
                onButtonPressed: () {
                  // TODO: Implement error handling action, e.g., retry logic
                },
              );
            }
            return child ?? const SizedBox.shrink();
          },
          future: listFuture(),
        ),
    rebuildOnChange: true,
    child: SambazaLoader(),
  );
}
