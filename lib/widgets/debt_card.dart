import 'package:flutter/material.dart';

import 'loader.dart';
import '../models/debt.dart';
import '../models/user.dart';
import '../services/auth.dart';
import '../utils/injectable/widget.dart';

class SambazaDebtCard extends SambazaInjectableStatelessWidget {
  final List<Type> $inject = <Type>[SambazaAuth];

  ThemeData get _themeData => Theme.of(context);

  Future<User> _getUser() async {
    User user = $$<SambazaAuth>().user;
    await user.pull();
    return user;
  }

  @override
  Widget template(BuildContext context) => Card(
        child: FutureBuilder<User>(
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.hasData) {
              Debt debt = snapshot.data.debt;
              bool debtIsBad = debt.percentage > 0.2;
              return Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor:
                        debtIsBad ? Colors.red[100] : Colors.cyan[100],
                    child: Icon(
                      debtIsBad
                          ? Icons.info_outline
                          : Icons.check_circle_outline,
                      color: debtIsBad
                          ? _themeData.errorColor
                          : _themeData.primaryColor,
                      semanticLabel:
                          debtIsBad ? 'Bad debt level' : 'Good debt level',
                    ),
                  ),
                  SizedBox(height: 72, width: 16),
                  Text(
                    'Debt:',
                    style: _themeData.textTheme.body2,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'KES ${debt.value.toString()}',
                    style: _themeData.textTheme.display1,
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Icon(
                Icons.error,
                semanticLabel: 'Error retrieving count',
                size: 48.0,
              );
            }
            return Padding(
              child: SambazaLoader('Loading debt'),
              padding: EdgeInsets.symmetric(vertical: 4),
            );
          },
          future: _getUser(),
        ),
      );
}
