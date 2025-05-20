import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class AssignSerialsPage extends StatelessWidget {
  static String route = '/branch/lpos/items/assign-serials';

  const AssignSerialsPage({super.key});

  static AssignSerialsPage create(BuildContext context) => AssignSerialsPage();

  @override
  Widget build(BuildContext context) => SambazaCreatePage(
        form: _AssignSerialsForm(),
        title: 'Assign serials',
      );
}

class _AssignSerialsForm extends StatefulWidget {
  @override
  _AssignSerialsFormState createState() => _AssignSerialsFormState();
}

class _AssignSerialsFormState extends State<_AssignSerialsForm> {
  bool _autovalidate = false, _valid = false, _processing = false;
  final List<SambazaField> _fields = <SambazaField>[
    SambazaField.number(
      label: 'First Serial',
      name: 'serial_first',
      placeholder: 'Enter the first serial number',
      step: 1,
      require: true,
    ),
    SambazaField.number(
      label: 'Last Serial',
      name: 'serial_last',
      placeholder: 'Enter the last serial number',
      step: 1,
      require: true,
    ),
  ];
  final Map<String, SambazaFieldBuilder> _fieldBuilders =
      <String, SambazaFieldBuilder>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LPOItem _lpoItem;

  ThemeData get themeData => Theme.of(context);

  @override
  void dispose() {
    for (var builder in _fieldBuilders.values) {
      builder.field.destroy();
    }
    super.dispose();
  }

  @override
  void initState() {
    for (var field in _fields) {
      _addFieldBuilder(field, field.name);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LPOItem>(
        builder: (BuildContext context, AsyncSnapshot<LPOItem> snapshot) {
          if (snapshot.hasData) {
            return _buildForm();
          } else if (snapshot.hasError) {
            return SambazaError(snapshot.error);
          }
          return SambazaLoader('Loading...');
        },
        future: _prepareItem(),
      );

  String _addFieldBuilder(SambazaField field, [String builderName]) {
    builderName ??= '${field.name}${_fieldBuilders.length}';
    field.init();
    _fieldBuilders[builderName] = _createFieldBuilder(field);
    return builderName;
  }

  Widget _buildField(String name) => _fieldBuilders[name].build(
        _processing,
        false,
        _fields.last.name == name,
      );

  Form _buildForm() => Form(
        autovalidate: _autovalidate,
        key: _formKey,
        child: Column(
          children: <Widget>[
            _buildField('serial_first'),
            SizedBox(height: 8),
            _buildField('serial_last'),
            SizedBox(height: 8),
            _processing
                ? SambazaLoader('Assigning serials')
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
                  child: Text('ASSIGN'),
                  focusNode: null,
                  onPressed: !_processing ? _save : null,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ],
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

  SambazaField _fieldNamed(String name) => _fieldBuilders[name].field;

  void _handleError(Exception error) {
    print(error);
  }

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

  Future<LPOItem> _prepareItem() async {
    if (ModalRoute.of(context).settings.arguments is! LPOItem) {
      throw SambazaException('Expected "LPO Item" to be passed to this page.');
    }
    _lpoItem ??= ModalRoute.of(context).settings.arguments;
    return _lpoItem;
  }

  void _save() {
    _validate().then((_) {
      setState(() {
        _processing = true;
      });
      return _lpoItem.assignSerial(
          _fieldNamed('serial_first').value, _fieldNamed('serial_last').value);
    }).then((_) {
      Navigator.pop(context, _lpoItem.fields);
    }).catchError((e) {
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
    }).whenComplete(() {
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
    _fields
        .firstWhere((SambazaField field) => field.$invalid)
        .focusNode
        .requestFocus();
    throw SambazaException(
      'A field(s) in the form is/are invalid',
      'Form Error',
    );
  }
}
