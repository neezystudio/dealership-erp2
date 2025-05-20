import 'package:flutter/material.dart';

import 'loader.dart';
import '../services/api.dart';
import '../services/storage.dart';
import '../utils/configs/figures.dart';
import '../utils/injectable/widget.dart';

class SambazaFiguresCard extends SambazaInjectableStatelessWidget {
  final SambazaFiguresConfig config;
  final List<Type> $inject = <Type>[SambazaAPI, SambazaStorage];

  SambazaFiguresCard(this.config);

  ThemeData get _themeData => Theme.of(context);

  Future<double> _getFigures() async {
    if ($$<SambazaStorage>().has(config.endpointWithParams)) {
      return $$<SambazaStorage>().$get(config.endpointWithParams);
    }
    String result =
        await $$<SambazaAPI>().fetch(config.endpoint, config.params);
    double figure = num.parse(result).toDouble();
    $$<SambazaStorage>().cache(config.endpointWithParams, figure);
    return figure;
  }

  @override
  Widget template(BuildContext context) => Card(
        child: FutureBuilder<double>(
          builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  SizedBox(height: 8),
                  Text(
                    config.title,
                    style: _themeData.textTheme.bodySmall,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'KES ${snapshot.data.toString()}',
                    style: _themeData.textTheme.headlineMedium,
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Icon(
                Icons.error,
                semanticLabel: 'Error retrieving figures',
                size: 48.0,
              );
            }
            return SambazaLoader('Loading figures');
          },
          future: _getFigures(),
        ),
      );
}
