import 'common/all.dart';
import '../resources.dart';
import '../utils/model.dart';

class Company extends SambazaModel<CompanyResource>
    with SambazaModelFlags, SambazaModelTimestamps {
  String get address;
  num get commissionPercentage;
  String get description;
  String get email;
  String get fax;
  String get location;
  String get logo;
  num get maxDebtPercentage;
  String get name;
  String get phone;
  String get pinNo;
  String get poBox;
  String get tel;

  Company.create([Map<String, dynamic> company]) : super.create(company);

  Company.from(Map<String, dynamic> company) : super.from(company);

  @override
  void init() {
    know(<String>[
      'address',
      'commission_percentage',
      'description',
      'email',
      'fax',
      'location',
      'logo',
      'max_debt_percentage',
      'name',
      'phone',
      'pin_no',
      'po_box',
      'tel',
    ]);
    resource = CompanyResource();
    super.init();
  }
}
