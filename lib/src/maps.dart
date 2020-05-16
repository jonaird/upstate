part of 'base.dart';

/// StateMap is a [StateElement] that implements the map interface. It takes a normal map in its constructor and
/// recursively converts all values to [StateElement]s. StateMaps are immutable except in the one case
/// in which it contains a [StateValue<Null>] in which case that value is replaced with the instantiated value.
class StateMap extends StateIterable
    with MapMixin<String, dynamic>, _StateMapMixin {
  StateMap(Map<String, dynamic> map, [StateElement parent]) : super(parent) {
    _map = _toStateElementMap(map, this);
  }
}

///StateOjbect is the default [RootStateElement] used in Upstate which makes it very easy
///and quick to create a state with many nested values.
class StateObject extends RootStateElement
    with MapMixin<String, dynamic>, _StateMapMixin {
  bool notifyParent;
  StateElement Function(dynamic value, StateElement parent) converter;
  StateValueTyping typing;
  TypeSafety typeSafety;

  StateObject(Map<String, dynamic> map,
      {bool elementsShouldNotifyParents = true,
      this.typing = StateValueTyping.dynamicTyping,
      this.converter,
      this.typeSafety = TypeSafety.unsafe})
      : notifyParent = elementsShouldNotifyParents {
    _map = _toStateElementMap(map, this);
  }

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

  String toJson(){
    var primitives = toPrimitive();
    return jsonEncode(primitives);
  }
  
  dynamic _getElementFromPath(StatePath path) {
    dynamic element = this;

    for (var key in path) {
      if (((element is StateMap) ||
              (element is StateObject) && key is String) ||
          (element is StateList && key is int))
        element = element?._getElementFromKey(key);
      else
        throw ('Invalid state path for state: $this');
    }

    return element;
  }

  T call<T>(StatePath path) {
    if (typeSafety != TypeSafety.unsafe && path.expectedType == dynamic)
      throw ('when using complete type safety all paths must have their expected state element types as '
          'their generic values.');

    var element = _getElementFromPath(path);

    if (path.expectedType != dynamic &&
        path.expectedType != element.runtimeType)
      throw ('Type error when trying to get state element at path: $path');

    return element;
  }

  static StateObject of<T extends StateWidget>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<T>()?.state;

  void unmount() {
    notifyRemovedFromState();
  }

  operator [](key) {
    if (removedFromState) throw (removedError);
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

mixin _StateMapMixin on StateElement {
  Map<String, StateElement> _map;
  _getElementFromKey(key) => _map[key];

  void _instantiateNullWithValue(
      StateValue<Null> oldElement, StateValue newElement) {
    String k;

    for (var key in _map.keys) if (_map[key] == oldElement) k = key;

    _map[k] = newElement;
    notifyChange();
  }
  void notifyRemovedFromState() {
    _notifications.add(StateElementNotification.removedFromState);
    _notifications.close();
    _removedFromState = true;
    for (var elem in _map.values) {
      elem.notifyRemovedFromState();
    }
  }

  Iterable<String> get keys => _map.keys;

  operator [](key) {
    if (removedFromState) throw (removedError);
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

  ///Recursively converts all values to primitive values where possible
  ///for the purpose of converting the entire state tree to JSON
  Map toPrimitive() {
    var newMap = Map.from(_map);
    newMap.updateAll((key, value) => value.toPrimitive());
    return newMap;
  }
}
