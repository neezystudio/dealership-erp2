import 'dart:async';
import 'package:flutter/material.dart';

import '../services/all.dart';
import '../state.dart';
import '../utils/all.dart';
import '../widgets/all.dart';
import 'app.dart';
import 'forgot-password.dart';

class LoginPage extends SambazaInjectableStatelessWidget {
  static String route = '/login';

  @override
  final List<Type> $inject = <Type>[SambazaAuth];

  LoginPage({super.key});

  static LoginPage create(BuildContext context) => LoginPage();

  @override
  Widget template(BuildContext context) => Scaffold(
    body: WillPopScope(
      onWillPop: () async => true,
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
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: _LoginForm(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends SambazaInjectableWidgetState<_LoginForm> {
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _valid = false, _processing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, SambazaFieldBuilder> _fieldBuilders = <String, SambazaFieldBuilder>{};

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

  @override
  final List<Type> $inject = <Type>[SambazaAPI, SambazaAuth, SambazaStorage];

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
    autovalidateMode: _autovalidateMode,
    key: _formKey,
    child: ListView(
      shrinkWrap: true,
      children: <Widget>[
        _buildField('email'),
        SizedBox(height: 8),
        _buildField('password'),
        SizedBox(height: 8),
        SizedBox(
          height: 35,
          child: _processing ? SambazaLoader('Signing in') : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              onPressed: !_processing ? _forgotPassword : null,
              child: Text('Forgot password?'),
            ),
            Expanded(child: SizedBox(height: 8)),
            ElevatedButton(
              onPressed: !_processing ? _login : null,
              child: Text('SIGN IN'),
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

  Widget _buildField(String name) => _fieldBuilders[name]!.build(
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
    Navigator.pushNamed< bool>(context, ForgotPasswordPage.route).then((result) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: <Widget>[
                Text('SENT'),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'An email with a link to reset your password has been sent. Please check your inbox.',
                  ),
                ),
              ],
            ),
          ),
        );
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

  void Function(String) _onFieldSubmitted(SambazaField field) => (String value) {
    if (_fields.last == field) {
      _validate().catchError(_handleError);
    } else {
      _fields.elementAt(_fields.indexOf(field) + 1).focusNode.requestFocus();
    }
  };

  void _login() async {
    try {
      await _validate();
      setState(() => _processing = true);

      final credentials = _fieldBuilders.map(
        (name, builder) => MapEntry(name, builder.field.value),
      );

      final jwtResult = await SambazaResource(
        SambazaAPIEndpoints.accounts,
        '/login',
      ).$save(credentials);
      $$<SambazaAuth>().jwt = jwtResult['token'].toString();

      final user = $$<SambazaAuth>().user;

      final tokenResult = await SambazaResource(
        SambazaAPIEndpoints.accounts,
        '/login/token',
      ).$save(credentials);
      $$<SambazaAuth>().token = tokenResult['key'].toString();

      if (user!.role == SambazaAuthRole.other) {
        $$<SambazaAuth>().clear();
        $$<SambazaStorage>().clear();
        throw SambazaException(
          'You are not allowed to log in here. Use your browser instead.',
          'Forbidden',
        );
      }

      final fcmToken = $$<SambazaStorage>()
          .$get(SambazaState.FCM_TOKEN_STORAGE_KEY)
          .toString();
      await user.pull();

      final profile = user.profile;
      if (profile.deviceToken != fcmToken) {
        profile.deviceToken = fcmToken;
        await user.update();
      }

      setState(() => _processing = false);

      final args = ModalRoute.of(context)?.settings.arguments ?? false;
      if (args == true) {
        Navigator.pop<void>(context);
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed<void, void>(context, AppPage.route);
      }
    } on SambazaException catch (e) {
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
      setState(() => _processing = false);
    } catch (e) {
      _handleError(e as Exception);
    }
  }

  Future<void> _validate() {
    setState(() {
      _valid = _formKey.currentState!.validate();
      _autovalidateMode = _valid ? AutovalidateMode.always : AutovalidateMode.disabled;
    });
    if (_valid) {
      _formKey.currentState!.save();
      return Future.value();
    }
    _fields
        .firstWhere((field) => field.$invalid)
        .focusNode
        .requestFocus();
    return Future.error(
      SambazaException('A field(s) in the form is/are invalid', 'Form Error'),
    );
  }
}
