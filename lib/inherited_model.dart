import 'package:flutter/widgets.dart';

import 'shared_value.dart';

class SharedValueInheritedModel extends InheritedModel<SharedValue> {
  final Map<SharedValue, double> stateNonceMap;

  const SharedValueInheritedModel({
    Key key,
    Widget child,
    @required this.stateNonceMap,
  }) : super(key: key, child: child);

  // fallback to updateShouldNotifyDependent()
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  @override
  bool updateShouldNotifyDependent(
    SharedValueInheritedModel oldWidget,
    Set<SharedValue> dependencies,
  ) {
    for (SharedValue sharedValue in dependencies) {
      // Compare the nonce value of this SharedValue,
      // with an older nonce value of the same SharedValue object.
      //
      // If the nonce values are not same,
      // rebuild the widget
      if (sharedValue.nonce != oldWidget.stateNonceMap[sharedValue]) {
        return true;
      }
    }
    return false;
  }
}
