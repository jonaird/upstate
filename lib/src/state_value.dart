part of 'base.dart';

class StateValue<T> extends StateElement<T> {
  T _value;

  StateValue(T value, _StateIterable parent)
      : _value = value,
        super(parent);

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

  operator [](key){
    throw('you can\'t use the [] on state values');
  }

  T call() {
    if (removedFromStateTree) {
      throw ('A value you tried to access has been removed from the state tree');
    }
    return _value;
  }

  bool get isNull => _value == null;

  bool get isNotNull => _value != null;

  T toPrimitive() => _value;

  StateValue instantiate(newValue) {
    if (_value != null) {
      throw ('you can only instantiate null state values');
    } else if (!stronglyTyped&&!nullable) {
      throw ('Initialize should only but used for stronglyTyped:true and nullable:true');
    }
    var newElement = _toStateElement(newValue, this.parent);
    parent._instantiateNullWithValue(this, newElement);
    _notifications.add(StateElementNotification.instantiated);
    _removeFromStateTree();
    return newElement;
  }
}
