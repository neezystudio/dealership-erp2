import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../services/all.dart';
import '../../resources.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class EditOrderPage extends StatelessWidget {
  static String route = '/orders/edit';

  const EditOrderPage({super.key});

  static EditOrderPage create(BuildContext context) => EditOrderPage();

  @override
  Widget build(BuildContext context) => SambazaCreatePage(
        form: _EditOrderForm(),
        title: 'Edit order',
      );
}

class _EditOrderForm extends StatefulWidget {
  @override
  _EditOrderFormState createState() => _EditOrderFormState();
}

class _EditOrderFormState extends SambazaInjectableWidgetState<_EditOrderForm> {
  bool _autovalidate = false, _valid = false, _processing = false;
  final Map<String, SambazaFieldBuilder> _fieldBuilders =
      <String, SambazaFieldBuilder>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  final List<Type> $inject = <Type>[SambazaAPI, SambazaStorage];
  final List<List<String>> _nestedFieldBuilderSets = <List<String>>[];
  Order _order;

  ThemeData get themeData => Theme.of(context);

  @override
  void dispose() {
    for (var builder in _fieldBuilders.values) {
      builder.field.destroy();
    }
    super.dispose();
  }

  @override
  Widget template(BuildContext context) => FutureBuilder<List<Airtime>>(
        builder: (BuildContext context, AsyncSnapshot<List<Airtime>> snapshot) {
          if (snapshot.hasData) {
            return _buildForm(snapshot.data);
          } else if (snapshot.hasError) {
            return SambazaError(snapshot.error);
          }
          return SambazaLoader('Loading...');
        },
        future: _prepareOrder(),
      );

  String _addFieldBuilder(SambazaField field, [String builderName]) {
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

  Widget _buildField(String name) => _fieldBuilders[name].build(
        _processing,
        false,
        _fieldBuilders.values.last.field.name == name,
      );

  Form _buildForm(List<Airtime> airtimeList) => Form(
        autovalidate: _autovalidate,
        key: _formKey,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Order Items',
                  style: themeData.textTheme.body2,
                ),
              ],
            ),
          ]
            ..addAll(_generateFieldSets())
            ..addAll(<Widget>[
              SizedBox(height: 8),
              Row(
                children: <Widget>[
                  RaisedButton(
                      child: Text('ADD ITEM'),
                      onPressed: () {
                        setState(() {
                          _addNestedFieldBuilderSet(airtimeList);
                        });
                      })
                ],
                mainAxisAlignment: MainAxisAlignment.end,
              ),
              SizedBox(height: 8),
              _processing
                  ? SambazaLoader('Placing order')
                  : SizedBox(height: 35),
              Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    focusNode: null,
                    onPressed: !_processing
                        ? () {
                            Navigator.pop(context, null);
                          }
                        : null,
                    textColor: Colors.black87,
                  ),
                  Expanded(
                    child: SizedBox(height: 8),
                  ),
                  RaisedButton(
                    child: Text('SAVE'),
                    focusNode: null,
                    onPressed: !_processing ? _save : null,
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.end,
              ),
            ]),
          mainAxisSize: MainAxisSize.min,
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
          _buildField,
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
        ([Map<String, dynamic> fields]) => Airtime.create(fields),
      );

  Future<SambazaModels<Telco>> _listTelcos() => SambazaModel.list<Telco>(
        TelcoResource(),
        ([Map<String, dynamic> fields]) => Telco.create(fields),
      );

  void Function() _onFieldEditingComplete(SambazaField field) => () {
        if (_fieldBuilders.values.last.field == field) {
          _validate().catchError(_handleError);
        }
      };

  void Function(String) _onFieldChanged(SambazaField field) => (String value) {
        setState(() {
          field.controller.value = TextEditingValue(text: value);
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

  Future<List<Airtime>> _prepareOrder() async {
    if (ModalRoute.of(context).settings.arguments is! Order) {
      throw SambazaException('Expected "Order" to be passed to this page.');
    }
    SambazaModels<Airtime> airtimes = await _listAirtimes();
    SambazaModels<Telco> telcos = await _listTelcos();
    List<Airtime> airtimeList = airtimes.list.map<Airtime>((Airtime a) {
      a.$telco = telcos.list.firstWhere((Telco t) => t.id == a.telco);
      return a;
    }).toList();
    return airtimeList;
  }

  void _save() {
    _validate()
        .then((_) {
          setState(() {
            _processing = true;
          });
          _order.fill(<String, dynamic>{
            'order_items': _nestedFieldBuilderSets
                .map<Map<String, dynamic>>(
                  (List<String> fieldSet) => <String, dynamic>{
                    'airtime': <String, dynamic>{
                      'id': _fieldBuilders[fieldSet[0]].field.value,
                    },
                    'quantity': _fieldBuilders[fieldSet[1]].field.value,
                  },
                )
                .toList(),
          });
        })
        .then((_) => _order.update())
        .then((_) {
          Navigator.pop(context, _order.fields);
        })
        .catchError((e) {
          if (e is SambazaException) {
            Scaffold.of(context).showSnackBar(SnackBar(
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
          print(e);
        })
        .whenComplete(() {
          setState(() {
            _processing = false;
          });
        });
  }

  Future<void> _validate() async {
    setState(() {
      _valid = _formKey.currentState.validate();
      _autovalidate = _valid == false;
    });
    if (_valid) {
      _formKey.currentState.save();
      return;
    }
    _fieldBuilders.values
        .firstWhere((SambazaFieldBuilder builder) => builder.field.$invalid)
        .field
        .focusNode
        .requestFocus();
    throw SambazaException(
      'A field(s) in the form is/are invalid',
      'Form Error',
    );
  }
}
