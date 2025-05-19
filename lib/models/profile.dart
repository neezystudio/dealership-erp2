import 'common/all.dart';
import '../utils/model.dart';

class Profile extends SambazaModel with SambazaModelTimestamps {
  String get branch;
  String get company;
  String get deviceToken;
  set deviceToken(d);
  String get picture;
  set picture(p);
  String get user;

  Profile.create([Map<String, dynamic> profile]) : super.create(profile);

  Profile.from(Map<String, dynamic> profile) : super.from(profile);

  @override
  void init() {
    know(<String>[
      'branch',
      'company',
      'device_token',
      'picture',
    ]);
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
