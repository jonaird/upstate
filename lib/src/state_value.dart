part of 'base.dart';

class StateValue<T> extends StateElement {
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


  bool get isNull => _value == null;

  bool get isNotNull => _value != null;

  T toPrimitive() => _value.toPrimitive();

  StateValue instantiate(newValue) {
    if (typing!=StateValueTyping.nonNullable) {
      throw ('Initialize should only but used for when not using nonNullable typing');
    } else if (_value != null) {
      throw ('you can only instantiate null state values');
    }
    var newElement = _toStateElement(newValue, this.parent);
    parent._instantiateNullWithValue(this, newElement);
    _notifications.add(StateElementNotification.instantiated);
    _removeFromStateTree();
    return newElement;
  }
}

enum StateValueTyping{
  dynamicTyping, strongTyping, nonNullable 
}



//needed for stateValue.toPrimitive(); which is needed for json conversion
//override for custom json serialization. will default to toJson();
extension on Object{
  toPrimitive()=>this;
}

