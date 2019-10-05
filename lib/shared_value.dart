library shared_value;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'inherited_model.dart';
import 'manager_widget.dart';

typedef T SetStateCallback<T>(T value);

class SharedValue<T> {
  static var random = Random();
  static StateManagerWidgetState stateManager;
  static Map<SharedValue, double> stateNonceMap = {};

  /// Initalize Shared value.
  ///
  /// Internally, this inserts an [InheritedModel] widget into the widget tree.
  static Widget wrapApp(Widget app) {
    stateManager = StateManagerWidgetState();
    return StateManagerWidget(app, stateManager, stateNonceMap);
  }

  double nonce = random.nextDouble();
  T _value;
  StreamController<T> _controller;

  /// The key to use for storing this value in shared preferences.
  String prefKey;

  SharedValue(this.prefKey, {T value}) {
    _value = value;
    _updateNonce();
  }

  /// The value held by this state.
  T get value => _value;

  /// Get the value held by this state,
  /// and also rebuild the widget in [context] whenever [mutate] is called.
  T of(BuildContext context) {
    InheritedModel.inheritFrom<SharedValueInheritedModel>(
      context,
      aspect: this,
    );
    return _value;
  }

  /// A stream of [value]s that gets updated everytime [mutate] is called.
  Stream get stream {
    if (_controller == null) {
      _controller = StreamController();
    }
    return _controller.stream.asBroadcastStream();
  }

  /// Update the value that this state holds,
  /// and rebuild all widgets that called [of] on this state.
  void mutate(SetStateCallback<T> fn) {
    var newValue = fn(_value);
    if (newValue == _value) return;

    _value = newValue;
    _updateNonce();
    _controller?.add(_value);

    if (stateManager == null) {
      throw FlutterError.fromParts([
        ErrorSummary("SharedValue was not initalized."),
        ErrorHint(
          "Did you forget to call SharedValue.wrapApp()?\n"
          "If so, please do it once,"
          "alongside runApp() so that SharedValue can be initalized for you application.\n"
          "Example:\n"
          "\trunApp(SharedValue.wrapApp(MyApp()))",
        )
      ]);
    }
    stateManager.rebuild();
  }

  void _updateNonce() {
    nonce = random.nextDouble();
    stateNonceMap[this] = nonce;
  }

  /// Try to load the value stored at [prefKey] in shared preferences.
  /// If no value is found, return immediately.
  /// Else, call [mutate] and update [value].
  Future<void> load() async {
    var pref = await SharedPreferences.getInstance();
    var str = pref.getString(prefKey);
    if (str == null) return;
    mutate((_) {
      return deserialize(str);
    });
  }

  /// Store the current [value] at [prefKey] in shared preferences.
  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setString(prefKey, serialize(_value));
  }

  /// serialize [obj] of type [T].
  String serialize(T obj) {
    return jsonEncode(obj);
  }

  /// desrialize [str] to an obj of type [T].
  T deserialize(String str) {
    return jsonDecode(str) as T;
  }
}
