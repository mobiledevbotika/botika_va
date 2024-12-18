import 'dart:async';
import 'dart:collection';

class FutureQueue<T> {
  Queue<Future<T> Function()>? _taskQueue;

  bool _isProcessing = false;

  Function()? onStop;

  void add(Future<T> Function() task) {
    _taskQueue ??= Queue<Future<T> Function()>();
    _taskQueue!.add(task);
  }

  void run() {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;

    _run();
  }

  void _run() {
    if (_taskQueue != null) {
      if (_isProcessing) {
        _executeNextTask().then((_) => _run());
        return;
      }
    }

    _onStop();
  }

  Future<void> _executeNextTask() async {
    if (_taskQueue != null) {
      if (_taskQueue!.isNotEmpty) {
        Future<T> Function() task = _taskQueue!.removeFirst();
        await task();
      }
    }
    if (_taskQueue != null) {
      if (_taskQueue!.isEmpty) {
        _isProcessing = false;
      }
    }
  }

  void _onStop() {
    if (onStop != null) {
      onStop!();
    }
  }

  void stop() {
    _isProcessing = false;
    if (_taskQueue != null) {
      _taskQueue!.clear();
      _taskQueue = null;
    }
  }
}
