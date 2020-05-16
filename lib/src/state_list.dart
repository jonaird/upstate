part of 'base.dart';

///A [StateElement] that implements the list interface and
///contains a list of other state elements. Note that if any object
///is added to the list it is automatically converted to a [StateElement]. You do not
///provide state elements to the list to yourself.
class StateList extends StateIterable with ListMixin<dynamic> {
  List<StateElement> _list;

  StateList(List list, StateElement parent) : super(parent) {
    _list = _toStateElementList(list, this);
  }

  List toPrimitive() {
    var iterable = _list.map((e) => e.toPrimitive());
    return List.from(iterable);
  }

  _getElementFromKey(key) => _list[key];

  void _instantiateNullWithValue(
      StateValue<Null> oldElement, StateValue newElement) {
    int index = _list.indexOf(oldElement);
    _list[index] = newElement;
    notifyChange();
  }

  void notifyRemovedFromState() {
    _notifications.add(StateElementNotification.removedFromState);
    _notifications.close();
    _removedFromState = true;
    for (var elem in _list) {
      elem.notifyRemovedFromState();
    }
  }

  StateElement operator [](int index) {
    if (removedFromState) throw (removedError);

    if (typeSafety == TypeSafety.complete)
      throw ('you can\'t use [] operators with complete type safety. Instead use the call method with a state path');

    return _list[index];
  }

  operator []=(int index, value) {
    if (removedFromState) throw (removedError);

    StateElement oldElem = _list[index];
    _list[index] = _toStateElement(value, this);
    oldElem.notifyRemovedFromState();
    notifyChange();
  }

  int get length {
    if (removedFromState) throw (removedError);

    return _list.length;
  }

  set length(int newLength) {
    if (removedFromState) throw (removedError);

    _list.length = newLength;
  }

  //Many List methods make multiple changes to the List in one go.
  //We don't need to update our app state for every change and if we did so we
  //can run into errors and performance issue. Thus we have to override these methods to only
  //notify a change once all the mutations have finished.
  //We also need to override methods that removes elements to notify them
  //that they've been removed from the state tree.

  @override
  void addAll(Iterable iterable) {
    if (removedFromState) throw (removedError);

    var toAdd = iterable.map((e) => _toStateElement(e, this));
    insertAll(_list.length, toAdd);
  }

  @override
  void clear() {
    if (removedFromState) throw (removedError);

    var toRemove = List.of(_list);
    _list.clear();
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void fillRange(int start, int end, [fillValue]) {
    if (removedFromState) throw (removedError);

    var toRemove = _list.getRange(start, end);
    for (int i = start; i < end + 1; i++)
      _list[i] = _toStateElement(fillValue, this);

    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void insert(int index, value) {
    if (removedFromState) throw (removedError);

    var toRemove = _list[index];
    _list.insert(index, _toStateElement(value, this));
    _remove(toRemove);
    notifyChange();
  }

  @override
  insertAll(int index, Iterable iterable) {
    if (removedFromState) throw (removedError);

    var toAdd = iterable.map((e) => _toStateElement(e, this));
    _list.insertAll(index, toAdd);
    notifyChange();
  }

  @override
  bool remove(element) {
    if (removedFromState) throw (removedError);

    bool returnVal = _list.remove(element);
    if (returnVal) {
      _remove(element);
      notifyChange();
    }
    return returnVal;
  }

  @override
  StateElement removeAt(int index) {
    if (removedFromState) throw (removedError);

    var toRemove = _list[index];
    _list.removeAt(index);
    _remove(toRemove);
    notifyChange();
    return toRemove;
  }

  @override
  StateElement removeLast() {
    if (removedFromState) throw (removedError);

    var toRemove = _list.removeLast();
    _remove(toRemove);
    notifyChange();
    return toRemove;
  }

  @override
  void removeRange(int start, int end) {
    if (removedFromState) throw (removedError);

    var toRemove = _list.getRange(start, end);
    _list.removeRange(start, end);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void removeWhere(bool test(StateElement element)) {
    if (removedFromState) throw (removedError);

    var toRemove = _list.where(test);
    _list.removeWhere(test);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void replaceRange(int start, int end, Iterable replacement) {
    if (removedFromState) throw (removedError);

    var toRemove = _list.getRange(start, end);
    var toAdd = replacement.map((e) => _toStateElement(e, this));
    _list.replaceRange(start, end, toAdd);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void retainWhere(bool test(StateElement element)) {
    if (removedFromState) throw (removedError);

    var toRemove = _list.where((elem) => !test(elem));
    _list.retainWhere(test);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  setAll(int index, Iterable iterable) {
    if (removedFromState) throw (removedError);

    var toRemove = _list.getRange(index, iterable.length - 1);
    var toAdd = iterable.map((e) => _toStateElement(e, this));
    _list.setAll(index, toAdd);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  setRange(int start, int end, Iterable iterable, [int skipCount = 0]) {
    if (removedFromState) throw (removedError);
    var toRemove = _list.getRange(start, end);
    var toAdd = _toStateElementList(List.from(iterable), parent);
    _list.setRange(start, end, toAdd, skipCount);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  shuffle([Random random]) {
    if (removedFromState) throw (removedError);

    _list.shuffle(random);
    notifyChange();
  }

  sort([int compare(a, b)]) {

    if (removedFromState) throw (removedError);
    _list.sort(compare);
    notifyChange();
  }
}

List<StateElement> _toStateElementList(List list, StateElement parent) {
  var stateElements = list.map((e) => _toStateElement(e, parent));

  return List.from(stateElements).cast<StateElement>();
}

void _remove(StateElement element) {
  element.notifyRemovedFromState();
}
