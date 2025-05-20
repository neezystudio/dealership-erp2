import 'package:dealership_erp_sambaza_app/utils/exception.dart' show SambazaException;


class SambazaServiceNotFoundException extends SambazaException {
  SambazaServiceNotFoundException(String message, [String title = ''])
      : super(message, title);
}
