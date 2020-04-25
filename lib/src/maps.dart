part of 'base.dart';

// StateMap is an unmodifiable map<String, StateElement>
class StateMap extends _StateIterable with MapMixin<String, dynamic> {
  Map<String, StateElement> _map;

  StateMap(Map<String, dynamic> map, [StateElement parent]) : super(parent) {
    _map = _toStateElementMap(map, this);
  }

  void _instantiateNullWithValue(
      StateValue<Null> oldElement, StateValue newElement) {
    String k;
    _map.forEach((key, value) {
      if (value == oldElement) {
        k = key;
      }
    });
    _map[k] = newElement;
    notifyChange();
  }

  Iterable<String> get keys => _map.keys;

  operator [](key) => _map[key];

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
  bool notifyParent,  useNums, stronglyTyped, nullable;
  StateValue Function(dynamic value, StateElement parent) converter;

  StateObject(Map<String, dynamic> map,
      {bool elementsShouldNotifyParents = true,
      this.useNums=false,
      this.stronglyTyped=false,
      this.nullable=true,
      this.converter})
      : notifyParent = elementsShouldNotifyParents,
        super(map) {
    if (useNums && !stronglyTyped) {
      throw ("useNums can't be used without stronglyTyped:true");
    } else if (nullable && !stronglyTyped) {
      throw ("nullable can't be used without stronglyTyped:true");
    }
  }

  factory StateObject.fromJson(String json,
      {bool elementsShouldNotifyParents = true,
      bool useNums = false,
      bool stronglyTyped = true,
      StateValue Function(dynamic value, StateElement parent) converter}) {
    var map = jsonDecode(json);
    return StateObject(map,
        elementsShouldNotifyParents: elementsShouldNotifyParents,
        useNums: useNums,
        stronglyTyped: stronglyTyped,
        converter: converter);
  }

  static of<T extends StateWidget>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<T>().state;

  StateValue call(StatePath path) {
    return getElementAtPath(path);
  }

  StateElement getElementAtPath(StatePath path) {
    StateElement element = this;
    StatePath newPath = StatePath.from(path);

    while (newPath.isNotEmpty) {
      if (element is StateMap && newPath.first is String) {
        var elem = element as StateMap;
        element = elem[newPath.first];
        newPath.removeAt(0);
      } else if (element is StateList && newPath.first is int) {
        var elem = element as StateList;
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
    return element.notifications.listen((event) {
      callback();
    });
  }
}

Map<String, StateElement> _toStateElementMap(
    Map<String, dynamic> map, StateElement parent) {
  var newMap = Map.from(map);

  newMap.updateAll((key, value) {
    return _toStateElement(value, parent);
  });
  return newMap.cast<String, StateElement>();
}
