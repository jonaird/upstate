import 'package:flutter/material.dart';
import 'package:upstate/upstate.dart';

void main() {
  //State is stored in State widgets that provide their state to ancestors
  runApp(StateWidget(state: StateObject({'counter': 1}), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with StateConsumerMixin {
  StateObject state;
  var counterPath = StatePath(['counter']);

  void _incrementCounter() {
    state(counterPath).value++; //Use the call method with a StatePath
  }

  @override
  void didChangeDependencies() {
    cancelSubscriptions();
    state = StateObject.of(context);
    subscribeToPaths([counterPath], state);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    cancelSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
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
              '${state['counter'].value}', //or use [] operators
              style: Theme.of(context).textTheme.headline4,
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
}
