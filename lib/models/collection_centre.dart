import 'common/all.dart';
import 'company.dart';
import '../resources.dart';
import '../utils/model.dart';

class CollectionCentre extends SambazaModel<CollectionCentreResource>
    with SambazaModelFlags, SambazaModelTimestamps {
  List<String> get branches;
  Company get company;
  String get email;
  set email(e);
  String get location;
  set location(l);
  String get name;
  set name(s);
  String get phone;
  set phone(p);

  CollectionCentre.create([Map<String, dynamic>? collectionCentre])
      : super.create(collectionCentre!);

  CollectionCentre.from(super.collectionCentre)
      : super.from();

  @override
  void init() {
    know(<String>[
      'branches',
      'company',
      'email',
      'location',
      'name',
      'phone',
    ]);
    relate('company', Company.create(fields['company']));
    resource = CollectionCentreResource();
    super.init();
  }
}
