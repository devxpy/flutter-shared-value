import 'package:flutter/material.dart';
import 'package:shared_value/shared_value.dart';

// This global SharedValue can be shared across the entire app
final SharedValue<int> counter = SharedValue(
  value: 0, // initial value
  key: "counter", // disk storage key for shared_preferences
  autosave: true, // autosave to shared prefs when value changes
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load previous value from shared prefs
  counter.load();

  runApp(
    // don't forget this!
    SharedValue.wrapApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("MyApp.build()");

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Shared value demo"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              CounterText(),
            ],
          ),
        ),
        floatingActionButton: CounterButton(),
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("CounterText.build()");

    // The .of(context) bit makes this widget rebuild automatically
    int counterValue = counter.of(context);

    return Text(
      '$counterValue',
      style: Theme.of(context).textTheme.headline4,
    );
  }
}

class CounterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Button.build()");

    return FloatingActionButton(
      onPressed: _incrementCounter,
      tooltip: 'Increment',
      child: Icon(Icons.add),
    );
  }

  void _incrementCounter() {
    // update counter value and rebuild widgets
    counter.$ += 1;
  }
}
