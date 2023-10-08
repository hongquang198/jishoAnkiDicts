import 'dart:async';

class ButtonDebouncer {
  final Duration delay;
  Timer? _timer;

  ButtonDebouncer({required this.delay});

  void call(void Function() action) {
    if (_timer?.isActive ?? false) {
      return;
    }
    _timer = Timer(delay, () => {});
    action.call();
  }
}
