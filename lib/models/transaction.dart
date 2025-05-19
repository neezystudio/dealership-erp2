import 'common/all.dart';
import '../resources.dart';
import '../utils/model.dart';

enum TransactionMethod { bank, mpesa }
enum TransactionStatus { approved, created, rejected }

final Map<String, TransactionMethod> _methodMap = TransactionMethod.values
    .asMap()
    .map<String, TransactionMethod>((int i, TransactionMethod m) =>
        MapEntry(m.toString().split('.').last, m));
final Map<String, TransactionStatus> _statusMap = TransactionStatus.values
    .asMap()
    .map<String, TransactionStatus>((int i, TransactionStatus s) =>
        MapEntry(s.toString().split('.').last, s));

class Transaction extends SambazaModel<TransactionResource>
    with SambazaModelFlags, SambazaModelTimestamps {
  String get batch;
  String get branch;
  String get comments;
  set comments(c);
  String get company;
  String get description;
  set description(d);
  bool get isComplete;
  String get $method => fields['method'];
  TransactionMethod get method => _methodMap[$method];
  set method(TransactionMethod m) {
    fields['method'] = m.toString().replaceAll('TransactionMethod.', '');
  }

  String get referenceNumber;
  set referenceNumber(r);
  String get $status => fields['status'];
  TransactionStatus get status => _statusMap[$get('status')];
  set status(TransactionStatus s) {
    fields['status'] = s.toString().replaceAll('TransactionStatus.', '');
  }

  String get transactionNumber;
  String get user;
  num get value;

  Transaction.create([Map<String, dynamic> transaction])
      : super.create(transaction);

  Transaction.from(Map<String, dynamic> transaction) : super.from(transaction);

  @override
  init() {
    know(<String>[
      'batch',
      'branch',
      'comments',
      'company',
      'description',
      'is_complete',
      'method',
      'reference_number',
      'status',
      'transaction_number',
      'value',
    ]);
    resource = TransactionResource();
    super.init();
  }

  @override
  Map<String, dynamic> get serialised =>
      Map<String, dynamic>.from(super.serialised);
}
