enum SambazaAuthRole { branch_admin, other, regular }

class SambazaAuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final SambazaAuthRole role;
  SambazaAuthUser(
      {this.id, this.email, this.firstName, this.lastName, this.role});
}
