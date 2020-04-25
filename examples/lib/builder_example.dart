import 'package:flutter/material.dart';
import 'package:upstate/upstate.dart';

void main() {
 runApp(StateWidget(
    state: StateObject({'counter': 1}), 
    child: MyApp()));
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  StateObject state;

  void _incrementCounter() {
    state(StatePath(['counter'])).value++; //you can use the call method with a state value to get a value
  }

  @override
  Widget build(BuildContext context) {
    state = StateObject.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            StateBuilder(
                paths: [StatePath(['counter'])], // will rebuild when any value at this path changes
                builder: (BuildContext context, StateObject state, child) {
                  return Text(
                    state['counter'].value.toString(),
                    style: Theme.of(context).textTheme.headline4,
                  );
                }),
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
