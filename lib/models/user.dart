import 'common/all.dart';
import 'debt.dart';
import 'profile.dart';
import '../resources.dart';
import '../utils/auth.dart';
import '../utils/model.dart';

class User extends SambazaModel<UserResource> with SambazaModelFlags {
  Debt get debt;
  String get email;
  set email(s);
  String get firstName;
  set firstName(f);
  String get fullName;
  set fullName(f);
  bool get isBranchAdmin;
  bool get isCompanyAdmin;
  bool get isDsa;
  bool get isFinanceAdmin;
  bool get isLogisticsAdmin;
  bool get isOpsAdmin;
  bool get isRegularUser;
  Map get lastName;
  set lastName(l);
  String get phone;
  set phone(p);
  Profile get profile;
  String get $role => fields['role'];
  SambazaAuthRole get role {
    switch ($role) {
      case 'manager':
        return SambazaAuthRole.branch_admin;
      case 'regular':
        return SambazaAuthRole.regular;
      default:
        return SambazaAuthRole.other;
    }
  }

  bool get usable;

  User.create([Map<String, dynamic> user]) : super.create(user);

  User.from(Map<String, dynamic> user) : super.from(user);

  @override
  void init() {
    know(<String>[
      'debt',
      'email',
      'first_name',
      'full_name',
      'is_branch_admin',
      'is_company_admin',
      'is_dsa',
      'is_finance_admin',
      'is_logistics_admin',
      'is_ops_admin',
      'is_regular_user',
      'last_name',
      'phone',
      'profile',
      'role',
    ]);
    relate('debt', Debt.create(fields['debt']));
    relate('profile', Profile.create(fields['profile']));
    resource = UserResource();
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
