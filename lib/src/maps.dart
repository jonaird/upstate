import 'dart:collection';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'base.dart';
import '../upstate.dart';
import 'state_list.dart';

// StateMap is an unmodifiable map<String, StateElement>
class StateMap extends StateElement with MapMixin<String, StateElement> {
  Map<String, StateElement> _map;
  final StateElement parent;
  bool notifyAncestors;

  StateMap(Map<String, dynamic> map, [this.parent])
      {
        if(this.parent!=null){
          notifyAncestors=parent.notifyAncestors;
        }
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

  Map toPrimitive(){
    var newMap = Map.from(_map);
    newMap.updateAll((key, value) => value.toPrimitives());
    return newMap;
  }

}

class StateObject extends StateMap {
  bool notifyAncestors;

  StateObject(Map<String, dynamic> map,
      {bool elementsShouldNotifyAncestors = true})
      : notifyAncestors = elementsShouldNotifyAncestors,
        super(map);

  factory  StateObject.fromJson(String json, {bool elementsShouldNotifyAncestors = true}){
    var map = jsonDecode(json);
    return StateObject(map,elementsShouldNotifyAncestors: elementsShouldNotifyAncestors);
  }


  static of<T extends StateWidget>(BuildContext context) =>context.dependOnInheritedWidgetOfExactType<T>().state;
  
  StateValue call(StatePath path){
    return getElementAtPath(path);
  }

  StateElement getElementAtPath(StatePath path){
    StateElement element = this;
    StatePath newPath = StatePath.from(path);

    while (newPath.isNotEmpty) {
      if ((element is StateMap && newPath.first is String)||(element is StateList && newPath.first is int)) {
        var elem = element as StateMap;
        element = elem[newPath.first];
        newPath.removeAt(0);
      } else {
        throw ('Invalid state path for state: $this');
      }
    }
    return element;
  }


  StreamSubscription subscribeTo(StatePath path, VoidCallback callback) {
    StateElement element = getElementAtPath(path);
    return element.changes.listen((event) {
      callback();
    });
  }
}

Map<String, StateElement> toStateElementMap(
    Map<String, dynamic> map, StateElement parent) {
  var newMap = Map.from(map);

  
  newMap.updateAll((key, value) {
    return toStateElement(value, parent);
  });
  return newMap.cast<String,StateElement>();
}
