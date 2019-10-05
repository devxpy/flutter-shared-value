[![pub package](https://img.shields.io/pub/v/global_state.svg?style=for-the-badge)](https://pub.dartlang.org/packages/global_state)

# Shared Value

A wrapper over flutter's [InheritedModel](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html),
 shared value allows users to easily share a global state value between multiple widgets.

## Usage

- initiate
    
```dart
main() {
    /// Insert Shared Value into the widget tree.
    runApp(SharedValue.wrapApp(MyApp()));
}

/// Create a Shared Value object that holds the value of a counter.
/// ("counter" is used as key for shared_preferences).
var counter = SharedValue("counter", value: 0);
```

- use

```dart
/// Use `counter` anywhere.
print(counter.value);

/// Muatate `counter` anywhere.
counter.mutate((value) {
    value += 1;
});

/// Rebuild widgets whenever `counter` changes.
class MyWidgetState extends State<MyWidget> {
    @override
    Widget build(BuildContext context) {
        counterValue = counter.of(context);
        ...
    }
}
```

- persist

```dart
/// Store counter to shared preferences.
counter.load();

/// Load counter's value from shared preferences.
counter.store();
```
