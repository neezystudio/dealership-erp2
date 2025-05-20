import 'cache.dart';
import 'exception.dart';
import 'resource.dart';

typedef SambazaModelFactory<T extends SambazaModel> =
    T Function([Map<String, dynamic> fields]);

class SambazaModelException extends SambazaException {
  SambazaModelException(message, [title = 'Model Error'])
    : super(message, title);
}

abstract class SambazaModel<R extends SambazaResource>
    implements SambazaCache<String, dynamic> {
  final Map<String, dynamic> fields;
  final List<String> knownFields = <String>[];
  final Map<String, SambazaModels> _lists = <String, SambazaModels>{};
  final Map<String, SambazaModelRelationship> _relationships =
      <String, SambazaModelRelationship>{};
  late R resource;

  SambazaModel(this.fields) {
    init();
  }

  SambazaModel.create([Map<String, dynamic>? fields])
    : this(fields = fields ?? <String, dynamic>{});

  SambazaModel.from(Map<String, dynamic> fields) : this(fields);

  static Future<SambazaModels<T>> list<T extends SambazaModel>(
    SambazaResource r,
    SambazaModelFactory<T> f, [
    Map<String, dynamic>? params,
  ]) async {
    List<Map<String, dynamic>> rL = await r.$list(params);
    return SambazaModels(rL, f);
  }

  String get id => fields['id'];
  dynamic get serialised =>
      fields.keys
          .where((String key) => knownFields.contains(key))
          .toList()
          .asMap()
          .map<String, dynamic>(
            (int i, String key) => MapEntry<String, dynamic>(key, fields[key]),
          )
        ..addAll(
          _relationships.map<String, dynamic>(
            (String field, SambazaModelRelationship relationship) =>
                MapEntry(field, relationship.serialise()),
          ),
        )
        ..addAll(
          _lists.map<String, dynamic>(
            (String field, SambazaModels list) =>
                MapEntry(field, list.serialise()),
          ),
        );

  void init() {}

  @override
  dynamic $get(String key) => fields[key];

  @override
  bool has(String key) => fields.containsKey(key);

  @override
  void $set(String key, dynamic value) {
    fields[key] = value;
  }

  void fill(Map<String, dynamic> newFields) {
    fields.addAll(newFields);
    _lists.forEach((String field, SambazaModels models) {
      if (newFields.containsKey(field)) {
        models.refresh(newFields[field]);
      }
    });
    _relationships.forEach((
      String field,
      SambazaModelRelationship relationship,
    ) {
      if (newFields.containsKey(field)) {
        relationship.fill(newFields[field]);
      }
    });
  }

  void know(List<String> more) => knownFields.addAll(more);

  bool knows(String fieldName) => knownFields.contains(fieldName);

  Map<Type, SambazaModels> get _listsTypeMap => _lists.map<Type, SambazaModels>(
    (String field, SambazaModels m) => MapEntry(m.list.runtimeType, m),
  );

  SambazaModels? listOf<T extends Type>(T type) =>
      _listsTypeMap[<T>[].runtimeType];

  SambazaModels<SambazaModel<SambazaResource>>? listFor<M extends SambazaModel>(
    String field,
  ) => _lists[field];

  void listOn<T extends SambazaModel>(
    String field,
    List<dynamic> list,
    SambazaModelFactory<T> f,
  ) {
    _lists[field] = SambazaModels<T>(List<Map<String, dynamic>>.from(list), f);
  }

  bool lists(String fieldName) => _lists.containsKey(fieldName);

  Future<void> pull([Map<String, dynamic>? params]) async {
    Map<String, dynamic> result = await resource.$get(id, params);
    fill(result);
  }

  void relate<T extends SambazaModel>(String field, T model) {
    _relationships[field] = SambazaModelRelationship<T>(model);
  }

  void relateMany<T extends SambazaModel>(
    String field,
    List<dynamic> list,
    SambazaModelFactory<T> f,
  ) {
    _lists[field] = SambazaModels<T>(List<Map<String, dynamic>>.from(list), f);
  }

  bool relatesOn(String fieldName) => _relationships.containsKey(fieldName);

  SambazaModelRelationship? relationship(String fieldName) =>
      _relationships[fieldName];

  Future<void> save([Map<String, dynamic>? params]) async {
    Map<String, dynamic> result = await resource.$save(serialised, params);
    fill(result);
  }

  Future<void> update([Map<String, dynamic>? params]) async {
    Map<String, dynamic> result = await resource.$update(
      id,
      serialised,
      params,
    );
    fill(result);
  }

  @override
  String toString() => serialised.toString();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    String key = invocation.memberName.toString().replaceAllMapped(
      RegExp(r'Symbol\("(\w+)=?"\)'),
      (Match m) => m.group(1) ?? '',
    );
    String snakeCaseKey = key.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (Match m) => '_${m.group(0)?.toLowerCase()}',
    );
    if (invocation.isGetter == true) {
      if (lists(key)) {
        return listFor(key)!.list;
      }
      if (lists(snakeCaseKey)) {
        return listFor(snakeCaseKey)!.list;
      }
      if (relatesOn(key)) {
        return relationship(key)!.model;
      }
      if (relatesOn(snakeCaseKey)) {
        return relationship(snakeCaseKey)!.model;
      }
      if (knows(key) && has(key)) {
        return $get(key);
      }
      if (knows(snakeCaseKey) && has(snakeCaseKey)) {
        return $get(snakeCaseKey);
      }
    } else if (invocation.isSetter == true) {
      dynamic value = invocation.positionalArguments.first;
      if (lists(key)) {
        return listFor(key)?.refresh(value);
      }
      if (lists(snakeCaseKey)) {
        return listFor(snakeCaseKey)?.refresh(value);
      }
      if (relatesOn(key)) {
        relationship(key)?.fill(value);
      }
      if (relatesOn(snakeCaseKey)) {
        relationship(snakeCaseKey)?.fill(value);
      }
      if (knows(key) && has(key)) {
        return $set(key, value);
      }
      if (knows(snakeCaseKey) && has(snakeCaseKey)) {
        return $set(snakeCaseKey, value);
      }
    }
    return super.noSuchMethod(invocation);
  }
}

class SambazaModelRelationship<T extends SambazaModel> {
  final T model;

  SambazaModelRelationship(this.model);

  void fill(dynamic value) {
    model.fill(
      value is SambazaModel
          ? value.serialised
          : Map<String, dynamic>.from(value),
    );
  }

  dynamic serialise() => model.serialised;
}

class SambazaModels<T extends SambazaModel> {
  final List<T> list;
  final SambazaModelFactory<T> modelFactory;

  SambazaModels(List<Map<String, dynamic>> items, SambazaModelFactory<T> f)
    : list = items.map<T>(f).toList(),
      modelFactory = f;

  T find(String id) => list.singleWhere(
    (T model) => model.id == id,
    orElse: () {
      throw SambazaModelException(
        'No model of type ${T.toString()} with id $id could be found',
        'Model not found',
      );
    },
  );

  int indexOf(String id) => list.indexWhere((T model) => model.id == id);

  void refresh(List<dynamic> value) {
    list.clear();
    list.addAll(
      value is List<T>
          ? value
          : List<Map<String, dynamic>>.from(
            value,
          ).map<T>(modelFactory).toList(),
    );
  }

  void replaceAt(String id, T model) {
    list[indexOf(id)] = model;
  }

  List<dynamic> serialise() => list.map((T model) => model.serialised).toList();
}
