[![pub package](https://img.shields.io/pub/v/shared_value.svg?style=for-the-badge)](https://pub.dartlang.org/packages/shared_value)

# Shared Value

A wrapper over [InheritedModel](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html),
 this module allows users to easily share global state between multiple widgets.

## Usage

1. Initialize
    
```dart
main() {
    /// Insert Shared Value into the widget tree.
    runApp(SharedValue.wrapApp(MyApp()));
}

/// Create a Shared Value object that holds the value of a counter.
/// ("counter" is used as key for shared_preferences).
var counter = SharedValue("counter", value: 0);
```

2. Use

```dart
/// Use `counter` anywhere.
print(counter.value);

/// Muatate `counter` anywhere.
counter.mutate((value) {
    return value + 1;
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

3. Persist

```dart
/// Store counter to shared preferences.
counter.load();

/// Load counter's value from shared preferences.
counter.store();
```
