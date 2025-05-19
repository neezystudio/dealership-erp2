import 'dart:convert';

import 'api.dart';
import 'injectable.dart';
import '../services/api.dart';
import '../services/storage.dart';

class SambazaResource with SambazaInjectable {
  final SambazaAPIEndpointGenerator endpointGenerator;
  final List<Type> $inject = <Type>[
    SambazaAPI,
    SambazaStorage,
  ];
  final String path;

  String get endpoint => endpointGenerator('$path/');

  SambazaResource(
    this.endpointGenerator, [
    this.path = '',
  ]) {
    inject();
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, dynamic> params,
  ]) async {
    String urlWithParams = SambazaAPIEndpoints.urlWithParams(
      path,
      params,
    );
    if ($$<SambazaStorage>().has(
      urlWithParams,
    )) {
      return Map<String, dynamic>.from(
        $$<SambazaStorage>().$get(
          urlWithParams,
        ),
      );
    }
    String result = await $$<SambazaAPI>().fetch(
      path,
      params,
    );
    Map<String, dynamic> decoded = Map<String, dynamic>.from(
      json.decode(
        result,
      ),
    );
    $$<SambazaStorage>().cache(
      urlWithParams,
      decoded,
    );
    return decoded;
  }

  Future<Map<String, dynamic>> $delete(
    String id,
  ) async {
    String result = await $$<SambazaAPI>().delete('$endpoint$id/');
    return Map<String, dynamic>.from(
      json.decode(
        result,
      ),
    );
  }

  Future<Map<String, dynamic>> $get([
    String id = '',
    Map<String, dynamic> params,
  ]) =>
      _get(
        '$endpoint${(id ?? '').isEmpty ? '' : '$id/'}',
        params,
      );

  Future<List<Map<String, dynamic>>> $list([
    Map<String, dynamic> params,
  ]) async {
    Map<String, dynamic> decoded = await _get(
      endpoint,
      params,
    );
    return List<Map<String, dynamic>>.from(
      decoded['results'],
    );
  }

  Future<Map<String, dynamic>> $save(
    Map<String, dynamic> body, [
    Map<String, dynamic> params
  ]) async {
    String result = await $$<SambazaAPI>().send(
      '$endpoint',
      body,
      params,
    );
    return Map<String, dynamic>.from(
      json.decode(
        result,
      ),
    );
  }

  Future<Map<String, dynamic>> $update(
    String id,
    Map<String, dynamic> body, [
    Map<String, dynamic> params,
  ]) async {
    String path = '$endpoint$id/';
    String result = await $$<SambazaAPI>().update(
      path,
      body,
      params,
    );
    Map<String, dynamic> decoded = Map<String, dynamic>.from(
      json.decode(
        result,
      ),
    );
    $$<SambazaStorage>().cache(
      SambazaAPIEndpoints.urlWithParams(
        path,
        params,
      ),
      decoded,
    );
    return decoded;
  }
}