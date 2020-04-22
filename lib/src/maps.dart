import 'dart:collection';
import 'dart:async';
import 'base.dart';
import '../upstate.dart';
import 'package:flutter/widgets.dart';
import 'state_list.dart';


// StateMap is an unmodifiable map<String, StateElement>
class StateMap extends StateElement with MapMixin<String, StateElement> {
  Map<String, StateElement> _map;
  final StateElement parent;
  bool notifyAncestors;

  StateMap(Map<String, dynamic> map, [this.parent])
      : notifyAncestors = parent.notifyAncestors {
    _map = toStateElementMap(map, this);
  }

 
  Iterable<String> get keys => _map.keys;

  StateElement operator [](key) => _map[key];

  operator []=(key, value) {
    throw ('StateMaps are immutable.');
  }

  void clear() {
    throw ('StateMaps are immutable.');
  }

  remove(key) {
    throw ('StateMaps are immutable.');
  }
}

class StateObject extends StateMap {
  bool notifyAncestors;
  StateObject(Map<String, dynamic> map, {this.notifyAncestors = true})
      : super(map);

  static of<T extends StateWidget>(BuildContext context) {
    var stateWidget = context.findAncestorWidgetOfExactType<T>();
    return stateWidget.state;
    
  }
  
  StreamSubscription subscribeTo(StatePath path, Function callback) {
    StateElement element=this;
    StatePath newPath = StatePath.from(path);

    while(newPath.isNotEmpty){
      if(element is StateMap && newPath.first is String){
        var elem = element as StateMap;
        element = elem[newPath.first];
      } else if(element is StateList && newPath.first is int){
        var elem = element as StateList;
        element = elem[newPath.first];
      } else{
        throw('Invalid state path for state: $this');
      }
    }

    return element.changes.listen((event) {callback();});
    
  }
}

Map<String, StateElement> toStateElementMap(
    Map<String, dynamic> map, StateElement parent) {
  var newMap = Map.from(map);
  newMap.updateAll((key, value) {
    return toStateElement(value, parent);
  });
  return newMap;
}
