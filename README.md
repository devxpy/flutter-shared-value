[![pub package](https://img.shields.io/pub/v/shared_value.svg?style=for-the-badge)](https://pub.dartlang.org/packages/shared_value)

# Shared Value

A wrapper over [InheritedModel](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html),
 this module allows users to easily share global state between multiple widgets.

It's a no-boilerplate generalization of the `Provider` state management solution.

## Usage

*1. Initialize*
    
```dart
main() {
    // Insert Shared Value into the widget tree.
    runApp(SharedValue.wrapApp(MyApp()));
}

// Create a `SharedValue` object that holds the value of our counter.
var counter = SharedValue(value: 0);
```

*2. Use*

```dart
// Use [counter] anywhere, even without a `BuildContext`
print(counter.value);

// Update [counter] anywhere.
counter.update((value) => value + 1);

// Rebuild [MyWidget] whenever [counter] changes.
class MyWidgetState extends State<MyWidget> {
    @override
    Widget build(BuildContext context) {

        // supply [counter] the `BuildContext` to rebuild widget
        counterValue = counter.of(context);

        return Text("Counter: $counterValue");
    }
}
```

*3. Persist*

```dart
// provide a shared_prefences key
var counter = SharedValue(value: 0, key: "counter");

// Store [counter]'s value to shared preferences
await counter.store();

// Load [counter]'s value from shared preferences
await counter.load();
```

## Efficiency

Shared value is smart enough to only rebuild the widget that is using the shared value that was updated. No more, no less.


