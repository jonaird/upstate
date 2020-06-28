import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import '../upstate.dart';
import 'dart:math';
import 'errors.dart';

part 'maps.dart';
part 'state_list.dart';
part 'state_value.dart';

/// The base class for everything within your state.
/// A state element holds a reference to its parent, contains options that
/// have been passed to [StateObject], and has a broadcast stream for notifying
/// listeners when it has been modified, removed from state or in the case of
/// [StateValue<Null>], instantiated. StateElement can be extended to create
/// custom state models with complex
/// data types and restrictions on how data can be accessed or modified i.e. state models.

abstract class StateElement {
  final StateElement parent;
  RootStateElement _rootElement;
  bool _removedFromState = false, notifyParent;
  StateElement Function(dynamic value, StateElement parent) converter;
  StateValueTyping typing;
  TypeSafety typeSafety;

  StateElement(this.parent) {
    if (parent != null) {
      notifyParent = parent.notifyParent;
      typing = parent.typing;
      converter = parent.converter;
      typeSafety = parent.typeSafety;
      _rootElement=parent._rootElement;
    }
    else _rootElement=this;
  }

  final StreamController<StateElementNotification> _notifications =
      StreamController.broadcast();


  RootStateElement get rootElement =>_rootElement;

  ///Whether a state element has been removed from the state tree
  bool get removedFromState => _removedFromState;

  ///Returns a stream that can be subscribed to that receives [StateElementNotification]s upon changes
  Stream<StateElementNotification> get notifications => _notifications.stream;

  ///Subscripes to [notifications] and calls the callback upon an event
  ///will be depricated. Use notifications instead.
  StreamSubscription<StateElementNotification> subscribe(
      void Function(StateElementNotification notification) callback) {
    return notifications.listen((event) => callback(event));
  }

  //Notifies all listeners that this element has changed and dependent widgets should rebuild.
  void notifyChange() {
    if (removedFromState) throw (removedError);

    _notifications.add(StateElementNotification.changed);

    if (notifyParent) parent?.notifyChange();
  }

  ///should be called after a state element is no longer part of the state. This will cause
  ///your app to throw an error if you accidentally try to access or modify an element
  ///that's no longer in state.
  void notifyRemovedFromState() {
    _notifications.add(StateElementNotification.removedFromState);
    _notifications.close();
    _removedFromState = true;
  }

  ///Should be overriden if you need to convert the state to JSON.
  /// Attempts to convert a state element to primitive values before converting to JSON
  dynamic toPrimitive() => this;
}

///StatePath is a helper class that implements the list interface and represents a path in a [StateObject] state tree.
///For example `StatePath(['path','to','stateElement',0])`
class StatePath<T> extends ListBase {
  List _path;
  final expectedType = T;

  StatePath(List path) {
    for (var key in path) {
      if (!(key is int || key is String))
        throw ('StatePaths must contain only Strings or ints');
    }
    _path = path;
  }

  factory StatePath.from(StatePath path) => StatePath(path.toList());

  int get length => _path.length;

  set length(int newLength) {
    _path.length = newLength;
  }

  dynamic operator [](int index) => _path[index];

  void operator []=(int index, value) {
    if (!(value is int || value is String))
      throw ('StatePaths must contain only Strings or ints');

    _path[index] = value;
  }
}

///Notifications that are sent to listeners of [StateElement] changes.
enum StateElementNotification { changed, instantiated, removedFromState }

///Option passed to [StateObject].
enum TypeSafety { unsafe, basic, complete }

StateElement _toStateElement(obj, StateElement parent) {
  if (parent != null && parent.converter != null) {
    StateElement elem = parent.converter(obj, parent);

    if (elem != null) return elem;
  }

  if (obj is List) return StateList(obj, parent);

  if (obj is Map) return StateMap(obj, parent);

  if (parent.typing == StateValueTyping.dynamicTyping)
    return StateValue<dynamic>(obj, parent);

  switch (obj.runtimeType) {
    case String:
      return StateValue<String>(obj, parent);

    case bool:
      return StateValue<bool>(obj, parent);

    case Null:
      {
        if (parent.typing == StateValueTyping.nonNullable)
          return StateValue<Null>(obj, parent);
        else
          return StateValue<dynamic>(obj, parent);
      }
      break;
    case int:
      return StateValue<int>(obj, parent);

    case double:
      return StateValue<double>(obj, parent);

    default:
      throw ("All elements in the state tree must be of type double, int, bool, String, Map, List or null unless you use dynamic typing or use a converter");
  }
}

///Either a [StateMap] or a [StateList]
abstract class StateIterable extends StateElement {
  StateIterable(StateElement parent) : super(parent);

  dynamic _getElementFromPath(StatePath path) {
    dynamic elem = this;

    for (var key in path) {
      if (elem is StateMap && key is String)
        elem = (elem as StateMap)._getElementFromKey(key);
      else if (elem is StateObject && key is String)
        elem = (elem as StateObject)._getElementFromKey(key);
      else if (elem is StateList && key is int)
        elem = (elem as StateList)._getElementFromKey(key);
      else
        throw ('Invalid state path for state: $this');
    }

    return elem;
  }

  T call<T>(StatePath path) {
    var didSpecifiedType = (T != dynamic || path.expectedType != dynamic);
    if (typeSafety != TypeSafety.unsafe && !didSpecifiedType)
      throw ('when using complete type safety all paths must have their expected state element types as '
          'their generic values.');

    var element = _getElementFromPath(path);

    if (path.expectedType != dynamic &&
        path.expectedType != element.runtimeType)
      throw ('Type error when trying to get state element at path: $path');

    return element;
  }
}

///This built in converter will convert all ints and doubles to [StateValue]<num>
StateValue numConverter(value, StateElement parent) {
  if (value is num) return StateValue<num>(value, parent);
  return null;
}

///The root [StateElement] in the state tree. You can subclass to create your own
///custom state object.
abstract class RootStateElement extends StateElement {
  RootStateElement() : super(null);
  void unmount();
}
