import 'package:meta/meta.dart';

class  SambazaOption {

  final String optionText;
  final dynamic value;

  SambazaOption({
    @required this.optionText,
    @required this.value,
  });

  String toString() => '{"optionText":"$optionText, "value":"$value"}';

}