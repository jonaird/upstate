part of 'base.dart';

// StateMap is an unmodifiable map<String, StateElement>
class StateMap extends _StateIterable with MapMixin<String, dynamic> {
  Map<String, StateElement> _map;

  StateMap(Map<String, dynamic> map, [StateElement parent]) : super(parent) {
    _map = _toStateElementMap(map, this);
  }

  _getElementFromKey(key) => _map[key];

  void _instantiateNullWithValue(
      StateValue<Null> oldElement, StateValue newElement) {
    String k;

    for (var key in _map.keys) if (_map[key] == oldElement) k = key;

    _map[k] = newElement;
    notifyChange();
  }

  Iterable<String> get keys => _map.keys;

  operator [](key) {
    if (removedFromStateTree) throw (removedError);
    if (typeSafety == TypeSafety.complete)
      throw ('you can\'t use [] operators with complete type safety. Instead use the call method with a state path');

    return _map[key];
  }

  operator []=(String key, value) {
    throw ('StateMaps are immutable.');
  }

  void clear() {
    throw ('StateMaps are immutable.');
  }

  remove(key) {
    throw ('StateMaps are immutable.');
  }

  Map toPrimitive() {
    var newMap = Map.from(_map);
    newMap.updateAll((key, value) => value.toPrimitive());
    return newMap;
  }
}

class StateObject extends StateMap {
  bool notifyParent;
  StateElement Function(dynamic value, StateElement parent) converter;
  StateValueTyping typing;
  TypeSafety typeSafety;

  StateObject(Map<String, dynamic> map,
      {bool elementsShouldNotifyParents = true,
      this.typing = StateValueTyping.dynamicTyping,
      this.converter,
      this.typeSafety = TypeSafety.unsafe})
      : notifyParent = elementsShouldNotifyParents,
        super(map);

  static StateObject fromJson(String json,
      {bool elementsShouldNotifyParents,
      StateValueTyping typing = StateValueTyping.dynamicTyping,
      TypeSafety typeSafety = TypeSafety.unsafe,
      StateElement Function(dynamic value, StateElement parent) converter}) {
    var map = jsonDecode(json);
    return StateObject(map,
        elementsShouldNotifyParents: elementsShouldNotifyParents,
        typing: typing,
        typeSafety: typeSafety,
        converter: converter);
  }

  static StateObject of<T extends StateWidget>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<T>()?.state;

  void unmount() {
    _removeFromStateTree();
  }

  operator [](key) {
    if (removedFromStateTree) throw (removedError);
    if (typeSafety != TypeSafety.unsafe)
      throw ('you can\'t use [] operators on state objects while using type-safe options');

    return _map[key];
  }
}

Map<String, StateElement> _toStateElementMap(
    Map<String, dynamic> map, StateElement parent) {
  
  var newMap = Map.from(map);
  newMap.updateAll((key, value) => _toStateElement(value, parent));
  return newMap.cast<String, StateElement>();
}
