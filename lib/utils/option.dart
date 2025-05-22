
class  SambazaOption {

  final String optionText;
  final dynamic value;

  SambazaOption({
    required this.optionText,
    required this.value,
  });

  @override
  String toString() => '{"optionText":"$optionText, "value":"$value"}';

}