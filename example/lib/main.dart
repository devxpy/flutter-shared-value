import 'package:flutter/material.dart';
import 'package:shared_value/shared_value.dart';

// This SharedValue can be shared from any number of widgets.
final counter = SharedValue(
  value: 0, // initial value
  key: "counter", // disk storage key for shared_preferences
);

void main() {
  runApp(SharedValue.wrapApp(MyApp()));
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
    var counterValue = counter.of(context);

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

    // Load the previously stored value of counter to disk using shared_preferences
    counter.load();
  }

  Future<void> _incrementCounter() async {
    setState(() {});
    // update counter value and rebuild all widgets using that value
    counter.update((value) => value + 1);

    // Save the internal value of counter to disk using shared_preferences
    await counter.save();
  }
}
