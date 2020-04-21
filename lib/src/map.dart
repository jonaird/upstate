import 'dart:collection';
import 'base.dart';

// StateMap is an unmodifiable map<String, StateElement>
class StateMap extends StateElement with MapMixin<String, StateElement> {
  Map<String, StateElement> _map;
  final StateElement parent;
  bool notifyRecursively;

  StateMap(Map<String, dynamic> map, [this.parent]) {
    if (!isRoot) {
      notifyRecursively = parent.notifyRecursively;
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
}

class StateObject extends StateMap {
  final bool notifyRecursively;
  StateObject(Map<String, dynamic> map, {this.notifyRecursively = true})
      : super(map);
}

Map<String, StateElement> toStateElementMap(
    Map<String, dynamic> map, StateElement parent) {
  var newMap = Map.from(map);
  newMap.updateAll((key, value) {
    return toStateElement(value, parent);
  });
  return newMap;
}
