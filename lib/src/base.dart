

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'maps.dart';
import 'state_list.dart';
import 'state_value.dart';

abstract class StateElement {
  StateElement parent;
  bool _removedFromStateTree = false;
  bool notifyAncestors;

  final StreamController<StateElementChangeRecord> _changes = StreamController.broadcast();

  dynamic toPrimitive();


  bool get isRoot {
    return this is StateObject;
  }

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
    
    // _changes.add(ChangeRecord.removedFromStateTree);
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

StateElement toStateElement(obj, StateElement parent) {
  if (obj is Map) {
    return StateMap(obj, parent);
  } else if (obj is List) {
    return StateList(obj, parent);
  } else if (obj is double||obj is int || obj is String||obj is bool||obj==null) {
    return StateValue(obj, parent);
  } 
  else {
    throw ("All elements in the state tree must be of type double, int, bool, String, Map, List or null. Instead element"
        "$obj was of type ${obj.runtimeType}");
  }
}
