import '../state_notifier.dart';
import '../service.dart';
import '../../state.dart';

mixin SambazaServiceStateNotifier on SambazaService, SambazaStateNotifier {
  @override
  late SambazaState state;

  @override
  void register(SambazaState state) {
    this.state = state;
    return super.register(state);
  }
}
