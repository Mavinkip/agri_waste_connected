import 'package:flutter/foundation.dart';

class ScheduleNotifier extends ChangeNotifier {
  static final ScheduleNotifier instance = ScheduleNotifier._();
  ScheduleNotifier._();

  bool _updated = false;
  bool get updated => _updated;

  void markUpdated() { _updated = true; notifyListeners(); }
  void consume() { _updated = false; }
}
