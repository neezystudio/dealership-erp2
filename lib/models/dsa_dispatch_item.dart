import 'dispatch_item.dart';
import '../resources.dart';

class DSADispatchItem extends DispatchItem<DSADispatchResource> {
  num get serialFirst;
  set serialFirst(s);
  num get serialLast;
  set serialLast(s);

  DSADispatchItem.create(DSADispatchResource dispatchResource,
      [Map<String, dynamic> dispatchItem])
      : super.create(dispatchResource, dispatchItem);

  DSADispatchItem.from(
      DSADispatchResource dispatchResource, Map<String, dynamic> dispatchItem)
      : super.from(dispatchResource, dispatchItem);

  static String serialFormatter(num serial) {
    String s = serial.toInt().toString();
    return s.length > 5
        ? s.length > 8
            ? '${s.substring(0, 2)}**${s.substring(s.length - 5)}'
            : '**${s.substring(s.length - 5)}'
        : s;
  }
}
