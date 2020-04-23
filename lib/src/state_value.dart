part of 'base.dart';

class StateValue<T> extends StateElement {
  T _value;

  StateValue(T value, _StateIterable parent)
      : _value = value,
        super(parent);

  bool get isNull => _value == null;

  bool get isNotNull => _value != null;

  T toPrimitive() => _value;

  T get value {
    if (removedFromStateTree) {
      throw ('A value you tried to access has been removed from the state tree');
    }
    return _value;
  }

  set value(T newValue) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    }
    _value = newValue;
    notifyChange();
  }

  StateValue<N> initialize<N>(N newValue) {
    if (_value != null) {
      throw ('you can only initialize null state values');
    }
    var newElement = StateValue<N>(newValue, parent);
    parent._initializeNullWithValue(this, newElement);
    return newElement;
  }
}

// class NullableStateValue extends StateValue {
//   final StateElement _parent;
//   NullableStateValue(StateElement parent) : _parent=parent, super(null, parent);
// }
