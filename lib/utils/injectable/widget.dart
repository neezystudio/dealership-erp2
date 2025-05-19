import 'package:flutter/widgets.dart';

import '../injectable.dart';
import '../widget.dart';

abstract class SambazaInjectableStatelessWidget extends SambazaStatelessWidget
    with SambazaInjectable {
  @override
  Widget build(BuildContext context) {
    inject();
    return super.build(context);
  }
}
