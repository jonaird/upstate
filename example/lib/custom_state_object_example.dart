import 'package:flutter/material.dart';
import 'package:upstate/upstate.dart';


class CustomStateWidget extends InheritedWidget{
  final MyState state;
  CustomStateWidget({@required this.state,Widget child, Key key}):super(key:key);

  @override
  bool updateShouldNotify(CustomStateWidget oldWidget) {
    if(oldWidget.state!=state){
      oldWidget.state.unmount();
      return true;
    } else{
      return false;
    }
  }
}


class MyState {
  final stateObject=StateObject({'counter': Counter()}, typeSafety:TypeSafety.complete, converter:converter);
  final counterPath = StatePath<CounterModel>(['counter']);


  CounterModel get counter => stateObject(counterPath);

  void unmount()=>stateObject.unmount();

  MyState of<T extends CustomStateWidget>(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<T>()?.state;
  }
}

class Counter {
  var count = 0;
}

class CounterModel extends StateElement {
  final Counter _counter;

  CounterModel(Counter counter, StateElement parent)
      : _counter = counter,
        super(parent);

  int get count => _counter.count;

  void increment() {
    _counter.count++;
    notifyChange();
  }

  @override
  toPrimitive() {
    // TODO: implement toPrimitive
    throw UnimplementedError();
  }
}

StateElement converter(element, parent){
  if(element is Counter){
    return CounterModel(element,parent);
  } else{
    return null;
  }
}