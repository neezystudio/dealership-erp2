import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'app.dart';
import 'login.dart';
import '../services/all.dart';
import '../state.dart';
import '../utils/all.dart';
import '../widgets/error.dart';

class RootPage extends StatefulWidget {
  static String route = '/';

  static RootPage create(BuildContext context) => RootPage();

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends SambazaInjectableWidgetState<RootPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Type> $inject = <Type>[SambazaAuth, SambazaStorage];

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    print("onBackgroundMessage: $message");
    if (message.containsKey('data')) {
      // Handle data message
      //  final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      //  final dynamic notification = message['notification'];
    }

    // Or do other work.
    return Future.value('Done');
  }

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  @override
  Widget template(BuildContext context) => FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<SambazaState> snapshot) {
          if (snapshot.hasData) {
            if ($$<SambazaAuth>().token.isNotEmpty) {
              return AppPage();
            } else {
              return LoginPage();
            }
          } else if (snapshot.hasError) {
            return SambazaError(snapshot.error);
          }

          return Container(
            child: Column(
              children: <Widget>[
                Image(
                  image: AssetImage('assets/images/logo.png'),
                ),
                SizedBox(height: 8.0),
                CircularProgressIndicator(),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.overlay,
              color: Theme.of(context).backgroundColor,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/doodles.png'),
              ),
            ),
          );
        },
        future: Future.microtask(_stateReady),
      );

  Future<SambazaState> _stateReady() async {
    if (!$$<SambazaStorage>().has(SambazaState.FCM_TOKEN_STORAGE_KEY)) {
      $$<SambazaStorage>().$set(
          SambazaState.FCM_TOKEN_STORAGE_KEY, await _firebaseMessaging.getToken());
    }
    return state.ready();
  }
}
