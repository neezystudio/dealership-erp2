import 'package:flutter/widgets.dart';

import '../../state.dart';
import '../../utils/model.dart';

class SambazaListItemConfigBuilder<M extends SambazaModel, I extends SambazaModel> {

  String Function(M, [I]) group;
  final List<Widget> Function(M, [I]) leading;
  final List<String> Function(M, [I]) subtitle;
  final String Function(M, [I]) title;
  Widget Function(M, [I]) trailing;
  
  SambazaListItemConfigBuilder({
    this.group = _groupDefault,
    required this.leading,
    required this.subtitle,
    required this.title,
    this.trailing = _trailingDefault,
  });

  static String strFromTime(DateTime time) =>
      '${SambazaState.weekdays[time.weekday]}, ${time.day.toString()} ${SambazaState.months[time.month]} ${time.year.toString()}';

  static String _groupDefault(SambazaModel m, [SambazaModel? mI]) => '';

  static Widget _trailingDefault(SambazaModel m, [SambazaModel? mI]) => SizedBox(height: 8);

}