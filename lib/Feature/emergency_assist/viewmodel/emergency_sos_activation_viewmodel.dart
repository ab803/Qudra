import 'dart:async';

import 'package:flutter/material.dart';

class EmergencySosActivationViewModel extends ChangeNotifier {
  EmergencySosActivationViewModel({
    this.totalMilliseconds = 3000,
  });

  final int totalMilliseconds;

  Timer? _timer;

  int remainingMilliseconds = 3000;
  bool isRunning = false;
  bool isCompleted = false;
  bool isCancelled = false;

  double get progress {
    final completed = totalMilliseconds - remainingMilliseconds;
    final value = completed / totalMilliseconds;
    return value.clamp(0.0, 1.0);
  }

  int get countdownNumber {
    final seconds = (remainingMilliseconds / 1000).ceil();
    return seconds <= 0 ? 0 : seconds;
  }

  String get countdownLabel {
    if (isCompleted) return 'تم التفعيل';
    return countdownNumber.toString();
  }

  void startCountdown() {
    if (isRunning || isCompleted) return;

    isRunning = true;
    isCancelled = false;
    remainingMilliseconds = totalMilliseconds;
    notifyListeners();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      remainingMilliseconds -= 100;

      if (remainingMilliseconds <= 0) {
        remainingMilliseconds = 0;
        isRunning = false;
        isCompleted = true;
        _timer?.cancel();
      }

      notifyListeners();
    });
  }

  void cancelCountdown() {
    _timer?.cancel();
    isRunning = false;
    isCancelled = true;
    isCompleted = false;
    remainingMilliseconds = totalMilliseconds;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}