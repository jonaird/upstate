import 'package:flutter/material.dart';
import 'package:upstate/upstate.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StateWidget(
        state:MyStateObject(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var counter = MyStateObject.of(context).counter;
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
            CustomStateBuilder(
                elements: [counter], // will rebuild when any value at this path changes
                builder: (BuildContext context) {
                  var state = MyStateObject.of(context);
                  return Text(
                    state.counter.count.toString(),
                    style: Theme.of(context).textTheme.headline4,
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counter.increment,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class MyStateObject extends RootStateElement {
  CounterModel _counter;
  

  MyStateObject() {
    _counter = CounterModel(this);
  }

  CounterModel get counter => _counter;

  static MyStateObject of<T extends StateWidget>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<T>()?.state;

  @override
  void unmount() {
    notifyRemovedFromState();
    _counter.notifyRemovedFromState();
  }
}

class CounterModel extends StateElement {
  int _count = 0;
  bool notifyParent = false;
  
  CounterModel(StateElement parent) : super(parent);

  int get count => _count;

  void increment() {
    _count++;
    notifyChange();
  }
}
