import 'package:flutter/widgets.dart';

import '../state_notifier.dart';
import '../state.dart';

mixin SambazaWidgetStateStateNotifier<T extends StatefulWidget> on SambazaStateNotifier, SambazaWidgetState<T> {

  @override
  void setState(void Function() callback) {
    notifyState();
    super.setState(callback);
  }

}