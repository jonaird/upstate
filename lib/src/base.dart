import 'dart:async';
import 'dart:collection';

import 'maps.dart';
import 'state_list.dart';
import 'state_value.dart';

abstract class StateElement {
  StateElement parent;
  bool _removedFromStateTree = false;
  bool notifyAncestors;

  final StreamController<ChangeRecord> _changes = StreamController.broadcast();


  //notifies subscribers of a change and all ancestor state elements
  void notifyChange() {
    if (_removedFromStateTree) {
      throw ('State element has been removed from the state tree and can\'t be modified');
    } else {
      _changes.add(ChangeRecord.changed);
      if (notifyAncestors && !isRoot) {
        parent.notifyChange();
      }
    }
  }

  bool get isRoot {
    return this is StateObject;
  }

  void removeFromTree() {
    _removedFromStateTree = true;
    _changes.add(ChangeRecord.removedFromStateTree);
    _changes.close();

    //recursively removes children from tree;
    if (this is StateMap) {
      var map = this as StateMap;
      map.forEach((key, stateElement) {
        stateElement.removeFromTree();
      });
    } else if (this is StateList) {
      var list = this as StateList;
      list.forEach((stateElement) {
        stateElement.removeFromTree();
      });
    }
  }

  bool get removedFromStateTree => _removedFromStateTree;

  Stream<ChangeRecord> get changes {
    return _changes.stream;
  }
}

class StatePath extends ListBase {
  List _path;

  StatePath(List path) {
    path.forEach((key) {
      if(!(key is int || key is String)){
        throw('StatePaths must only contain Strings or ints');
      }
     });
     _path=path;
  }

  factory StatePath.from(StatePath path) {
    return StatePath(path.toList());
  }

  int get length => _path.length;

  String operator [](int index) => _path[index];

  void operator []=(int index, value) {
    _path[index] = value;
  }

  @override
  List toList({growable = true}) {
    return List.from(_path);
  }

  set length(int newLength) {
    _path.length = newLength;
  }
}

enum ChangeRecord { changed, removedFromStateTree }

StateElement toStateElement(obj, StateElement parent) {
  if (obj is Map) {
    return StateMap(obj, parent);
  } else if (obj is List) {
    return StateList(obj, parent);
  } else if ((obj is double)||(obj is String)||(obj is bool)) {
    return StateValue(obj, parent);
  } 
  else {
    throw ("All elements in the state tree must be of type double, int, bool, String, Map, or List. Instead element"
        "$obj was of type ${obj.runtimeType}");
  }
}
