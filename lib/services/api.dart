import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


import 'auth.dart';
import '../utils/api.dart';
import '../utils/exception.dart';
import '../utils/injectable/service.dart';

// Ensure these exception classes are defined if not already present in '../utils/exception.dart'
// Example implementation (remove if already defined in your project):
/*
class SambazaAPIException implements Exception {
  final String message;
  final Uri uri;
  final int? statusCode;
  final String reasonPhrase;
  SambazaAPIException(this.message, [this.uri = Uri(), this.statusCode, this.reasonPhrase = '']);
  @override
  String toString() => 'SambazaAPIException: $message';
}

class SambazaException implements Exception {
  final String message;
  final String reason;
  SambazaException(this.message, [this.reason = '']);
  @override
  String toString() => 'SambazaException: $message';
}
*/

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
                  ? _parseErrorFromResponse(Map<String, dynamic>.from(bodyPart), [field])
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
      response.request is http.BaseRequest ? (response.request as http.BaseRequest).url : Uri(),
      response.statusCode,
      response.reasonPhrase ?? '',
    );
  }

  Future<String> delete(String endpoint, [Map<String, dynamic> params = const <String, dynamic>{}]) async {
    String url = SambazaAPIEndpoints.urlWithParams(endpoint, params);
    Map<String, String> headers = _headers();
    try {
      final http.Response response = await http.delete(Uri.parse(url), headers: headers);
      return _parseResponse(response);
    } on http.ClientException catch (e) {
      throw SambazaAPIException(
        e.message,
        e.uri ?? Uri(),
      );
    } on SocketException catch (e) {
      throw SambazaException(
        '$endpoint ${e.message}',
        'Connection Error',
      );
    }
  }

  Future<String> fetch(String endpoint, [Map<String, dynamic> params = const <String, dynamic>{}]) async {
    String url = SambazaAPIEndpoints.urlWithParams(endpoint, params);
    Map<String, String> headers = _headers();
    try {
      final http.Response response = await http.get(Uri.parse(url), headers: headers);
      return _parseResponse(response);
    } on http.ClientException catch (e) {
      throw SambazaAPIException(
        e.message,
        e.uri ?? Uri(),
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
    String url = SambazaAPIEndpoints.urlWithParams(endpoint, params ?? const <String, dynamic>{});
    Map<String, String> headers = _headers(<String, String>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    });
    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      return _parseResponse(response, body.keys);
    } on http.ClientException catch (e) {
      throw SambazaAPIException(
        e.message,
        e.uri ?? Uri(),
      );
    } on SocketException catch (e) {
      throw SambazaException(
        '$endpoint ${e.message}',
        'Connection Error',
      );
    } catch (e) {
      throw SambazaException(
        '$endpoint Unexpected error: $e',
        'Unknown Error',
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
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      return _parseResponse(response, body.keys);
    } on http.ClientException catch (e) {
      throw SambazaAPIException(
        e.message,
        e.uri ?? Uri(),
      );
    } on SocketException catch (e) {
      throw SambazaException(
        '$endpoint ${e.message}',
        'Connection Error',
      );
    }
  }
}
