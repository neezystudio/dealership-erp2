import '../../utils/all.dart';

mixin SambazaModelTimestamps<R extends SambazaResource> on SambazaModel<R> {
  String get $createdAt => fields['created_at'];
  DateTime get createdAt => DateTime.parse($createdAt).toLocal();
  String get createdBy;
  String get $modifiedAt => fields['modified_at'];
  DateTime get modifiedAt => DateTime.parse($modifiedAt).toLocal();
  String get modifiedBy;

  @override
  void init() {
    know(<String>[
      'created_at',
      'created_by',
      'modified_at',
      'modified_by',
    ]);
    super.init();
  }
}
