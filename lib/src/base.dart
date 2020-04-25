import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import '../upstate.dart';
import 'dart:math';

part 'maps.dart';
part 'state_list.dart';
part 'state_value.dart';

abstract class StateElement<T> {
  final _StateIterable parent;
  bool _removedFromStateTree = false, notifyParent, useNums, stronglyTyped, nullable;
  StateValue Function(dynamic value, StateElement parent) converter;


  StateElement(this.parent) {
    if (parent != null) {
      notifyParent = parent.notifyParent;
      useNums = parent.useNums;
      stronglyTyped = parent.stronglyTyped;
      converter = parent.converter;
    }
  }

  final StreamController<StateElementNotification> _notifications =
      StreamController.broadcast();

  dynamic toPrimitive();

  bool get isRoot => this is StateObject;

  bool get removedFromStateTree => _removedFromStateTree;

  Stream<StateElementNotification> get notifications => _notifications.stream;

  //These 4 are awkward but needed to do something like stateOjb['path']['deeper'][1].value
  StateElement operator [](key){
    throw('State element must be a map or list to use [] operator');
  }
  
  operator []=(key, value){
    throw('State element must be a map or list to use [] operator');
  }

  get value{
    throw('State element must be a StateValue to get or set a value');
  }

  set value(T newValue){
    throw('State element must be a StateValue to get or set a value');
  }
  

  StateValue instantiate(value);

  //notifies subscribers of a value to a and optionally all ancestor state elements
  void notifyChange() {
    if (removedFromStateTree) {
      throw ('State element has been removed from the state tree and can\'t be modified');
    } else {
      _notifications.add(StateElementNotification.changed);
      if (notifyParent && !isRoot) {
        parent.notifyChange();
      }
    }
  }

  void _removeFromStateTree() {
    _notifications.add(StateElementNotification.removedFromStateTree);
    _notifications.close();

    //recursively removes children from tree;
    if (this is StateMap) {
      var map = this as StateMap;
      map.forEach((key, stateElement) {
        stateElement._removeFromStateTree();
      });
    } else if (this is StateList) {
      var list = this as StateList;
      list.forEach((stateElement) {
        stateElement._removeFromStateTree();
      });
    }
    _removedFromStateTree = true;
  }

  String toJson() {
    return jsonEncode(toPrimitive());
  }
 
//uncomment to perform tests
  @visibleForTesting
  void removeFromStateTree() {
    _removeFromStateTree();
  }
}

class StatePath extends ListBase {
  List _path;

  StatePath(List path) {
    path.forEach((key) {
      if (!(key is int || key is String)) {
        throw ('StatePaths must contain only Strings or ints');
      }
    });
    _path = path;
  }

  factory StatePath.from(StatePath path) {
    return StatePath(path.toList());
  }

  int get length => _path.length;

  set length(int newLength) {
    _path.length = newLength;
  }

  dynamic operator [](int index) => _path[index];

  void operator []=(int index, value) {
    if (!(value is int || value is String)) {
      throw ('StatePaths must contain only Strings or ints');
    }
    _path[index] = value;
  }

  @override
  List toList({growable = true}) {
    return List.from(_path);
  }
}

enum StateElementNotification { changed, instantiated, removedFromStateTree }

StateElement _toStateElement(obj, StateElement parent) {

  if( parent!=null && parent.converter!=null){
    StateElement elem = parent.converter(obj,parent);
    if(elem!=null){
      return elem;
    }
  }

  if (obj is List) {
    return StateList(obj, parent);
  } else if (obj is Map) {
    return StateMap(obj, parent);
  } else if (!parent.stronglyTyped) {
    return StateValue<dynamic>(obj, parent);
  } else {
    switch (obj.runtimeType) {
      case String:
        {
          return StateValue<String>(obj, parent);
        }

      case bool:
        {
          return StateValue<bool>(obj, parent);
        }

      case Null:
        {
          if(parent.nullable){
            return StateValue<dynamic>(obj, parent);
          } else if(!parent.nullable){
            return StateValue<Null>(obj, parent);
          }
          
        }
      break;
      case int:
        {
          if (parent.useNums) {
            return StateValue<num>(obj, parent);
          } else {
            return StateValue<int>(obj, parent);
          }
        }
        break;

      case double:
        {
          if (parent.useNums) {
            return StateValue<num>(obj, parent);
          } else {
            return StateValue<double>(obj, parent);
          }
        }
        break;

      default:
        {
          throw ("All elements in the state tree must be of type double, int, bool, String, Map, List or null unless you set "
          "stronglyTyped:false or use a converter");
        }
    }
  }

}

abstract class _StateIterable extends StateElement {
  _StateIterable(_StateIterable parent) : super(parent);

  void _instantiateNullWithValue(
      StateValue<Null> oldElement, StateValue newElement);
}
