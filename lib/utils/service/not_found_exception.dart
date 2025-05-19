import 'package:sambaza/utils/exception.dart';

class SambazaServiceNotFoundException extends SambazaException {
  SambazaServiceNotFoundException(String message, [String title = ''])
      : super(message, title);
}
