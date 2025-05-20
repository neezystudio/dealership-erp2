import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


import 'auth.dart';
import '../utils/api.dart';
import '../utils/exception.dart';
import '../utils/injectable/service.dart';

class SambazaAPI extends SambazaInjectableService {
  final List<String> _errors = <String>[
    'detail',
    'non_field_errors',
  ];
  @override
  final List<Type> $inject = <Type>[SambazaAuth];

  String _decodeError(dynamic error) =>
      error is List ? error.join('') : error.toString();

  Map<String, String> _headers(
      [Map<String, String> headers = const <String, String>{}]) {
    if ($$<SambazaAuth>().token.isNotEmpty) {
      return <String, String>{
        HttpHeaders.authorizationHeader: 'Token ${$$<SambazaAuth>().token}',
      }..addAll(headers);
    }
    return headers;
  }

  String _parseErrorFromResponse(
      Map<String, dynamic> responseBody, Iterable<String> fields) {
    String error = '';
    if (fields.isNotEmpty) {
      for (var field in fields) {
        if (responseBody.containsKey(field)) {
          if (responseBody[field] is Map) {
            for (var value in _errors) {
              if (responseBody[field].containsKey(value)) {
                error += _decodeError(responseBody[field][value]);
              }
            }
          } else if (responseBody[field] is List) {
            responseBody[field].forEach((dynamic bodyPart) {
              error += bodyPart is Map
                  ? _parseErrorFromResponse(bodyPart, [field])
                  : _decodeError(bodyPart);
            });
          } else {
            error += _decodeError(responseBody[field]);
          }
        }
      }
    }
    for (var value in _errors) {
      if (responseBody.containsKey(value)) {
        error += _decodeError(responseBody[value]);
      }
    }
    return error;
  }

  String _parseResponse(http.Response response,
      [Iterable<String> fields = const <String>[]]) {
    // print(
    //   'SambazaAPI: ${response.statusCode} ${response.request.method} ${response.request.url}',
    // );
    if ([200, 201].contains(response.statusCode)) {
      // print('SambazaAPI: ${response.body}');
      return response.body;
    } else {
      print(response.body);
    }
    String error = response.body;
    if (response.statusCode == 400) {
      Map<String, dynamic> decoded =
          Map<String, dynamic>.from(json.decode(response.body));
      error = _parseErrorFromResponse(decoded, fields);
    }
    throw SambazaAPIException(
      error,
      response.request.url,
      response.statusCode,
      response.reasonPhrase,
    );
  }

  Future<String> delete(String endpoint, [Map<String, dynamic> params]) async {
    String url = SambazaAPIEndpoints.urlWithParams(endpoint, params);
    Map<String, String> headers = _headers();
    try {
      final http.Response response = await http.delete(url, headers: headers);
      return _parseResponse(response);
    } on http.ClientException catch (e) {
      throw SambazaAPIException(
        e.message,
        e.uri,
      );
    } on SocketException catch (e) {
      throw SambazaException(
        '$endpoint ${e.message}',
        'Connection Error',
      );
    }
  }

  Future<String> fetch(String endpoint, [Map<String, dynamic> params]) async {
    String url = SambazaAPIEndpoints.urlWithParams(endpoint, params);
    Map<String, String> headers = _headers();
    try {
      final http.Response response = await http.get(url, headers: headers);
      return _parseResponse(response);
    } on http.ClientException catch (e) {
      throw SambazaAPIException(
        e.message,
        e.uri,
      );
    } on SocketException catch (e) {
      throw SambazaException(
        '$endpoint ${e.message}',
        'Connection Error',
      );
    }
  }

  Future<String> send(String endpoint, Map<String, dynamic> body,
      [Map<String, dynamic>? params]) async {
    String url = SambazaAPIEndpoints.urlWithParams(endpoint, params);
    Map<String, String> headers = _headers(<String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    });
    try {
      final http.Response response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );
      return _parseResponse(response, body.keys);
    } on http.ClientException catch (e) {
      throw SambazaAPIException(
        e.message,
        e.uri,
      );
    } on SocketException catch (e) {
      throw SambazaException(
        '$endpoint ${e.message}',
        'Connection Error',
      );
    }
  }

  Future<String> update(String endpoint, Map<String, dynamic> body,
      [Map<String, dynamic> params = const <String, dynamic>{}]) async {
    String url = SambazaAPIEndpoints.urlWithParams(endpoint, params);
    Map<String, String> headers = _headers(<String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    });
    try {
      final http.Response response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );
      return _parseResponse(response, body.keys);
    } on http.ClientException catch (e) {
      throw SambazaAPIException(
        e.message,
        e.uri,
      );
    } on SocketException catch (e) {
      throw SambazaException(
        '$endpoint ${e.message}',
        'Connection Error',
      );
    }
  }
}
