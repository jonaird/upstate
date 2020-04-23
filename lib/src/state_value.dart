// import 'base.dart';

part of 'base.dart';

class StateValue<T> extends StateElement {
  var _value;
  final StateElement _parent;
  bool notifyAncestors;
  bool useNums;

  StateValue(T value, StateElement parent)
      : _parent = parent,
      notifyAncestors = parent.notifyAncestors,
        useNums = parent.useNums {
    if ((value is String) ||
        (value is bool) ||
        (value is double) ||
        (value is int) ||
        value == null) {
      _value = value;
    } else {
      throw ('State values must be of type int, double, String, bool, or null');
    }
  }

  dynamic toPrimitive() => _value;

  T get value {
    if (removedFromStateTree) {
      throw ('A value you tried to access has been removed from the state tree');
    }
    return _value;
  }

  set value(T newValue) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    } else if (newValue.runtimeType != _value.runtimeType) {
      throw ('When mutating a state value, it must be of the same type as the previous value.');
    }
    _value = newValue;
    notifyChange();
  }
}

class NullableStateValue extends StateValue {
  StateElement parent;
  NullableStateValue(this.parent) : super(null, parent);
}
