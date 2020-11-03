library shared_value;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'inherited_model.dart';
import 'manager_widget.dart';

class SharedValue<T> {
  static final random = Random();
  static StateManagerWidgetState stateManager;
  static final stateNonceMap = <SharedValue, double>{};

  /// Initalize Shared value.
  ///
  /// Internally, this inserts an [InheritedModel] widget into the widget tree.
  ///
  /// This must be done exactly once for the whole application.
  static Widget wrapApp(Widget app) {
    stateManager = StateManagerWidgetState();
    return StateManagerWidget(app, stateManager, stateNonceMap);
  }

  double nonce;
  T _value;
  StreamController<T> _controller;

  /// The key to use for storing this value in shared preferences.
  final String key;

  /// automatically save to shared preferences when the value changes
  final bool autosave;

  SharedValue({this.key, T value, this.autosave = false}) {
    _value = value;
    _update(rebuild: false);
  }

  /// Alias for [value]
  T get $ => value;

  /// Alias for [value]
  set $(T newValue) {
    value = newValue;
  }

  /// The value held by this state.
  T get value => _value;

  /// Update [value] and rebuild the dependent widgets if it changed.
  set value(T newValue) {
    if (newValue == _value) return;
    setState(() {
      _value = newValue;
    });
  }

  /// Rebuild all dependent widgets.
  R setState<R>([R Function() fn]) {
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

    var ret = fn?.call();

    if (ret is Future) {
      ret.then((_) {
        _update();
      });
    } else {
      _update();
    }

    return ret;
  }

  /// Get the value held by this state,
  /// and also rebuild the widget in [context] whenever [mutate] is called.
  T of(BuildContext context) {
    InheritedModel.inheritFrom<SharedValueInheritedModel>(
      context,
      aspect: this,
    );
    return _value;
  }

  /// A stream of [value]s that gets updated everytime the internal value is changed.
  Stream<T> get stream {
    _controller ??= StreamController.broadcast();
    return _controller.stream;
  }

  /// Update [value] using the return value of [fn],
  /// and rebuild the dependent widgets if it changed.
  void update(T Function(T) fn) {
    value = fn(_value);
  }

  void _update({rebuild: true}) {
    // update the nonce
    nonce = random.nextDouble();
    stateNonceMap[this] = nonce;

    if (rebuild) {
      // rebuild state manger widget
      stateManager.rebuild();
    }

    // add value to stream
    _controller?.add(value);

    if (autosave) {
      save();
    }
  }

  /// Try to load the value stored at [key] in shared preferences.
  /// If no value is found, return immediately.
  /// Else, udpdate [value] and rebuild dependent widgets if it changed.
  Future<void> load() async {
    assert(key != null);
    var pref = await SharedPreferences.getInstance();
    var str = pref.getString(key);
    if (str == null) return;
    value = deserialize(str);
  }

  /// Store the current [value] at [key] in shared preferences.
  Future<void> save() async {
    assert(key != null);
    var pref = await SharedPreferences.getInstance();
    await pref.setString(key, serialize(_value));
  }

  /// serialize [obj] of type [T] for shared preferences.
  String serialize(T obj) {
    return jsonEncode(obj);
  }

  /// desrialize [str] to an obj of type [T] for shared preferences.
  T deserialize(String str) {
    return jsonDecode(str) as T;
  }
}
