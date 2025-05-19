import 'dart:async';
import 'package:flutter_autofill/flutter_autofill.dart';
import 'package:flutter/material.dart';

import '../models/all.dart';
import '../services/all.dart';
import '../state.dart';
import '../utils/all.dart';
import '../widgets/all.dart';
import 'app.dart';
import 'forgot-password.dart';

class LoginPage extends SambazaInjectableStatelessWidget {
  static String route = '/login';

  final List<Type> $inject = <Type>[SambazaAuth];

  static LoginPage create(BuildContext context) => LoginPage();

  @override
  Widget template(BuildContext context) => Scaffold(
        body: WillPopScope(
          child: Column(
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
                'Sign in to continue',
                style: Theme.of(context).textTheme.headline,
              ),
              Expanded(
                child: Container(
                  child: _LoginForm(),
                  padding: EdgeInsets.all(16.0),
                ),
              ),
            ],
          ),
          onWillPop: () async {
            if ($$<SambazaAuth>().token.isEmpty) {
              await FlutterAutofill.cancel();
            }
            return true;
          },
        ),
      );
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends SambazaInjectableWidgetState<_LoginForm> {
  bool _autovalidate = false, _valid = false, _processing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, SambazaFieldBuilder> _fieldBuilders =
      <String, SambazaFieldBuilder>{};
  final List<SambazaField> _fields = <SambazaField>[
    SambazaField.email(
      autocomplete: true,
      label: 'Email Address',
      name: 'email',
      placeholder: 'Enter your email address',
      require: true,
    ),
    SambazaField.password(
      autocomplete: true,
      label: 'Password',
      name: 'password',
      minlength: 8,
      placeholder: 'Enter your password',
      require: true,
    ),
  ];
  final List<Type> $inject = <Type>[SambazaAPI, SambazaAuth, SambazaStorage];

  @override
  void dispose() {
    _fields.forEach((SambazaField field) {
      field.destroy();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fields.forEach((SambazaField field) {
      _addFieldBuilder(field, field.name);
    });
  }

  @override
  Widget template(BuildContext context) => Form(
        autovalidate: _autovalidate,
        child: ListView(
          children: <Widget>[
            _buildField('email'),
            SizedBox(height: 8),
            _buildField('password'),
            SizedBox(height: 8),
            SizedBox(
              child: _processing ? SambazaLoader('Signing in') : null,
              height: 35,
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text('Forgot password?'),
                  focusNode: null,
                  onPressed: !_processing ? _forgotPassword : null,
                  textColor: Colors.black87,
                ),
                Expanded(
                  child: SizedBox(height: 8),
                ),
                RaisedButton(
                  child: Text('SIGN IN'),
                  focusNode: null,
                  onPressed: !_processing ? _login : null,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ],
          shrinkWrap: true,
        ),
        key: _formKey,
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
        _fieldBuilders.values.last.field.name == name,
      );

  SambazaFieldBuilder _createFieldBuilder(SambazaField field) =>
      SambazaFieldBuilder.of(
        field,
        onComplete: _onFieldEditingComplete(field),
        onSubmit: _onFieldSubmitted(field),
      );

  void _forgotPassword() {
    Navigator.pushNamed(context, ForgotPasswordPage.route).then((result) {
      if (result == true) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
            children: <Widget>[
              Text('SENT'),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                    'An email with a link to reset your password has been sent. Please check your inbox.'),
              ),
            ],
          ),
        ));
      }
    });
  }

  void _handleError(Exception error) {
    print(error);
  }

  void Function() _onFieldEditingComplete(SambazaField field) => () {
        if (_fields.last == field) {
          _validate().catchError(_handleError);
        }
      };

  void Function(String) _onFieldSubmitted(SambazaField field) =>
      (String value) {
        if (_fields.last == field) {
          _validate().catchError(_handleError);
        } else {
          _fields
              .elementAt(_fields.indexOf(field) + 1)
              .focusNode
              .requestFocus();
        }
      };

  void _login() async {
    try {
      await _validate();
      setState(() {
        _processing = true;
      });
      await FlutterAutofill.commit();
      Map<String, dynamic> credentials = _fieldBuilders.map<String, dynamic>(
        (String name, SambazaFieldBuilder builder) =>
            MapEntry(name, builder.field.value),
      );
      Map<String, dynamic> jwtResult = await SambazaResource(
        SambazaAPIEndpoints.accounts,
        '/login',
      ).$save(
        credentials,
      );
      $$<SambazaAuth>().jwt = jwtResult['token'].toString();
      User user = $$<SambazaAuth>().user;
      Map<String, dynamic> tokenResult = await SambazaResource(
        SambazaAPIEndpoints.accounts,
        '/login/token',
      ).$save(
        credentials,
      );
      $$<SambazaAuth>().token = tokenResult['key'].toString();
      if (user.role == SambazaAuthRole.other) {
        $$<SambazaAuth>().clear();
        $$<SambazaStorage>().clear();
        throw SambazaException(
          'You are not allowed to log in here. Use your browser instead.',
          'Forbidden',
        );
      }
      String fcmToken = $$<SambazaStorage>()
          .$get(SambazaState.FCM_TOKEN_STORAGE_KEY)
          .toString();
      await user.pull();
      Profile profile = user.profile;
      if (profile.deviceToken != fcmToken) {
        profile.deviceToken = fcmToken;
        await user.update();
      }
      setState(() {
        _processing = false;
      });
      final bool args = ModalRoute.of(context).settings.arguments ?? false;
      if (args) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, AppPage.route);
      }
    } on SambazaException catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Text('ERROR'),
              SizedBox(width: 8.0),
              Expanded(
                child: Text('${e.title} - ${e.message}'),
              ),
            ],
          ),
        ),
      );
      setState(() {
        _processing = false;
      });
    } catch (e) {
      _handleError(e);
    }
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
    return Future.error(
      SambazaException(
        'A field(s) in the form is/are invalid',
        'Form Error',
      ),
    );
  }
}
