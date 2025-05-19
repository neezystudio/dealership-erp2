import 'package:flutter/widgets.dart';

import '../injectable.dart';
import '../state.dart';

abstract class SambazaInjectableWidgetState<T extends StatefulWidget>
    extends SambazaWidgetState<T> with SambazaInjectable {
  @override
  void initState() {
    super.initState();
    inject();
  }
}
