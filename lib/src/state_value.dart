import 'base.dart';

class StateValue<T> extends StateElement {
  var _value;
  final StateElement parent;
  bool _isInt = false;
  bool notifyAncestors;

  StateValue(T value, this.parent):notifyAncestors=parent.notifyAncestors {
    if (value is int) {
      _value = value.toDouble();
    } else if ((value is String) || (value is bool) || (value is double)) {
      _value = value;
    } else {
      throw ('State values must be of type int, double, String, or bool');
    }
  }
  
  dynamic toPrimitive(){
    return _value;
  }


  T get value {
    if (removedFromStateTree) {
      throw ('A value you tried to access has been removed from the state tree');
    } else if (_value is double) {
      throw ('to access a number from a state value use asInt or asDouble');
    }
    return _value;
  }

  set value(T newValue) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    } else if (_value is double) {
      throw ('to access a number from a state value use asInt or as Double');
    } else if (newValue.runtimeType != _value.runtimeType && _value != null) {
      throw ('When mutating a state value, it must be of the same type as the previous value');
    }
    _value = newValue;
    notifyChange();
  }

  int get asInt {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    } else if (!_value is double) {
      throw ('asInt can only be used for state values that hold a number');
    }
    _isInt ??= true;
    return _value.toInt();
  }

  set asInt(int value) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    } else if (!_value is double) {
      throw ('asInt can only be used for state values that hold a number');
    }
    _isInt ??= true;
    _value = value.toDouble();
    notifyChange();
  }

  double get asDouble {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    } else if (!_value is double) {
      throw ('asDouble can only be used for state values that hold a number');
    }
    return _value;
  }

  set asDouble(double value) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    } else if (!_value is double) {
      throw ('asDouble can only be used for state values that hold a number');
    } else if (_isInt) {
      throw ("Once a StateNumber is set or retrieved as an int, you cannot set it as a double");
    }
    _value = value;
    notifyChange();
  }
}
