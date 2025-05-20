import 'package:flutter/material.dart';

import '../services/all.dart';
import '../pages/all.dart';
import '../utils/all.dart';

class SambazaError extends SambazaInjectableStatelessWidget {
  final List<Type> $inject = <Type>[SambazaAuth, SambazaStorage];
  final SambazaException exception;
  final void Function() onButtonPressed;

  SambazaError(this.exception, {required this.onButtonPressed});

  void _logout() {
    $$<SambazaAuth>().clear();
    $$<SambazaStorage>().clear();
    Navigator.pushNamed(context, LoginPage.route, arguments: true);
  }

  @override
  Widget template(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    void Function() onPressed = onButtonPressed;
    try {
      throw exception;
    } on SambazaAPIException catch (e) {
      if (e.code == 401) {
        onPressed = _logout;
      }
    } catch (e) {
      print(e);
    }
    return Column(
      children: <Widget>[
        Icon(
          Icons.error,
          color: themeData.indicatorColor,
          semanticLabel: 'Error',
          size: themeData.iconTheme.size,
        ),
        Text(exception.title, style: themeData.textTheme.headlineMedium),
        Text(exception.message, style: themeData.textTheme.labelMedium),
        OutlinedButton(
          child: Text(
            'OK',
            style: TextStyle(
              color: Colors.black87,
              inherit: true,
            ).merge(themeData.textTheme.labelLarge),
          ),

          onPressed: onPressed,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
    );
  }
}
