import 'common/all.dart';
import '../resources.dart';
import '../utils/model.dart';


class Branch extends SambazaModel<BranchResource> with SambazaModelFlags, SambazaModelTimestamps {
  List<String> get collectionCentres;
  String get company;
  String get description;
  String get email;
  bool get isHead;
  String get location;
  String get name;
  String get phone;

  Branch.create([Map<String, dynamic>? branch]) : super.create(branch!);

  Branch.from(Map<String, dynamic> branch) : super.from(branch);

  @override
  void init() {
    know(<String>[
      'collection_centres',
      'company',
      'description',
      'isHead',
      'location',
      'name',
      'phone',
    ]);
    super.init();
  }
}