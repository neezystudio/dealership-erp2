import 'common/all.dart';
import 'user.dart';
import '../resources.dart';
import '../utils/model.dart';

class Rollup extends SambazaModel<RollupResource>
    with SambazaModelFlags, SambazaModelTimestamps {
  String get batch;
  String get branch;
  String get company;
  String get referenceNumber;
  User get user;
  num get value;

  Rollup.create([Map<String, dynamic> fields]) : super.create(fields);

  Rollup.from(Map<String, dynamic> fields) : super.from(fields);

  @override
  void init() {
    know(<String>[
      'batch',
      'branch',
      'company',
      'reference_number',
      'value',
    ]);
    resource = RollupResource();
    super.init();
  }
}
