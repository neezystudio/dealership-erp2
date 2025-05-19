export 'api.dart';
export 'auth.dart';
export 'storage.dart';
import 'api.dart';
import 'auth.dart';
import 'storage.dart';
import '../utils/service.dart';

class SambazaServices {
  static List<SambazaServiceFactory> factories = <SambazaServiceFactory>[
    () => SambazaStorage(),
    () => SambazaAuth(),
    () => SambazaAPI(),
  ];
}
