

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import '../upstate.dart';

part 'maps.dart';
part 'state_list.dart';
part 'state_value.dart';

abstract class StateElement {
  StateElement _parent;
  bool _removedFromStateTree = false;
  bool notifyAncestors;
  bool useNums;

  final StreamController<StateElementChangeRecord> _changes = StreamController.broadcast();

  dynamic toPrimitive();

  StateElement get parent => _parent;

  bool get isRoot => this is StateObject;

  bool get removedFromStateTree => _removedFromStateTree;

  Stream<StateElementChangeRecord> get changes {
    return _changes.stream;
  }


  //notifies subscribers of a value to a and optionally all ancestor state elements
  void notifyChange() {
    if (_removedFromStateTree) {
      throw ('State element has been removed from the state tree and can\'t be modified');
    } else {
      _changes.add(StateElementChangeRecord.changed);
      if (notifyAncestors && !isRoot) {
        parent.notifyChange();
      }
    }
  }



  void removeFromStateTree() {
    
    _changes.add(StateElementChangeRecord.removedFromStateTree);
    _changes.close();

    //recursively removes children from tree;
    if (this is StateMap) {
      var map = this as StateMap;
      map.forEach((key, stateElement) {
        stateElement.removeFromStateTree();
      });
    } else if (this is StateList) {
      var list = this as StateList;
      list.forEach((stateElement) {
        stateElement.removeFromStateTree();
      });
    }
    _removedFromStateTree = true;
  }

  String toJson(){
    return jsonEncode(toPrimitive());
  }

  
}

class StatePath extends ListBase {
  List _path;

  StatePath(List path) {
    path.forEach((key) {
      if(!(key is int || key is String)){
        throw('StatePaths must contain only Strings or ints');
      }
     });
     _path=path;
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
    if(!(value is int || value is String)){
        throw('StatePaths must contain only Strings or ints');
      }
    _path[index] = value;
  }

  @override
  List toList({growable = true}) {
    return List.from(_path);
  }

  
}

//Not currently using removedFromStateTree. Maybe there's a use case?
enum StateElementChangeRecord { changed, removedFromStateTree }

StateElement _toStateElement(obj, StateElement parent, bool useNums) {
  if (obj is Map) {
    return StateMap(obj, parent);
  } else if (obj is List) {
    return StateList(obj, parent);
  } else if (obj is num) {
    if(useNums){
      return StateValue<num>(obj, parent);
    } else if(obj is int){
      return StateValue<int>(obj,parent);
    } else{
      return StateValue<double>(obj, parent);
    }
  }  else if (obj is String){
    return StateValue<String>(obj, parent);
  } else if (obj is bool){
    return StateValue<bool>(obj, parent);
  } else if (obj == null){
    return NullableStateValue(parent);
  }
  else {
    throw ("All elements in the state tree must be of type double, int, bool, String, Map, List or null. Instead element"
        "$obj was of type ${obj.runtimeType}");
  }
}
