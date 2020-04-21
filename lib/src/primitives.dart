import 'base.dart';

abstract class StateValue<T> extends StateElement {
  T _value;

  T get value {
    if (removedFromTree) {
      throw ('A value you tried to change has been removed from the state tree');
    } else {
      return _value;
    }
  }

  bool get isNull => _value == null;

  bool get isNotNull => _value != null;

  set value(T newValue) {
    if (removedFromTree) {
      throw ('A value you tried to change has been removed from the state tree');
    }
    _value = newValue;
    notifyChange();
  }
}

class StateBool extends StateValue<bool> {
  final StateElement parent;
  bool notifyRecursively;
  StateBool(value,this.parent)
      : notifyRecursively=parent.notifyRecursively {
    _value = value;
  }
}

class StateNumber extends StateValue<double> {
  bool _isInt;
  final StateElement parent;
  bool notifyRecursively;
  

  StateNumber(number, this.parent,)
      : 
      notifyRecursively=parent.notifyRecursively {
    _value = number.toDouble();
  }

  int asInt() {
    _isInt ??= true;
    return _value.toInt();
  }

  @override
  set value(dynamic val) {
    if (_isInt && !(val is int)) {
      throw (FormatException(
          "Once a StateNumber has consumed used with asInt(), all new values must be ints"));
    } else {
      _value = val.toDouble();
    }
  }
}

class StateString extends StateValue<String> {
  final StateElement parent;
  
  bool notifyRecursively;

  StateString(String string, this.parent,)
      : 
      notifyRecursively=parent.notifyRecursively {
    _value = string;
  }
}
