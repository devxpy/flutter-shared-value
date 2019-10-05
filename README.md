[![pub package](https://img.shields.io/pub/v/global_state.svg?style=for-the-badge)](https://pub.dartlang.org/packages/global_state)

# global_state
    
```dart
main() {
    /// Insert Global State into the widget tree.
    runApp(GlobalState.wrapApp(MyApp()));
}

/// Create a Global State object that holds the value of a counter.
/// ("counter" is used as key for shared_preferences).
var counter = GlobalState("counter", value: 0);
```

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

```dart
/// Store counter to shared preferences.
counter.load();

/// Load counter's value from shared preferences.
counter.store();
```
