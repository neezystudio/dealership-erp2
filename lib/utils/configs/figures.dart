import '../api.dart';

enum SambazaFiguresPeriod { daily, monthly }

final Map<SambazaFiguresPeriod, Map<String, dynamic>> _commissionParamMap = <SambazaFiguresPeriod, Map<String, dynamic>>{
  SambazaFiguresPeriod.daily: <String, dynamic>{'today': true},
  SambazaFiguresPeriod.monthly: <String, dynamic>{'month': true},
};

final Map<SambazaFiguresPeriod, String> _commissionTitleMap = <SambazaFiguresPeriod, String>{
  SambazaFiguresPeriod.daily: 'Today\'s',
  SambazaFiguresPeriod.monthly: 'This month\'s',
};

class SambazaFiguresConfig {
  final String endpoint;
  final SambazaFiguresPeriod period;
  final Map<String, dynamic> params;
  final String type;

  SambazaFiguresConfig(this.type, this.endpoint, this.period, [Map<String, dynamic>? options]): params = options ?? <String, dynamic> {} {
    params.addAll(_commissionParamMap[period]!);
  }

  String get endpointWithParams => SambazaAPIEndpoints.withParams(endpoint, params);

  String get title => '${_commissionTitleMap[period]} $type';

}