import 'package:flutter/material.dart';

import '../utils/exception.dart';
import '../widgets/error.dart';

class UnknownPage extends StatelessWidget {

  final String name;

  const UnknownPage(this.name, {super.key});

  static MaterialPageRoute create(RouteSettings settings) => MaterialPageRoute(
    builder: (BuildContext context) => UnknownPage(settings.name.toString()),
  );

  @override
  Widget build(BuildContext context) => SambazaError(
    SambazaException(
      'The page you were looking for does not exist. Ref: $name',
    )
  );
}