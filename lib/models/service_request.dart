import 'common/all.dart';
import '../resources.dart';
import '../utils/model.dart';

enum ServiceRequestStatus { approved, created, fulfilled, rejected }

final Map<String, ServiceRequestStatus> _statusMap = ServiceRequestStatus.values
    .asMap()
    .map<String, ServiceRequestStatus>((int i, ServiceRequestStatus s) =>
        MapEntry(s.toString().split('.').last, s));

class ServiceRequest extends SambazaModel<ServiceRequestResource>
    with SambazaModelFlags, SambazaModelTimestamps {
  num get amount;
  set amount(a);
  String get comments;
  set comments(c);
  String get description;
  set description(d);
  String get requestNumber;
  set requestNumber(r);
  String get $status => fields['status'];
  ServiceRequestStatus get status => _statusMap[$status];
  set status(ServiceRequestStatus s) {
    fields['status'] = s.toString().split('.').last;
  }

  String get title;
  set title(t);

  ServiceRequest.create([Map<String, dynamic> serviceRequest])
      : super.create(serviceRequest);

  ServiceRequest.from(Map<String, dynamic> serviceRequest)
      : super.from(serviceRequest);

  @override
  init() {
    know(<String>[
      'amount',
      'comments',
      'description',
      'request_number',
      'status',
      'title',
    ]);
    resource = ServiceRequestResource();
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
