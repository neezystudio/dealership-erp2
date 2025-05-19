import 'package:flutter_autofill/flutter_autofill.dart';
import 'package:flutter/material.dart';

import 'option.dart';

final Map<String, TextInputType> _textInputTypeMap = <String, TextInputType>{
  'datetime': TextInputType.datetime,
  'email': TextInputType.emailAddress,
  'number': TextInputType.number,
  'password': TextInputType.text,
  'tel': TextInputType.phone,
  'text': TextInputType.text,
  'textarea': TextInputType.multiline,
  'url': TextInputType.url,
};

class SambazaField {
  final bool autocomplete;
  TextEditingController controller;
  bool $dirty = false,
      $invalid = false,
      $pristine = true,
      $touched = false,
      $valid = false;
  final String label, name, placeholder, type;
  FocusNode focusNode;
  final TextInputType inputType;
  final num max, min, step;
  final int maxlength, minlength;
  final List<SambazaOption> options;
  final bool require, valueIsString;
  dynamic value;

  String get preliminaryValue => $touched ? controller.value.text : null;

  SambazaField({
    this.autocomplete = false,
    @required this.label,
    this.max,
    this.maxlength,
    this.min,
    this.minlength,
    @required this.name,
    this.options = const <SambazaOption>[],
    this.placeholder = '',
    this.require = false,
    this.step = 1,
    @required this.type,
  })  : inputType = _textInputTypeMap[type],
        valueIsString = [
          'email',
          'password',
          'select',
          'tel',
          'text',
          'textarea',
          'url'
        ].contains(type);

  Widget autofillWrap(FormField<String> child) => autocomplete
      ? Autofill(
          autofillHints: <String, List<String>>{
            'email': [FlutterAutofill.AUTOFILL_HINT_USERNAME],
            'password': [FlutterAutofill.AUTOFILL_HINT_PASSWORD],
          }[type] ?? [],
          autofillType: FlutterAutofill.AUTOFILL_TYPE_TEXT,
          child: child,
          onAutofilled: (dynamic value) {
            controller.value = TextEditingValue(
              text: value,
              selection: TextSelection.fromPosition(
                  TextPosition(offset: value.length)),
            );
          },
          textController: controller,
        )
      : child;

  void destroy() {
    focusNode.dispose();
    controller.removeListener(onChange);
    controller.dispose();
  }

  void handleEditingComplete() {
    focusNode.unfocus();
  }

  void handleSaved(String result) {
    if (valueIsString) {
      value = result;
    }
    if (type == 'number') {
      value = num.parse(result);
    }
  }

  void init() {
    focusNode = FocusNode();
    controller = TextEditingController();
    controller.addListener(onChange);
  }

  void onChange() {
    if ($pristine) {
      $pristine = false;
    }
    if (!$touched) {
      $touched = true;
    }
    $dirty = controller.value.text.isNotEmpty;
  }

  String toString() =>
      '{"label":"$label","max":"$max","maxlength":"$maxlength","min":"$min","minlength":"$minlength","name":"$name","preliminaryValue":"$preliminaryValue","required":"$require","step":"$step","type":"$type","value":"$value"}';

  String validator(String value) {
    if (require && $pristine && (value ?? '').isEmpty) {
        return 'This field is required';      
    }
    if ($touched) {
      _invalidate();
      if (require && value.isEmpty) {
        return 'This field is required';
      }
      if (type == 'email') {
        Pattern pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern);
        if (!regex.hasMatch(value)) return 'Please provide a valid email';
      }
      if (valueIsString) {
        if (maxlength != null && value.length > maxlength) {
          return 'This value must be less than ${maxlength + 1} characters';
        }
        if (minlength != null && value.length < minlength) {
          return 'This value must be more than ${minlength - 1} characters';
        }
      }
      if (type == 'number') {
        num val = num.parse(value);
        if (max != null && val > max) {
          return 'This value must be less than ${maxlength + step}';
        }
        if (min != null && val < min) {
          return 'This value must be less than ${maxlength - step}';
        }
      }
      _validate();
    }
    return null;
  }

  void _invalidate() {
    $invalid = true;
    $valid = false;
  }

  void _validate() {
    $valid = true;
    $invalid = false;
  }

  static SambazaField select<M extends Object>({
    @required String label,
    @required String name,
    @required List<M> options,
    @required SambazaOption Function(M) optionBuilder,
    String placeholder,
    bool require = false,
    @required String type,
  }) =>
      SambazaField(
        autocomplete: false,
        label: label,
        name: name,
        options: options.map<SambazaOption>(optionBuilder).toList(),
        placeholder: placeholder,
        require: require,
        type: type,
      );

  SambazaField.email({
    bool autocomplete = false,
    @required String label,
    @required String name,
    int maxlength,
    int minlength,
    String placeholder,
    bool require = false,
  }) : this(
          autocomplete: autocomplete,
          label: label,
          maxlength: maxlength,
          minlength: minlength,
          name: name,
          placeholder: placeholder,
          require: require,
          type: 'email',
        );

  SambazaField.number({
    @required String label,
    @required String name,
    num max,
    num min,
    String placeholder,
    bool require = false,
    num step,
  }) : this(
          autocomplete: false,
          label: label,
          max: max,
          min: min,
          name: name,
          placeholder: placeholder,
          require: require,
          step: step,
          type: 'number',
        );

  SambazaField.password({
    bool autocomplete = false,
    @required String label,
    @required String name,
    int maxlength,
    int minlength,
    String placeholder,
    bool require = false,
  }) : this(
          autocomplete: autocomplete,
          label: label,
          maxlength: maxlength,
          minlength: minlength,
          name: name,
          placeholder: placeholder,
          require: require,
          type: 'password',
        );

  SambazaField.tel({
    @required String label,
    @required String name,
    int maxlength,
    int minlength,
    String placeholder,
    bool require = false,
  }) : this(
          autocomplete: false,
          label: label,
          maxlength: maxlength,
          minlength: minlength,
          name: name,
          require: require,
          placeholder: placeholder,
          type: 'tel',
        );

  SambazaField.text({
    @required String label,
    @required String name,
    int maxlength,
    int minlength,
    String placeholder,
    bool require = false,
  }) : this(
          autocomplete: false,
          label: label,
          maxlength: maxlength,
          minlength: minlength,
          name: name,
          require: require,
          placeholder: placeholder,
          type: 'text',
        );

  SambazaField.textArea({
    @required String label,
    @required String name,
    int maxlength,
    int minlength,
    String placeholder,
    bool require = false,
  }) : this(
          autocomplete: false,
          label: label,
          maxlength: maxlength,
          minlength: minlength,
          name: name,
          require: require,
          placeholder: placeholder,
          type: 'textarea',
        );
}
