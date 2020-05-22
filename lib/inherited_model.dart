import 'package:flutter/widgets.dart';

import 'shared_value.dart';

class SharedValueInheritedModel extends InheritedModel<SharedValue> {
  final Map<SharedValue, double> stateNonceMap;

  const SharedValueInheritedModel({
    Key key,
    Widget child,
    @required this.stateNonceMap,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  @override
  bool updateShouldNotifyDependent(
    SharedValueInheritedModel oldWidget,
    Set<SharedValue> dependencies,
  ) {
    for (var state in dependencies) {
      // Compare the nonce value of this SharedValue,
      // with an older nonce value of the same SharedValue object.
      //
      // If the nonce values are not same,
      // rebuild the widget
      if (state.nonce != oldWidget.stateNonceMap[state]) {
        return true;
      }
    }
    return false;
  }
}
