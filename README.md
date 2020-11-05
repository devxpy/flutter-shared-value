[![pub package](https://img.shields.io/pub/v/shared_value.svg?style=for-the-badge)](https://pub.dartlang.org/packages/shared_value)

# Shared Value

A wrapper over [InheritedModel](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html),
 this module allows you to easily manage global state in flutter apps.

At a high level, `SharedValue` puts your variables in an intelligent "container" that is flutter-aware.

It can be viewed as a low-boilerplate generalization of the `Provider` state management solution.

## Usage

*1. Initialize*
    
```dart
// This global SharedValue can be shared across the entire app
final SharedValue<int> counter = SharedValue(
  value: 0, // initial value (optional)
);

main() {
  runApp(
    // don't forget this!
    SharedValue.wrapApp(
      MyApp(),
    ),
  );
}
```

*2. Use*

Unlike other state management solutions,
SharedValue works everywhere you'd expect dart code to work, even without a `BuildContext`.

```dart
// Read [counter]
print(counter.value);

// Update [counter]
counter.value += 1;

// Use [counter] in widgets, and let shared value do the rest.
Widget build(BuildContext context) {

  // The .of(context) bit makes this widget rebuild automatically
  int counterValue = counter.of(context);

  return Text("Counter: $counterValue");
}
```

*3. Persist*

```dart
// provide a shared_prefences key
final SharedValue<int> counter = SharedValue(
  key: "counter", // disk storage key for shared_preferences (optional)
  autosave: true, // autosave to shared prefs when value changes (optional)
);

// Load [counter]'s value from shared preferences
await counter.load();

// Store [counter]'s value to shared preferences (enabling `autosave` does this automatically)
await counter.store();
```

*4. Be cool*

Use `.$` as an alias for `.value` :)

```
print(counter.$);
```

## Efficiency

Shared value is smart enough to only rebuild the widget that subscribes to updates using `.of(context)`, no more, no less.
