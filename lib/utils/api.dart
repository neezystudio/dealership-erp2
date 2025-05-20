import 'exception.dart';

typedef SambazaAPIEndpointGenerator = String Function(String);

class SambazaAPIException extends SambazaException {
  final int code;
  @override
  final String message;
  @override
  final String title;
  final Uri uri;

  SambazaAPIException(this.message, this.uri, [this.code = 0, this.title = ''])
      : super(message, title);

  @override
  String toString() => message;
}

class SambazaAPIEndpoints {
  static const String BASE_URL = 'https://api.sambazaerp.co.ke/api/v1';

  static String accounts([path = '/']) => '/accounts$path';
  static String airtime([path = '/']) => '/orders/airtime$path';
  static String batches([path = '/']) => '/entities/batches$path';
  static String branches([path = '/']) => '/entities/branches$path';
  static String collectionCentres([path = '/']) =>
      '/entities/collection-centres$path';
  static String commissions([path = '/']) => '/sales/total-commission$path';
  static String companies([path = '/']) => '/entities/company$path';
  static String debts([path = '/']) => '/sales/debts$path';
  static String dispatch([path = '/']) => '/orders/dispatch$path';
  static String inventory([path = '/']) => '/orders/inventory$path';
  static String lpos([path = '/']) => '/orders/lpos$path';
  static String orders([path = '/']) => '/orders$path';
  static String requests([path = '/']) => '/management/requests$path';
  static String rollup([path = '/']) => '/sales/rollup$path';
  static String sales([path = '/']) => '/sales$path';
  static String stockTransfers([path = '/']) => '/orders/transfers$path';
  static String telcos([path = '/']) => '/entities/telcos$path';
  static String transactions([path = '/']) => '/sales/transactions$path';

  static String serialiseQueryParams(Map<String, dynamic> params) =>
      params.isNotEmpty
          ? '?${params
                  .map<String, String>((String key, dynamic value) =>
                      MapEntry<String, String>(key, '$key=${value.toString()}'))
                  .values
                  .join('&')}'
          : '';

  static String withParams(String endpoint, [Map<String, dynamic>? params]) =>
      endpoint + serialiseQueryParams(params ?? <String, dynamic>{});

  static String urlWithParams(String endpoint, [Map<String, dynamic>? params]) =>
      BASE_URL + withParams(endpoint, params);
}
