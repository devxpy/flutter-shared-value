import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'inherited_model.dart';
import 'shared_value.dart';

class StateManagerWidget extends StatefulWidget {
  final Widget child;
  final StateManagerWidgetState state;
  final Map<SharedValue, double> stateNonceMap;

  const StateManagerWidget(
    this.child,
    this.state,
    this.stateNonceMap, {
    Key? key,
  }) : super(key: key);

  @override
  StateManagerWidgetState createState() {
    return state;
  }
}

class StateManagerWidgetState extends State<StateManagerWidget> {
  Future<bool> rebuild() async {
    if (!mounted) return false;

    // if there's a current frame,
    if (SchedulerBinding.instance?.schedulerPhase != SchedulerPhase.idle) {
      // wait for the end of that frame.
      await SchedulerBinding.instance?.endOfFrame;
      if (!mounted) return false;
    }

    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SharedValueInheritedModel(
      child: widget.child,
      // IMPORTANT!
      // A copy of stateNonceMap must be provided here.
      //
      // If the same object is passed,
      // then SharedValueInheritedModel won't be able to compare nonce values,
      // since the mutations will be propagated throughout the code path.
      stateNonceMap: Map.of(widget.stateNonceMap),
    );
  }
}
