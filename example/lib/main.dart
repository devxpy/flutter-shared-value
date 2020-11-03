import 'package:flutter/material.dart';
import 'package:shared_value/shared_value.dart';

// This global SharedValue can be shared across the entire app
final SharedValue<int> counter = SharedValue(
  value: 0, // initial value
  key: "counter", // disk storage key for shared_preferences
  autosave: true, // autosave to shared prefs when value changes
);

Future<void> main() async {
  runApp(SharedValue.wrapApp(MyApp())); //  don't forget this!
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // The .of(context) bit makes this widget rebuild everytime counter is changed
    int counterValue = counter.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$counterValue',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    counter.load(); // load previous value from shared prefs
  }

  Future<void> _incrementCounter() async {
    // update counter value and rebuild all widgets using that value
    counter.update((value) => value + 1);
  }
}
