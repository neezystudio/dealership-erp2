import '../state.dart';

mixin SambazaStateNotifier {

  SambazaState get state;

  void notifyState() {
    state.appStateChanged();
  }

}
