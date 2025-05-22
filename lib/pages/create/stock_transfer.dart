import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/all.dart';
import '../../resources.dart';
import '../../services/all.dart';
import '../../utils/all.dart';
import '../../widgets/all.dart';

class CreateStockTransferPage extends StatelessWidget {
  static String route = '/branch/transfers/create';

  const CreateStockTransferPage({super.key});

  static CreateStockTransferPage create(BuildContext context) =>
      CreateStockTransferPage();

  @override
  Widget build(BuildContext context) => SambazaCreatePage(
        form: _CreateStockTransferForm(),
        title: 'Transfer stock',
      );
}

class _CreateStockTransferForm extends StatefulWidget {
  @override
  _CreateStockTransferFormState createState() =>
      _CreateStockTransferFormState();
}

class _CreateStockTransferFormState
    extends SambazaInjectableWidgetState<_CreateStockTransferForm> {
  bool _autovalidate = false, _valid = false, _processing = false;
  final Map<String, SambazaFieldBuilder> _fieldBuilders =
      <String, SambazaFieldBuilder>{};
  final Map<String, void Function(SambazaField)> _fieldSwappers =
      <String, void Function(SambazaField)>{};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  final List<Type> $inject = <Type>[SambazaAPI, SambazaAuth, SambazaStorage];
  late Future<int> _loadFuture;

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
    super.initState();
    _loadFuture = Future.wait<void>(
      <Future<void>>[
        _listAirtime(),
        _listUsers(),
        _listBranches(),
      ],
      eagerError: true,
    ).then<int>((List<void> _) {
      _addFieldBuilder(
        SambazaField.select<StockTransferParty>(
          label: 'To',
          name: 'destination_type',
          options: StockTransferParty.values,
          optionBuilder: _buildStockTransferPartyOption,
          require: true,
          type: 'text',
        ),
        'destination_type',
      );
      _addFieldBuilder(
        SambazaField.select<StockTransferParty>(
          label: 'From',
          name: 'origin_type',
          options: StockTransferParty.values,
          optionBuilder: _buildStockTransferPartyOption,
          require: true,
          type: 'text',
        ),
        'origin_type',
      );
      _addFieldBuilder(
        SambazaField.text(
          label: 'Recipient',
          name: 'destination',
          placeholder: 'Select a recipient type',
        ),
        'to',
      );
      _addFieldBuilder(
        SambazaField.text(
          label: 'Donor',
          name: 'origin',
          placeholder: 'Select an donor type',
        ),
        'from',
      );
      return 1;
    });
  }

  @override
  Widget template(BuildContext context) => FutureBuilder<int>(
        builder: (
          BuildContext context,
          AsyncSnapshot<int> snapshot,
        ) {
          if (snapshot.hasData) {
            return _buildForm();
          } else if (snapshot.hasError) {
            return SambazaError(
              snapshot.error is SambazaException
                  ? snapshot.error as SambazaException
                  : SambazaException(
                      snapshot.error?.toString() ?? 'Unknown error',
                      'Error',
                    ),
              onButtonPressed: () {
                Navigator.of(context).pop();
              },
            );
          }
          return SambazaLoader('Loading...');
        },
        future: _loadFuture,
      );

  String _addFieldBuilder(SambazaField field, [String? builderName]) {
    builderName ??= '${field.name}${_fieldBuilders.length}';
    field.init();
    _fieldBuilders[builderName] = _createFieldBuilder(field);
    return builderName;
  }

  SambazaOption _buildAirtimeOption(Airtime airtime) => SambazaOption(
        optionText:
            '${airtime.$telco.name} - Bamba ${airtime.value.toInt().toString()}',
        value: airtime.id,
      );

  SambazaOption _buildBranchOption(Branch branch) => SambazaOption(
        optionText: branch.name,
        value: branch.id,
      );

  FormField<String> _buildField(String name) => _fieldBuilders[name]?.build(
        _processing,
        false,
        _fieldBuilders.values.last.field.name == name,
      ) as FormField<String>;

  Form _buildForm() => Form(
        autovalidateMode: _autovalidate
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        key: _formKey,
        child: Column(
          children: <Widget>[
            SambazaFieldRow(
              children: <Widget>[
                SambazaFieldRow.child(
                  field: _buildField('destination_type'),
                ),
                SambazaFieldRow.child(
                  field: _buildField('to'),
                  flex: 3,
                ),
              ],
            ),
            SambazaFieldRow(
              children: <Widget>[
                SambazaFieldRow.child(
                  field: _buildField('origin_type'),
                ),
                SambazaFieldRow.child(
                  field: _buildField('from'),
                  flex: 3,
                ),
              ],
            ),
            SambazaFieldRow(
              children: <Widget>[
                SambazaFieldRow.child(
                  field: _buildField('airtime'),
                  flex: 2,
                ),
                SambazaFieldRow.child(
                  field: _buildField('quantity'),
                ),
              ],
            ),
            SizedBox(height: 8),
            _processing
                ? SambazaLoader('Requesting transfer')
                : SizedBox(height: 35),
            Row(
              children: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  focusNode: null,
                  onPressed: !_processing
                      ? () {
                          Navigator.pop(context, null);
                        }
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                  ),
                ),
                Expanded(
                  child: SizedBox(height: 8),
                ),
                ElevatedButton(
                  child: Text('TRANSFER'),
                  focusNode: null,
                  onPressed: !_processing ? _transfer : null,
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      );

  SambazaOption _buildStockTransferPartyOption(StockTransferParty stp) =>
      SambazaOption(
        optionText: stp.toString().split('.').last,
        value: stp.toString().split('.').last,
      );

  SambazaOption _buildUserOption(User user) => SambazaOption(
        optionText: user.email,
        value: user.id,
      );

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

  void _handleError(Object error) {
    print(error);
  }

  Future<void> _listAirtime() => SambazaModel.list<Airtime>(
        AirtimeResource(),
        ([Map<String, dynamic> fields = const {}]) =>
            Airtime.create(fields),
      ).then(
        (SambazaModels<Airtime> airtimes) async {
          SambazaModels<Telco> telcos = await _listTelcos();
          List<Airtime> airtimeList = airtimes.list.map<Airtime>((Airtime a) {
            a.$telco = telcos.list.firstWhere((Telco t) => t.id == a.telco);
            return a;
          }).toList();
          _addFieldBuilder(
            SambazaField.select<Airtime>(
              label: 'Airtime',
              name: 'airtime',
              options: airtimeList,
              optionBuilder: _buildAirtimeOption,
              require: true,
              type: 'text',
            ),
            'airtime',
          );
          _addFieldBuilder(
            SambazaField.number(
              label: 'Quantity',
              min: 1,
              name: 'quantity',
              placeholder: 'Quantity',
              require: true,
              step: 1,
            ),
            'quantity',
          );
        },
      );

  Future<void> _listBranches() => SambazaModel.list<Branch>(
        BranchResource(),
        ([Map<String, dynamic> fields = const {}]) => Branch.create(fields),
      ).then((SambazaModels<Branch> branches) {
        _fieldSwappers[StockTransferParty.branch.toString().split('.').last] =
            (SambazaField swapperField) {
          _addFieldBuilder(
            SambazaField.select<Branch>(
              label: swapperField.name == 'destination_type'
                  ? 'Recipient'
                  : 'Donor',
              name: swapperField.name == 'destination_type'
                  ? 'destination'
                  : 'origin',
              options: branches.list,
              optionBuilder: _buildBranchOption,
              require: true,
              type: 'text',
            ),
            swapperField.name == 'destination_type' ? 'to' : 'from',
          );
        };
      });

  Future<SambazaModels<Telco>> _listTelcos() => SambazaModel.list<Telco>(
        TelcoResource(),
        ([Map<String, dynamic> fields = const {}]) => Telco.create(fields),
      );

  Future<void> _listUsers() => SambazaModel.list<User>(
        UserResource(),
        ([Map<String, dynamic> fields = const {}]) => User.create(fields),
      ).then((SambazaModels<User> users) {
        _fieldSwappers[StockTransferParty.dsa.toString().split('.').last] =
            (SambazaField swapperField) {
          _addFieldBuilder(
            SambazaField.select<User>(
              label: swapperField.name == 'destination_type'
                  ? 'Recipient'
                  : 'Donor',
              name: swapperField.name == 'destination_type'
                  ? 'destination'
                  : 'origin',
              options: users.list
                  .where(
                    (User user) => user.isDsa,
                  )
                  .toList(),
              optionBuilder: _buildUserOption,
              require: true,
              type: 'text',
            ),
            swapperField.name == 'destination_type' ? 'to' : 'from',
          );
        };
      });

  void Function() _onFieldEditingComplete(SambazaField field) => () {
        if (_fieldBuilders.values.last.field == field) {
          _validate().catchError(_handleError);
        }
      };

  void Function(String?) _onFieldChanged(SambazaField field) => (String? value) {
        setState(() {
          field.controller.value = TextEditingValue(text: value ?? '');
          if (<String>['destination_type', 'origin_type']
              .contains(field.name) && value != null) {
            if (_fieldSwappers[value] != null) {
              _fieldSwappers[value]!(field);
            }
          }
        });
      };

  void Function(String) _onFieldSubmitted(SambazaField field) =>
      (String value) {
        List<SambazaField> f = _fieldBuilders.values
            .map<SambazaField>(
              (SambazaFieldBuilder builder) => builder.field,
            )
            .toList();
        if (f.last == field) {
          _validate().catchError(_handleError);
        } else {
          f
              .elementAt(
                f.indexOf(field) + 1,
              )
              .focusNode
              .requestFocus();
        }
      };

  Future<void> _transfer() async {
    try {
      await _validate();
      setState(() {
        _processing = true;
      });
      StockTransfer transfer = StockTransfer.create(
        <String, dynamic>{
          'airtime': _field('airtime').value,
          'branch': $$<SambazaAuth>().user?.profile?.branch,
          'destination': _field('to').value,
          'destination_type': _field('destination_type').value,
          'origin': _field('from').value,
          'origin_type': _field('origin_type').value,
          'quantity': _field('quantity').value,
        },
      );
      await transfer.save();
      Navigator.pop(context, transfer.fields);
    } on SambazaException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
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
    } catch (e) {
      _handleError(e);
      setState(() {
        _processing = false;
      });
    }
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
    _fieldBuilders.values
        .firstWhere(
          (SambazaFieldBuilder fieldBuilder) => fieldBuilder.field.$invalid,
        )
        .field
        .focusNode
        .requestFocus();
    throw SambazaException(
      'A field(s) in the form is/are invalid',
      'Form Error',
    );
  }
}
