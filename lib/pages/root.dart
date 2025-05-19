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
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final List<Type> $inject = <Type>[SambazaAuth, SambazaStorage];

  static Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
    print("onBackgroundMessage: ${message.data}");

    if (message.data.isNotEmpty) {
      // Handle data message here
    }

    if (message.notification != null) {
      print('Notification Title: ${message.notification!.title}');
      print('Notification Body: ${message.notification!.body}');
    }
  }

  @override
  void initState() {
    super.initState();

    _requestPermissions();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.data}");
      if (message.notification != null) {
        print("Notification Title: ${message.notification!.title}");
        print("Notification Body: ${message.notification!.body}");
      }
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("onLaunch: ${message.data}");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: ${message.data}");
    });
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  @override
  Widget template(BuildContext context) => FutureBuilder<SambazaState>(
        future: Future.microtask(_stateReady),
        builder: (BuildContext context, AsyncSnapshot<SambazaState> snapshot) {
          if (snapshot.hasData) {
            if ($$<SambazaAuth>().token.isNotEmpty) {
              return AppPage();
            } else {
              return LoginPage();
            }
          } else if (snapshot.hasError) {
            final error = snapshot.error;
            if (error is SambazaException) {
              return SambazaError(error);
            } else {
              return SambazaError(SambazaException(error?.toString() ?? 'Unknown error'));
            }
          }

          return Container(
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.overlay,
              color: Theme.of(context).primaryColor,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/doodles.png'),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage('assets/images/logo.png'),
                ),
                SizedBox(height: 8.0),
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      );

  Future<SambazaState> _stateReady() async {
    if (!$$<SambazaStorage>().has(SambazaState.FCM_TOKEN_STORAGE_KEY)) {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        $$<SambazaStorage>().$set(SambazaState.FCM_TOKEN_STORAGE_KEY, token);
      }
    }
    return state.ready();
  }
}
