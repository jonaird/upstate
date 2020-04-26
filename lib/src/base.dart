import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import '../upstate.dart';
import 'dart:math';

part 'maps.dart';
part 'state_list.dart';
part 'state_value.dart';

abstract class StateElement{
  final _StateIterable parent;
  bool _removedFromStateTree = false, notifyParent;
  StateElement Function(dynamic value, StateElement parent) converter;
  StateValueTyping typing;

  StateElement(this.parent) {
    if (parent != null) {
      notifyParent = parent.notifyParent;
      typing = parent.typing;
      converter = parent.converter;
    }
  }

//uncomment to perform tests
  // @visibleForTesting
  // void removeFromStateTree() {
  //   _removeFromStateTree();
  // }

  final StreamController<StateElementNotification> _notifications =
      StreamController.broadcast();

  dynamic toPrimitive();

  bool get isRoot => this is StateObject;

  bool get removedFromStateTree => _removedFromStateTree;

  Stream<StateElementNotification> get notifications => _notifications.stream;

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

}

class StatePath extends ListBase {
  List _path;

  StatePath(List path) {
    for (var key in path) {
      if (!(key is int || key is String)) {
        throw ('StatePaths must contain only Strings or ints');
      }
    }
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
}

enum StateElementNotification { changed, instantiated, removedFromStateTree }

StateElement _toStateElement(obj, StateElement parent) {
  if (parent != null && parent.converter != null) {
    StateElement elem = parent.converter(obj, parent);
    if (elem != null) {
      return elem;
    }
  }

  if (obj is List) {
    return StateList(obj, parent);
  } else if (obj is Map) {
    return StateMap(obj, parent);
  } else if (parent.typing == StateValueTyping.dynamicTyping) {
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
          if (parent.typing == StateValueTyping.nonNullable) {
            return StateValue<Null>(obj, parent);
          } else {
            return StateValue<dynamic>(obj, parent);
          }
        }
        break;
      case int:
        {
          return StateValue<int>(obj, parent);
        }
        break;

      case double:
        {
          return StateValue<double>(obj, parent);
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

StateValue numConverter(number, StateElement parent) {
  if (number is num) {
    return StateValue<num>(number, parent);
  } else {
    return null;
  }
}
