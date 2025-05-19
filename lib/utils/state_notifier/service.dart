import '../state_notifier.dart';
import '../service.dart';
import '../../state.dart';

mixin SambazaServiceStateNotifier on SambazaService, SambazaStateNotifier {
  SambazaState state;

  @override
  void register(SambazaState _state) {
    state = _state;
    return super.register(_state);
  }
}
