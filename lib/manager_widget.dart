import 'package:flutter/widgets.dart';

import 'shared_value.dart';
import 'inherited_model.dart';

class StateManagerWidget extends StatefulWidget {
  final Widget child;
  final StateManagerWidgetState state;
  final Map<SharedValue, double> stateNonceMap;

  const StateManagerWidget(
    this.child,
    this.state,
    this.stateNonceMap, {
    Key key,
  }) : super(key: key);

  @override
  StateManagerWidgetState createState() {
    return state;
  }
}

class StateManagerWidgetState extends State<StateManagerWidget> {
  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GlobalStateInheritedModel(
      child: widget.child,
      // IMPORTANT!
      // A copy of stateNonceMap must be provided here.
      //
      // If the same object is passed,
      // then GlobalStateInheritedModel won't be able to compare nonce values,
      // since the mutations will be propagated throughout the code path.
      stateNonceMap: Map.of(widget.stateNonceMap),
    );
  }
}
