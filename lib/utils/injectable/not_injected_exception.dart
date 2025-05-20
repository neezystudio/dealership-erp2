import 'package:dealership_erp_sambaza_app/utils/exception.dart';


class SambazaServiceNotInjectedException extends SambazaException {
  SambazaServiceNotInjectedException(String message, [String title = ''])
      : super(message, title);
}
