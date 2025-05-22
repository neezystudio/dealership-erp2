import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../resources.dart';
import '../../services/all.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class CreateSalePage extends StatelessWidget {
  static String route = '/sales/create';

  const CreateSalePage({super.key});

  static CreateSalePage create(BuildContext context) => CreateSalePage();

  @override
  Widget build(BuildContext context) => SambazaCreatePage(
        form: _CreateSaleForm(),
        title: 'Submit a sale',
      );
}

class _CreateSaleForm extends StatefulWidget {
  @override
  _CreateSaleFormState createState() => _CreateSaleFormState();
}

class _CreateSaleFormState
    extends SambazaInjectableWidgetState<_CreateSaleForm> {
  bool _autovalidate = false, _valid = false, _processing = false;
  late Future<List<Airtime>> _airtimeListFuture;
  final Map<String, SambazaFieldBuilder> _fieldBuilders =
      <String, SambazaFieldBuilder>{};
  final List<SambazaField> _fields = <SambazaField>[
    SambazaField.textArea(
      label: 'Notes',
      name: 'notes',
      placeholder: 'Add some notes',
    ),
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  final List<Type> $inject = <Type>[SambazaAPI, SambazaStorage];
  final List<List<String>> _nestedFieldBuilderSets = <List<String>>[];

  ThemeData get themeData => Theme.of(context);

  @override
  void dispose() {
    for (var field in _fields) {
      field.destroy();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _airtimeListFuture = _listAirtimes().then((SambazaModels<Airtime> airtimes) async {
      SambazaModels<Telco> telcos = await _listTelcos();
      List<Airtime> airtimeList = airtimes.list.map<Airtime>((Airtime a) {
        a.$telco = telcos.list.firstWhere((Telco t) => t.id == a.telco);
        return a;
      }).toList();
      _fields.addAll(<SambazaField>[
        SambazaField.select<Airtime>(
          label: 'Airtime',
          name: 'airtime',
          options: airtimeList,
          optionBuilder: _buildAirtimeOption,
          require: true,
          type: 'text',
        ),
        SambazaField.number(
          label: 'Quantity',
          name: 'quantity',
          placeholder: 'Quantity',
          step: 1,
          require: true,
        ),
      ]);
      for (var field in _fields) {
        _addFieldBuilder(field, field.name);
      }
      _nestedFieldBuilderSets.add(<String>['airtime', 'quantity']);
      return airtimeList;
    });
  }

  @override
  Widget template(BuildContext context) => FutureBuilder<List<Airtime>>(
        builder: (BuildContext context, AsyncSnapshot<List<Airtime>> snapshot) {
          if (snapshot.hasData) {
            return _buildForm(snapshot.data!);
          } else if (snapshot.hasError) {
            return SambazaError(
              snapshot.error is SambazaException
                  ? snapshot.error as SambazaException
                  : SambazaException('Unknown error', snapshot.error?.toString() ?? ''),
              onButtonPressed: () {
                // You can define what should happen when the button is pressed, e.g. retry
                setState(() {
                  _airtimeListFuture = _listAirtimes().then((SambazaModels<Airtime> airtimes) async {
                    SambazaModels<Telco> telcos = await _listTelcos();
                    List<Airtime> airtimeList = airtimes.list.map<Airtime>((Airtime a) {
                      a.$telco = telcos.list.firstWhere((Telco t) => t.id == a.telco);
                      return a;
                    }).toList();
                    return airtimeList;
                  });
                });
              },
            );
          }
          return SambazaLoader('Loading...');
        },
        future: _airtimeListFuture,
      );

  String _addFieldBuilder(SambazaField field, [String? builderName]) {
    builderName ??= '${field.name}${_fieldBuilders.length}';
    field.init();
    _fieldBuilders[builderName] = _createFieldBuilder(field);
    return builderName;
  }

  void _addNestedFieldBuilderSet(List<Airtime> airtimes) =>
      setState(() => _nestedFieldBuilderSets.add(<String>[
            _addFieldBuilder(SambazaField.select<Airtime>(
              label: 'Airtime',
              name: 'airtime',
              options: airtimes,
              optionBuilder: _buildAirtimeOption,
              require: true,
              type: 'text',
            )),
            _addFieldBuilder(SambazaField.number(
              label: 'Quantity',
              name: 'quantity',
              placeholder: 'Quantity',
              step: 1,
              require: true,
            )),
          ]));

  SambazaOption _buildAirtimeOption(Airtime airtime) => SambazaOption(
        optionText: '${airtime.$telco.name} - Bamba ${airtime.value.toInt().toString()}',
        value: airtime.id,
      );

  Widget _buildField(String name) {
    final builder = _fieldBuilders[name];
    if (builder == null) {
      return SizedBox.shrink();
    }
    return builder.build(
      _processing,
      false,
      _fieldBuilders.values.last.field.name == name,
    );
  }

  Form _buildForm(List<Airtime> airtimeList) => Form(
        autovalidateMode: _autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Sale Items',
                  style: themeData.textTheme.bodyMedium,
                ),
              ],
            ), ..._generateFieldSets(), SizedBox(height: 8),
              // Divider(),
              Row(
                children: <Widget>[
                  ElevatedButton(
                      child: Text('ADD ITEM'),
                      onPressed: () {
                        setState(() {
                          _addNestedFieldBuilderSet(airtimeList);
                        });
                      })
                ],
                mainAxisAlignment: MainAxisAlignment.end,
              ),
              _buildField('notes'),
              SizedBox(height: 8),
              _processing
                  ? SambazaLoader('Creating sale')
                  : SizedBox(height: 35),
              Row(
                children: <Widget>[
                  TextButton(
                    child: Text('SUBMIT', style: TextStyle(color: Colors.black87)),
                    focusNode: null,
                    onPressed: !_processing
                        ? () {
                            Navigator.pop(context, null);
                          }
                        : null,
                  ),
                  Expanded(
                    child: SizedBox(height: 8),
                  ),
                  ElevatedButton(
                    child: Text('MAKE'),
                    focusNode: null,
                    onPressed: !_processing ? _create : null,
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.end,
              ),
          ]
            
            ,
        ),
      );

  SambazaFieldBuilder _createFieldBuilder(SambazaField field) =>
      SambazaFieldBuilder.of(
        field,
        onChanged: _onFieldChanged(field),
        onComplete: _onFieldEditingComplete(field),
        onSubmit: _onFieldSubmitted(field),
      );

  List<Widget> _generateFieldSets() => _nestedFieldBuilderSets
      .map<Widget>(
        (List<String> fieldSet) => SambazaAirtimeFieldSet(
          (String name) => _fieldBuilders[name]?.build(
                _processing,
                false,
                _fieldBuilders.values.last.field.name == name,
              ) as FormField<String>,
          airtimeFieldName: fieldSet[0],
          quantityFieldName: fieldSet[1],
          onDelete: () => setState(() {
            _nestedFieldBuilderSets.remove(fieldSet);
          }),
        ),
      )
      .toList();

  void _handleError(Exception error) {
    print(error);
  }

  Future<SambazaModels<Airtime>> _listAirtimes() => SambazaModel.list<Airtime>(
        AirtimeResource(),
        ([Map<String, dynamic> fields = const {}]) => Airtime.create(fields),
      );

  Future<SambazaModels<Telco>> _listTelcos() => SambazaModel.list<Telco>(
        TelcoResource(),
        ([Map<String, dynamic> fields = const {}]) => Telco.create(fields),
      );

  void Function() _onFieldEditingComplete(SambazaField field) => () {
        if (_fieldBuilders.values.last.field == field) {
          _validate().catchError(_handleError);
        }
      };

  void Function(String?) _onFieldChanged(SambazaField field) => (String? value) {
        setState(() {
          field.controller.value = TextEditingValue(text: value ?? '');
        });
      };

  void Function(String) _onFieldSubmitted(SambazaField field) =>
      (String value) {
        List<SambazaField> f = _fieldBuilders.values
            .map<SambazaField>((SambazaFieldBuilder builder) => builder.field)
            .toList();
        if (f.last == field) {
          _validate().catchError(_handleError);
        } else {
          f.elementAt(f.indexOf(field) + 1).focusNode.requestFocus();
        }
      };

  void _create() {
    _validate().then<Sale>((x) {
      setState(() {
        _processing = true;
      });
      return Sale.create(<String, dynamic>{
        'notes': _fields
            .firstWhere((SambazaField field) => field.name == 'notes')
            .value,
        'sale_items': _nestedFieldBuilderSets
            .map<Map<String, dynamic>>(
                (List<String> fieldSet) => <String, dynamic>{
                      'airtime': <String, dynamic>{
                        'id': _fieldBuilders[fieldSet[0]]!.field.value,
                      },
                      'quantity': _fieldBuilders[fieldSet[1]]!.field.value,
                    })
            .toList(),
      });
    }).then<Sale>((Sale sale) async {
      await sale.save();
      return sale;
    }).then((Sale sale) {
      Navigator.pop(context, sale.fields);
    }).catchError((e) {
      if (e is SambazaException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: <Widget>[
              Text('ERROR'),
              SizedBox(width: 8.0),
              Expanded(
                child: Text('${e.title} - ${e.message}'),
              ),
            ],
          ),
        ));
      }
      if (e is Exception) {
        _handleError(e);
      }
    }).whenComplete(() {
      setState(() {
        _processing = false;
      });
    });
  }

  Future<void> _validate() {
    setState(() {
      _valid = _formKey.currentState?.validate() ?? false;
      _autovalidate = _valid == false;
    });
    if (_valid) {
      _formKey.currentState?.save();
      return Future.value();
    }
    _fields
        .firstWhere((SambazaField field) => field.$invalid)
        .focusNode
        .requestFocus();
    return Future.error(SambazaException(
        'A field(s) in the form is/are invalid', 'Form Error'));
  }
}
