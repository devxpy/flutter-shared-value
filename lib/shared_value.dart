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
  static late final StateManagerWidgetState stateManager =
      StateManagerWidgetState();
  static final stateNonceMap = <SharedValue, double>{};

  static bool didWrap = false;

  /// Initalize Shared value.
  ///
  /// Internally, this inserts an [InheritedModel] widget into the widget tree.
  ///
  /// This must be done exactly once for the whole application.
  static Widget wrapApp(Widget app) {
    didWrap = true;
    return StateManagerWidget(app, stateManager, stateNonceMap);
  }

  T _value;

  double? nonce;
  StreamController<T>? _controller;

  /// The key to use for storing this value in shared preferences.
  final String? key;

  /// automatically save to shared preferences when the value changes
  final bool autosave;

  /// customize encode function
  final String Function(T val)? customEncode;

  /// customize decode function
  final T Function(String val)? customDecode;

  /// customize save function
  final Future<void> Function(T val)? customSave;

  /// customize load function
  final Future<T> Function()? customLoad;

  SharedValue({
    this.key,
    required T value,
    this.autosave = false,
    this.customEncode,
    this.customDecode,
    this.customLoad,
    this.customSave,
  }) : _value = value {
    _update(init: true);
  }

  /// The value held by this state.
  T get $ => _value;

  /// Update the value and rebuild the dependent widgets if it changed.
  set $(T newValue) {
    setState(() {
      _value = newValue;
    });
  }

  /// Rebuild all dependent widgets.
  R? setState<R>([R? Function()? fn]) {
    if (!didWrap) {
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

    R? ret = fn?.call();

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
  T of(BuildContext? context) {
    if (context != null) {
      InheritedModel.inheritFrom<SharedValueInheritedModel>(
        context,
        aspect: this,
      );
    }
    return _value;
  }

  /// A stream of [$]s that gets updated everytime the internal value is changed.
  Stream<T> get stream {
    _controller ??= StreamController.broadcast();
    return _controller!.stream;
  }

  /// Set [$] to [value], but only if they're different
  void setIfChanged(T value) {
    if (value == $) return;
    $ = value;
  }

  /// Set [$] to the return value of [fn],
  /// and rebuild the dependent widgets if it changed.
  void update(T Function(T) fn) {
    $ = fn(_value);
  }

  void _update({init: false}) {
    // update the nonce
    nonce = random.nextDouble();
    stateNonceMap[this] = nonce!;

    if (!init) {
      // rebuild state manger widget
      stateManager.rebuild();
    }

    // add value to stream
    _controller?.add($);

    if (!init && autosave) {
      save();
    }
  }

  Future<T> waitUntil(bool Function(T) predicate) async {
    // short-circuit if predicate already satisfied
    if (predicate($)) return $;
    // otherwise, run predicate on every change
    await for (T value in this.stream) {
      if (predicate(value)) break;
    }
    return $;
  }

  /// Try to load the value stored at [key] in shared preferences.
  /// If no value is found, return immediately.
  /// Else, udpdate [$] and rebuild dependent widgets if it changed.
  Future<void> load() async {
    if (customLoad == null) {
      assert(key != null);
      final pref = await SharedPreferences.getInstance();
      final str = pref.getString(key!);
      if (str == null) return;
      $ = deserialize(str);
    } else {
      $ = await customLoad!();
    }
  }

  /// Store the current [$] at [key] in shared preferences.
  Future<void> save() async {
    if (customSave == null) {
      assert(key != null);
      final toSave = serialize(_value);
      final pref = await SharedPreferences.getInstance();
      await pref.setString(key!, toSave);
    } else {
      await customSave!(_value);
    }
  }

  /// serialize [obj] of type [T] for shared preferences.
  String serialize(T obj) {
    if (customEncode == null) {
      return jsonEncode(obj);
    } else {
      return customEncode!(obj);
    }
  }

  /// desrialize [str] to an obj of type [T] for shared preferences.
  T deserialize(String str) {
    if (customDecode == null) {
      return jsonDecode(str) as T;
    } else {
      return customDecode!(str);
    }
  }
}
