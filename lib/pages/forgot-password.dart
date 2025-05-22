import 'dart:async';
import 'package:flutter/material.dart';

import '../services/all.dart';
import '../utils/all.dart';
import '../widgets/loader.dart';

class ForgotPasswordPage extends StatelessWidget {
  static String route = '/forgot-password';

  const ForgotPasswordPage({super.key});

  static ForgotPasswordPage create(BuildContext context) =>
      ForgotPasswordPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Image(
              fit: BoxFit.contain,
              height: 150,
              image: AssetImage('assets/images/logo.png'),
            ),
          ),
        ),
        Text(
          'Provide your email',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: _ForgotPasswordForm(),
          ),
        ),
      ],
    ),
  );
}

class _ForgotPasswordForm extends StatefulWidget {
  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState
    extends SambazaInjectableWidgetState<_ForgotPasswordForm> {
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _valid = false, _processing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SambazaField _field = SambazaField.email(
    autocomplete: true,
    label: 'Email Address',
    name: 'email',
    placeholder: 'Enter your email address',
    require: true,
  );
  @override
  final List<Type> $inject = <Type>[SambazaAPI];
  final SambazaResource _resource = SambazaResource(
    SambazaAPIEndpoints.accounts,
    '/password/reset',
  );

  SambazaFieldBuilder get fieldBuilder => SambazaFieldBuilder.of(
    _field,
    onComplete: onFieldEditingComplete,
    onSubmit: onFieldSubmitted,
  );

  @override
  void dispose() {
    _field.destroy();
    super.dispose();
  }

  @override
  void initState() {
    _field.init();
    super.initState();
  }

  @override
  Widget template(BuildContext context) => Form(
    autovalidateMode: _autovalidateMode,
    key: _formKey,

    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        fieldBuilder.build(_processing, true, true),
        Expanded(
          child:
              _processing
                  ? SambazaLoader('Sending reset email')
                  : SizedBox(width: 1.0),
        ),
        Row(
          children: <Widget>[
            TextButton(
              onPressed:
                  !_processing
                      ? () {
                        Navigator.pop(context, false);
                      }
                      : null,
              child: Text(
                'Back to login',
                style: TextStyle(color: Colors.black87),
              ),
            ),

            Expanded(child: SizedBox(height: 8)),
            ElevatedButton(
              onPressed: !_processing ? _submit : null,
              child: Text('SEND LINK'),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ],
    ),
  );

  void _handleError(Exception error) {
    print(error);
  }

  void onFieldEditingComplete() => onFieldSubmitted('');

  void onFieldSubmitted(String value) {
    _validate().catchError(_handleError);
  }

  void _submit() {
    _validate()
        .then((x) {
          setState(() {
            _processing = true;
          });
        })
        .then(
          (x) => _resource.$save(<String, dynamic>{_field.name: _field.value}),
        )
        .then((Map<String, dynamic> result) {
          Navigator.pop(context, true);
        })
        .catchError((e) {
          if (e is SambazaException) {
            showSnackBar('ERROR', '${e.title} - ${e.message}');
          }
          _handleError(e);
        })
        .whenComplete(() {
          setState(() {
            _processing = false;
          });
        });
  }

  Future<void> _validate() async {
    setState(() {
      _valid = _formKey.currentState!.validate();
      _autovalidateMode = (_valid == false) as AutovalidateMode;
    });
    if (_valid) {
      _formKey.currentState?.save();
      return Future.value();
    }
    _field.focusNode.requestFocus();
    throw SambazaException(
      'A field(s) in the form is/are invalid',
      'Form Error',
    );
  }
}
