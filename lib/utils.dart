import 'package:flutter/material.dart' show BuildContext, Navigator;
import 'package:flutter/scheduler.dart' show SchedulerBinding;

typedef ContextCallback = void Function(BuildContext);

void goToRouteAsap(BuildContext context, String routeName, {Object arguments}) {
  // waits for stuff to settle down before pushing
  SchedulerBinding.instance.addPostFrameCallback(
    (_) => Navigator.pushReplacementNamed(context, routeName, arguments: arguments)
  );
} 

void doItAsap(BuildContext context, ContextCallback doStuff) {
  // waits for stuff to settle down before doing stuff
  SchedulerBinding.instance.addPostFrameCallback(
    (_) => doStuff(context)
  );
} 