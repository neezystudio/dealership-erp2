import 'common/all.dart';
import 'company.dart';
import '../resources.dart';
import '../services/api.dart';
import '../utils/all.dart';

class Batch extends SambazaModel<BatchResource>
    with SambazaInjectable, SambazaModelFlags, SambazaModelTimestamps {
  @override
  final List<Type> $inject = <Type>[SambazaAPI];

  String get $closeTime;
  DateTime get closeTime => DateTime.parse($closeTime);
  Company get company;
  bool get isOpen;
  String get $startTime;
  DateTime get startTime => DateTime.parse($startTime);

  Batch.create([Map<String, dynamic>? batch]) : super.create(batch!);

  Batch.from(super.batch) : super.from();

  @override
  void init() {
    know(<String>[
      'close_time',
      'company',
      'is_open',
      'start_time',
    ]);
    relate('company', Company.create(fields['company']));
    resource = BatchResource();
    super.init();
  }

  Future<void> close() => $$<SambazaAPI>().update(
        '${resource.endpoint}close/',
        <String, dynamic>{},
      );
}
