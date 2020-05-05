part of 'base.dart';

class StateList extends _StateIterable with ListMixin<dynamic> {
  List<StateElement> _list;

  StateList(List list, _StateIterable parent) : super(parent) {
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

  StateElement operator [](int index) {
    if (removedFromStateTree) throw (removedError);

    if (typeSafety == TypeSafety.complete)
      throw ('you can\'t use [] operators with complete type safety. Instead use the call method with a state path');

    return _list[index];
  }

  operator []=(int index, value) {
    if (removedFromStateTree) throw (removedError);

    StateElement oldElem = _list[index];
    _list[index] = _toStateElement(value, this);
    oldElem.removeFromStateTree();
    notifyChange();
  }

  int get length {
    if (removedFromStateTree) throw (removedError);

    return _list.length;
  }

  set length(int newLength) {
    if (removedFromStateTree) throw (removedError);

    _list.length = newLength;
  }

  //Many List methods make multiple changes to the List in one go.
  //We don't need to update our app state for every change and if we did so we
  //can run into errors and performance issue. Thus we have to override these methods to only
  //notify a change once all the mutations have finished.
  //We also need to override methods that removes elements to notify them
  //that they've been removed from the state tree.
  //TODO: these functions need to be reviewed

  @override
  void addAll(Iterable iterable) {
    if (removedFromStateTree) throw (removedError);

    var toAdd = iterable.map((e) => _toStateElement(e, this));
    insertAll(_list.length, toAdd);
  }

  @override
  void clear() {
    if (removedFromStateTree) throw (removedError);

    var toRemove = List.of(_list);
    _list.clear();
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void fillRange(int start, int end, [fillValue]) {
    if (removedFromStateTree) throw (removedError);

    var toRemove = getRange(start, end);
    for (int i = start; i < end + 1; i++)
      _list[i] = _toStateElement(fillValue, this);

    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void insert(int index, value) {
    if (removedFromStateTree) throw (removedError);

    var toRemove = _list[index];
    _list.insert(index, _toStateElement(value, this));
    _remove(toRemove);
    notifyChange();
  }

  @override
  insertAll(int index, Iterable iterable) {
    if (removedFromStateTree) throw (removedError);

    var toAdd = iterable.map((e) => _toStateElement(e, this));
    _list.insertAll(index, toAdd);
    notifyChange();
  }

  @override
  bool remove(element) {
    if (removedFromStateTree) throw (removedError);

    bool returnVal = _list.remove(element);
    if (returnVal) {
      _remove(element);
      notifyChange();
    }
    return returnVal;
  }

  @override
  StateElement removeAt(int index) {
    if (removedFromStateTree) throw (removedError);

    var toRemove = _list[index];
    _list.removeAt(index);
    _remove(toRemove);
    notifyChange();
    return toRemove;
  }

  @override
  StateElement removeLast() {
    if (removedFromStateTree) throw (removedError);

    var toRemove = _list.removeLast();
    _remove(toRemove);
    notifyChange();
    return toRemove;
  }

  @override
  void removeRange(int start, int end) {
    if (removedFromStateTree) throw (removedError);

    var toRemove = _list.getRange(start, end);
    _list.removeRange(start, end);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void removeWhere(bool test(StateElement element)) {
    if (removedFromStateTree) throw (removedError);

    var toRemove = _list.where(test);
    _list.removeWhere(test);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void replaceRange(int start, int end, Iterable replacement) {
    if (removedFromStateTree) throw (removedError);

    var toRemove = _list.getRange(start, end);
    var toAdd = replacement.map((e) => _toStateElement(e, this));
    _list.replaceRange(start, end, toAdd);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void retainWhere(bool test(StateElement element)) {
    if (removedFromStateTree) throw (removedError);

    var toRemove = _list.where((elem) => !test(elem));
    _list.retainWhere(test);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  setAll(int index, Iterable iterable) {
    if (removedFromStateTree) throw (removedError);

    var toRemove = _list.getRange(index, iterable.length - 1);
    var toAdd = iterable.map((e) => _toStateElement(e, this));
    _list.setAll(index, toAdd);
    toRemove.forEach(_remove);
    notifyChange();
  }

  //TODO
  // @override
  // setRange(int start, int end, Iterable iterable, [int skipCount = 0]) {

  //   _list.setRange(start, end, iterable)
  // }

  @override
  shuffle([Random random]) {
    if (removedFromStateTree) throw (removedError);

    _list.shuffle(random);
    notifyChange();
  }

  //TODO
//  sort([int compare(E a, E b)])
}

List<StateElement> _toStateElementList(List list, StateElement parent) {
  var stateElements = list.map((e) => _toStateElement(e,parent));

  return List.from(stateElements).cast<StateElement>();
}

void _remove(element) {
  element._removeFromStateTree();
}
