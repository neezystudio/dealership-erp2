import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../services/all.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class CreateServiceRequestPage extends StatelessWidget {
  static String route = '/service-requests/create';

  const CreateServiceRequestPage({super.key});

  static CreateServiceRequestPage create(BuildContext context) =>
      CreateServiceRequestPage();

  @override
  Widget build(BuildContext context) => SambazaCreatePage(
    form: _CreateServiceRequestForm(),
    title: 'Make a service request',
  );
}

class _CreateServiceRequestForm extends StatefulWidget {
  @override
  _CreateServiceRequestFormState createState() =>
      _CreateServiceRequestFormState();
}

class _CreateServiceRequestFormState
    extends SambazaInjectableWidgetState<_CreateServiceRequestForm> {
  bool _autovalidate = false, _valid = false, _processing = false;
  final Map<String, SambazaFieldBuilder> _fieldBuilders =
      <String, SambazaFieldBuilder>{};
  final List<SambazaField> _fields = <SambazaField>[
    SambazaField.text(
      label: 'Title',
      name: 'title',
      placeholder: 'Provide a title',
      require: true,
    ),
    SambazaField.number(
      label: 'Amount',
      name: 'amount',
      placeholder: 'Enter a value',
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
    autovalidateMode:
        _autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildField('title'),
        SizedBox(height: 8),
        _buildField('amount'),
        SizedBox(height: 8),
        _buildField('description'),
        SizedBox(height: 8),
        _processing
            ? SambazaLoader('Creating transaction')
            : SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              focusNode: null,
              onPressed:
                  !_processing
                      ? () {
                        Navigator.pop(context, null);
                      }
                      : null,
              child: Text('Cancel', style: TextStyle(color: Colors.black87)),
            ),
            Expanded(child: SizedBox(height: 8)),
            ElevatedButton(
              focusNode: null,
              onPressed: !_processing ? _submit : null,
              child: Text('SUBMIT'),
            ),
          ],
        ),
      ],
    ),
  );

  String _addFieldBuilder(SambazaField field, [String? builderName]) {
    builderName ??= '${field.name}${_fieldBuilders.length}';
    field.init();
    _fieldBuilders[builderName] = _createFieldBuilder(field);
    return builderName;
  }

  Widget _buildField(String name) =>
      _fieldBuilders[name]?.build(
        _processing,
        false,
        _fields.last.name == name,
      ) ??
      SizedBox.shrink();

  SambazaFieldBuilder _createFieldBuilder(SambazaField field) =>
      SambazaFieldBuilder.of(
        field,
        onChanged: _onFieldChanged(field),
        onComplete: _onFieldEditingComplete(field),
        onSubmit: _onFieldSubmitted(field),
      );

  SambazaField _field(String name) {
    final builder = _fieldBuilders[name];
    if (builder == null) {
      throw Exception("Field builder for '$name' not found.");
    }
    return builder.field;
  }

  void _handleError(Exception error) {
    print(error);
  }

  void Function() _onFieldEditingComplete(SambazaField field) => () {
    if (_fieldBuilders.values.last.field == field) {
      _validate().catchError(_handleError);
    }
  };

  void Function(String?) _onFieldChanged(SambazaField field) => (
    String? value,
  ) {
    setState(() {
      field.controller.value = TextEditingValue(text: value ?? '');
    });
  };

  void Function(String?) _onFieldSubmitted(SambazaField field) => (
    String? value,
  ) {
    List<SambazaField> f =
        _fieldBuilders.values
            .map<SambazaField>((SambazaFieldBuilder builder) => builder.field)
            .toList();
    if (f.last == field) {
      _validate().catchError(_handleError);
    } else {
      f.elementAt(f.indexOf(field) + 1).focusNode.requestFocus();
    }
  };

  void _submit() {
    _validate()
        .then<ServiceRequest>((_) {
          setState(() {
            _processing = true;
          });
          return ServiceRequest.create(<String, dynamic>{
            'amount': _field('amount').value,
            'description': _field('description').value,
            'title': _field('title').value,
          });
        })
        .then<ServiceRequest>((ServiceRequest request) async {
          await request.save();
          return request;
        })
        .then((ServiceRequest request) {
          Navigator.pop(context, request.fields);
        })
        .catchError((e) {
          if (e is SambazaException) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: <Widget>[
                    Text('ERROR'),
                    SizedBox(width: 8.0),
                    Expanded(child: Text('${e.title} - ${e.message}')),
                  ],
                ),
              ),
            );
          }
          if (e is Exception) {
            _handleError(e);
          }
        })
        .whenComplete(() {
          setState(() {
            _processing = false;
          });
        });
  }

  Future<void> _validate() async {
    setState(() {
      _valid = _formKey.currentState?.validate() ?? false;
      _autovalidate = _valid == false;
    });
    if (_valid) {
      _formKey.currentState?.save();
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
