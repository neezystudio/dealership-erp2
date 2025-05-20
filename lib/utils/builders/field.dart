import 'package:flutter/material.dart';

import '../field.dart';
import '../option.dart';

typedef SambazaFormFieldBuilder =
    FormField<String> Function(
      bool disabled,
      bool focus, [
      void Function(SambazaField) onComplete,
      void Function(SambazaField) onSubmit,
    ]);

void _onSubmitDefault(String s) {}
void _onCompleteDefault() {}
void _onChangedDefault(String? s) {}

class SambazaFieldBuilder {
  final SambazaField field;
  final void Function(String?) onChanged;
  final void Function() onComplete;
  final void Function(String) onSubmit;

  SambazaFieldBuilder.of(
    this.field, {
    this.onChanged = _onChangedDefault,
    this.onComplete = _onCompleteDefault,
    this.onSubmit = _onSubmitDefault,
  });

  DropdownMenuItem<String> _buildMenuItem(SambazaOption option) =>
      DropdownMenuItem(value: option.value, child: Text(option.optionText));

  Widget build(bool disabled, bool focus, bool last) => field.autofillWrap(
    field.options.isNotEmpty
        ? _buildDropdown(disabled)
        : _buildText(disabled, focus, last),
  );

  DropdownButtonFormField<String> _buildDropdown(
    bool disabled,
  ) => DropdownButtonFormField<String>(
    decoration: InputDecoration(
      enabled: !disabled,
      labelText: field.require ? '${field.label} *' : field.label,
      hintText: field.placeholder,
    ),
    isDense: true,
    items: field.options.map<DropdownMenuItem<String>>(_buildMenuItem).toList(),
    onChanged: onChanged,
    onSaved: (value) => field.handleSaved(value ?? ''),
    validator: (value) => field.validator(value ?? ''),
    value: field.preliminaryValue,
  );

  TextFormField _buildText(bool disabled, bool focus, bool last) =>
      TextFormField(
        autovalidateMode: AutovalidateMode.disabled,
        autofocus: focus,
        controller: field.controller,
        decoration: InputDecoration(
          labelText: field.require ? '${field.label} *' : field.label,
          hintText: field.placeholder,
        ),
        enabled: !disabled,
        focusNode: field.focusNode,
        keyboardType: field.inputType,
        maxLines: field.type == 'textarea' ? 3 : 1,
        obscureText: field.type == 'password',
        onEditingComplete: _onEditingComplete,
        onFieldSubmitted: onSubmit,
        onSaved: (value) => field.handleSaved(value ?? ''),
        textInputAction: last ? TextInputAction.go : TextInputAction.next,
        validator: (value) => field.validator(value ?? ''),
      );

  void _onEditingComplete() {
    field.handleEditingComplete();
    onComplete();
  }
}
