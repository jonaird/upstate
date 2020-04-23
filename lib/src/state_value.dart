import 'base.dart';

class StateValue<T> extends StateElement {
  var _value;
  final StateElement parent;
  bool _isInt = false;
  bool notifyAncestors;

  StateValue(T value, this.parent):notifyAncestors=parent.notifyAncestors {
    if ((value is String) || (value is bool) || (value is double) ||(value is int) || value==null) {
      _value = value;
    } else {
      throw ('State values must be of type int, double, String, bool, or null');
    }
  }
  
  dynamic toPrimitive()=>_value;


  T get value {
    if (removedFromStateTree) {
      throw ('A value you tried to access has been removed from the state tree');
    } 
    return _value;
  }

  set value(T newValue) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    } else if (newValue.runtimeType != _value.runtimeType && _value != null) {
      throw ('When mutating a state value, it must be of the same type as the previous value unless the previous value is null.');
    }
    _value = newValue;
    notifyChange();
  }
}
