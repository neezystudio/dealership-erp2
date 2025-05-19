import 'package:sambaza/utils/exception.dart';

class SambazaServiceNotInjectedException extends SambazaException {
  SambazaServiceNotInjectedException(String message, [String title = ''])
      : super(message, title);
}
