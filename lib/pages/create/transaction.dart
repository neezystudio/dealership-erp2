import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../services/all.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class CreateTransactionPage extends StatelessWidget {
  static String route = '/transactions/create';

  const CreateTransactionPage({super.key});

  static CreateTransactionPage create(BuildContext context) =>
      CreateTransactionPage();

  @override
  Widget build(BuildContext context) => SambazaCreatePage(
        form: _CreateTransactionForm(),
        title: 'File a new transaction',
      );
}

class _CreateTransactionForm extends StatefulWidget {
  @override
  _CreateTransactionFormState createState() => _CreateTransactionFormState();
}

class _CreateTransactionFormState
    extends SambazaInjectableWidgetState<_CreateTransactionForm> {
  bool _autovalidate = false, _valid = false, _processing = false;
  final Map<String, SambazaFieldBuilder> _fieldBuilders =
      <String, SambazaFieldBuilder>{};
  final List<SambazaField> _fields = <SambazaField>[
    SambazaField.text(
      label: 'Reference Number',
      name: 'reference_number',
      placeholder: 'Enter a reference number',
      require: true,
    ),
    SambazaField.select<TransactionMethod>(
      label: 'Method',
      name: 'method',
      options: TransactionMethod.values,
      optionBuilder: (TransactionMethod method) => SambazaOption(
        optionText: method.toString().split('.').last.toUpperCase(),
        value: method.toString().split('.').last,
      ),
      placeholder: 'Select a Method',
      require: true,
      type: 'text',
    ),
    SambazaField.number(
      label: 'Value',
      name: 'value',
      placeholder: 'Enter the value',
      require: true,
    ),
    SambazaField.textArea(
      label: 'Description',
      name: 'description',
      placeholder: 'Add some notes',
    ),
  ];
  @override
  final List<Type> $inject = <Type>[SambazaAPI, SambazaStorage];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    for (var field in _fields) {
      _addFieldBuilder(field, field.name);
    }
  }

  @override
  Widget template(BuildContext context) => Form(
        autovalidateMode: _autovalidate ,
        key: _formKey,
        child: Column(
          children: <Widget>[
            _buildField('reference_number'),
            SizedBox(height: 8),
            _buildField('method'),
            SizedBox(height: 8),
            _buildField('value'),
            SizedBox(height: 8),
            _buildField('description'),
            SizedBox(height: 8),
            _processing
                ? SambazaLoader('Creating transaction')
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
                  child: Text('SUBMIT'),
                  focusNode: null,
                  onPressed: !_processing ? _submit : null,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
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

  SambazaFieldBuilder _createFieldBuilder(SambazaField field) =>
      SambazaFieldBuilder.of(
        field,
        onChanged: _onFieldChanged(field),
        onComplete: _onFieldEditingComplete(field),
        onSubmit: _onFieldSubmitted(field),
      );

  SambazaField _field(String name) => _fieldBuilders[name].field;

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

  void _submit() {
    _validate().then<Transaction>((_) {
      setState(() {
        _processing = true;
      });
      return Transaction.create(<String, dynamic>{
        'description': _field('description').value,
        'method': _field('method').value,
        'reference_number': _field('reference_number').value,
        'value': _field('value').value,
      });
    }).then<Transaction>((Transaction transaction) async {
      await transaction.save();
      return transaction;
    }).then((Transaction transaction) {
      Navigator.pop(context, transaction.fields);
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
    }).whenComplete(() {
      setState(() {
        _processing = false;
      });
    });
  }

  Future<void> _validate() {
    setState(() {
      _valid = _formKey.currentState.validate();
      _autovalidate = _valid == false;
    });
    if (_valid) {
      _formKey.currentState.save();
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
