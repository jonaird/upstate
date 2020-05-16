import 'package:flutter/material.dart';
import 'package:upstate/upstate.dart';

// subclass state widget to use multiple states
class GlobalState extends StateWidget{
  GlobalState({@required StateObject state, @required Widget child}): super(state:state,child:child);
}


class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    // var state = 
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GlobalState(
              state:StateObject({'counter': 0}),
              child: StateWidget(
                state:StateObject({"some":{"other":['state','object']}}),
                child: MyHomePage()),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var counter = StateObject.of<GlobalState>(context)['counter'];//set generic for a specific state widget
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
            StateBuilder<GlobalState>(
                paths: [StatePath(['counter'])], // will rebuild when any value at this path changes
                builder: (BuildContext context, StateObject state) {
                  return Text(
                    state['counter'].value.toString(),
                    style: Theme.of(context).textTheme.headline4,
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){counter.value++;},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
