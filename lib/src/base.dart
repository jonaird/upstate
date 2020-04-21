import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'map.dart';
import 'list.dart';
import 'primitives.dart';

abstract class StateElement {
  StateElement parent;
  bool _removedFromTree = false;
  bool _pathSet=false;
  bool notifyRecursively;

  final StreamController<ChangeRecord> _changes = StreamController.broadcast();

  //notifies subscribers of a change and all ancestor state elements
  void notifyChange() {
    if (_removedFromTree) {
      throw ('State element has been removed from the state tree and can\'t be modified');
    } else {
      _changes.add(ChangeRecord.changed);
      if (notifyRecursively && !isRoot) {
        parent.notifyChange();
      }
    }
  }

  bool get isRoot {
    return this is StateObject;
  }

  void removeFromTree() {
    _removedFromTree = true;
    _changes.add(ChangeRecord.removedFromTree);
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

  bool get removedFromTree => _removedFromTree;

  Stream<ChangeRecord> get changes {
    return _changes.stream;
  }
}

class StatePath with ListMixin {
  List _path;

  StatePath(List path) : _path = path;

  factory StatePath.from(StatePath path) {
    return StatePath(path.toList());
  }

  static root() => StatePath([]);

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

enum ChangeRecord { changed, removedFromTree }

StateElement toStateElement(obj, StateElement parent) {
  if (obj is Map) {
    return StateMap(obj, parent);
  } else if (obj is List) {
    return StateList(obj, parent);
  } else if (obj is int) {
    return StateNumber(obj.toDouble(), parent);
  } else if (obj is double) {
    return StateNumber(obj, parent);
  } else if (obj is bool) {
    return StateBool(obj, parent);
  } else {
    throw ("All elements in the state tree must be of type double, int, bool, String, Map, or List. Instead element"
        "$obj was of type ${obj.runtimeType}");
  }
}
