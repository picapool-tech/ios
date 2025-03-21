import 'package:get/get.dart';

mixin ReactiveLoading<T> {
  final RxMap<T, RxBool> _loadingStates = <T, RxBool>{}.obs;

  RxBool getLoadingState(T buttonId) {
    // Make sure the state exists in the map
    if (!_loadingStates.containsKey(buttonId)) {
      _loadingStates[buttonId] = false.obs;
    }

    // Create a computed reactive value that watches the map entry
    return _loadingStates[buttonId]!;
  }

  bool isloadingStates(T buttonId) {
    return _loadingStates[buttonId]?.value ?? false;
  }

  void startLoading(T buttonId) {
    _setLoading(buttonId, true);
  }

  void stopLoading(T buttonId) {
    _setLoading(buttonId, false);
  }

  void _setLoading(T buttonId, bool isLoading) {
    getLoadingState(buttonId).value = isLoading;
  }
}
