part of 'base.dart';

/// StateValue is a [StateElement] that holds a value and notifies listeners when it's value changes.
/// If the value held by the StateValue is a primitive type (bool, String, int, double), then it will
/// automatically notify listeners when the value has changed. However if it holds some other type of object,
/// it just holds a pointer to that object and you should call [notifyChange] on the state value after
/// mutating the object. If you want a state element that contains a complex data structure and automatically
/// notifies listeners upon a change, you can create a custom state model using a converter function.

class StateValue<T> extends StateElement {
  T _value;

  StateValue(T value, StateElement parent)
      : _value = value,
        super(parent);

  ///Gets the value held in the [StateValue]
  T get value {
    if (removedFromState) throw (removedError);
    return _value;
  }

  ///Sets a new state value and notifies listeners.
  set value(T newValue) {
    if (removedFromState) throw (removedError);

    _value = newValue;
    notifyChange();
  }

  void silentSet(T newVal){
    if (removedFromState) throw (removedError);
    _value=newVal;
  }

  void quietSet(T newVal){
    if (removedFromState) throw (removedError);
    if(notifyParent==false) throw('no need to use quietSet if notifyParent is false');
    notifyParent=false;
    _value = newVal;
    notifyChange();
    notifyParent=true;

  }

  ///Returns whether the value contained in the StateValue is equal to null.
  bool get isNull => _value == null;

  bool get isNotNull => _value != null;

  ///Tries to convert the state value to a primitive which is called before converting to JSON.
  ///If a [StateValue] doesn't hold  a primitive type, the value will be converted to JSON
  ///using it's toJson function.
  T toPrimitive() => _value;

  ///When using [StateValueTyping.nonNullable], you can instantiate a [StateValue<Null>] with a
  ///state value that holds a non-null value. This will replace the [StateValue] in the state tree
  ///with a new one and call [StateElement._removeFromWidgetTree] on the old element.
  StateValue instantiate(newValue) {
    if (typing != StateValueTyping.nonNullable)
      throw ('Initialize should only but used for when not using nonNullable typing');

    if (_value != null) throw ('you can only instantiate null state values');

    var newElement = _toStateElement(newValue, parent);
    if (parent is StateMap)
      (parent as StateMap)._instantiateNullWithValue(this, newElement);
    if (parent is StateObject)
      (parent as StateObject)._instantiateNullWithValue(this, newElement);
    if (parent is StateList)
      (parent as StateList)._instantiateNullWithValue(this, newElement);
    _notifications.add(StateElementNotification.instantiated);
    notifyRemovedFromState();
    return newElement;
  }
}

///This option dictates what the generic type of [StateValue] will be.
enum StateValueTyping { dynamicTyping, strongTyping, nonNullable }
