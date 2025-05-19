import 'dart:convert';

import 'package:http/http.dart' as http;

class SambazaAPI {

  _SambazaAPIEndpoints endpoints = _SambazaAPIEndpoints();

}

class _SambazaAPIEndpoints {

  String orders([path = '/']) => '/orders$path';

}
