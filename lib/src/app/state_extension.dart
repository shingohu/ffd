import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

extension SafeSetState on State {
  safeSetState(VoidCallback fn) {
    final schedulerPhase = SchedulerBinding.instance!.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        setState(fn);
      });
    } else {
      setState(fn);
    }
  }
}
