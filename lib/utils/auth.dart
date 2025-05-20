enum SambazaAuthRole { branch_admin, other, regular }

class SambazaAuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final SambazaAuthRole role;
  SambazaAuthUser(
      {required this.id, required this.email, required this.firstName, required this.lastName, required this.role});
}
