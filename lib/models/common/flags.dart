import '../../utils/all.dart';

mixin SambazaModelFlags<R extends SambazaResource> on SambazaModel<R> {
  String get $deletedAt;
  DateTime get deletedAt => DateTime.parse($deletedAt);
  bool get isActive;
  bool get isDeleted;

  @override
  void init() {
    know(<String>[
      'deleted_at',
      'is_active',
      'is_deleted',
    ]);
    super.init();
  }
}
