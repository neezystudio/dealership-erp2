import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'login.dart';
import '../models/telco.dart';
import '../navs/all.dart';
import '../resources.dart';
import '../services/all.dart';
import '../state.dart';
import '../utils/all.dart';
import '../widgets/all.dart';

class AppPage extends StatefulWidget {
  static String route = '/app ';

  const AppPage({super.key});

  static AppPage create(BuildContext context) => AppPage();

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends SambazaInjectableWidgetState<AppPage> {
  int _currentIndex = 0;
  final List<SambazaNav> _navs = <SambazaNav>[
    HomeNav(),
    BankingNav(),
    OrdersNav(),
    InventoryNav(),
  ];
  @override
  List<Type> $inject = <Type>[SambazaAPI, SambazaAuth, SambazaStorage];

  @override
  initState() {
    super.initState();
    if ($$<SambazaAuth>().user!.role == SambazaAuthRole.branch_admin) {
      _navs.add(BranchNav());
    }
  }

  @override
  Widget template(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: <Widget>[
        PopupMenuButton<int>(
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<int>>[
                PopupMenuItem<int>(
                  value: 0,
                  child: ListTile(
                    leading: Icon(
                      Icons.power_settings_new,
                      semanticLabel: 'Log Out',
                    ),
                    title: Text('Log Out'),
                  ),
                ),
              ],
          onSelected: (int value) {
            if (value == 0) {
              $$<SambazaAPI>()
                  .send(
                    SambazaAPIEndpoints.accounts('/logout/'),
                    <String, dynamic>{},
                  )
                  .then((dynamic result) {
                    $$<SambazaAuth>().clear();
                    String fcmToken = $$<SambazaStorage>().$get(
                      SambazaState.FCM_TOKEN_STORAGE_KEY,
                    );
                    $$<SambazaStorage>().clear();
                    $$<SambazaStorage>().$set(
                      SambazaState.FCM_TOKEN_STORAGE_KEY,
                      fcmToken,
                    );
                    Navigator.pushReplacementNamed(context, LoginPage.route);
                  })
                  .catchError((e) {
                    print(e);
                  });
            }
          },
          tooltip: 'More actions',
        ),
      ],
      title: Text(
        _navs[_currentIndex].title,
        style: Theme.of(context).primaryTextTheme.titleLarge,
      ),
    ),
    body: FutureBuilder<SambazaModels<Telco>>(
      builder: (
        BuildContext context,
        AsyncSnapshot<SambazaModels<Telco>> snapshot,
      ) {
        if (snapshot.hasData) {
          return _navs[_currentIndex].view;
        } else if (snapshot.hasError) {}
        return SambazaLoader();
      },
      future: SambazaModel.list<Telco>(
        TelcoResource(),
        ([Map<String, dynamic>? f]) => Telco.create(f!),
      ),
    ),
    bottomNavigationBar: SambazaNavBar(
      activeIndex: _currentIndex,
      navs: _navs,
      onTap: (int newIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      },
    ),
    floatingActionButton: ScopedModelDescendant<SambazaState>(
      builder: (BuildContext context, Widget? child, SambazaState state) {
        return _navs[_currentIndex].hasFab
            ? FloatingActionButton(
              onPressed: _navs[_currentIndex].onFabPressed(context),
              child: Icon(
                Icons.add,
                semanticLabel: 'Add new ${_navs[_currentIndex].title}',
              ),
            )
            : Container();
      },
      rebuildOnChange: true,
    ),
  );
}
