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

  void _instantiateNullWithValue(
      StateValue<Null> oldElement, StateValue newElement) {
    int index = _list.indexOf(oldElement);
    _list[index] = newElement;
    notifyChange();
  }

  StateElement operator [](int index) {
    if (removedFromStateTree) {
      throw ('A value you tried to access has been removed from the state tree');
    }
    return _list[index];
  }

  operator []=(int index, value) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    }
    _list[index] = _toStateElement(value, this);
    notifyChange();
  }

  int get length {
    if (removedFromStateTree) {
      throw ('A value you tried to get has been removed from the state tree');
    }
    return _list.length;
  }

  set length(int newLength) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    }
    _list.length = newLength;
  }

  //Many List methods make multiple changes to the List in one go.
  //We don't need to update our app state for every change and if we did so we
  //can run into errors and performance issue. Thus we have to override these methods to only
  //notify a change once all the mutations have finished.
  //We use this[i] instead of list[i] to throw an error if the StateList
  //has been removed from the state tree.
  //We also need to override methods that removes elements to notify them
  //that they've been removed from the state tree.

  @override
  void addAll(Iterable iterable) {
    insertAll(_list.length, iterable);
  }

  @override
  void clear() {
    var newList = List.of(_list);
    _list.clear();
    newList.forEach(_remove);
    notifyChange();
  }

  

  @override
  void fillRange(int start, int end, [fillValue]) {
    var toRemove = getRange(start, end);
    for(int i=start;i<end+1;i++){
      _list[i]=_toStateElement(fillValue, this);
    }
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void insert(int index, value) {
    _list.insert(index, _toStateElement(value, this));
    notifyChange();
  }

  @override
  insertAll(int index, Iterable iterable) {
    var newList = iterable.map((e) => _toStateElement(e,this));
    _list.insertAll(index, newList);
    notifyChange();
  }

  @override
  bool remove(element) {
    assert(element is StateElement);
    var elem = element as StateElement;
    bool returnVal = _list.remove(element);
    elem. _removeFromStateTree();
    notifyChange();
    return returnVal;
  }

  @override
  StateElement removeAt(int index) {
    var elem = this[index];
    elem. _removeFromStateTree();
    _list.removeAt(index);
    return elem;
  }

  @override
  StateElement removeLast() {
    StateElement elem = _list.removeLast();
    elem. _removeFromStateTree();
    notifyChange();
    return elem;
  }

  @override
  void removeRange(int start, int end) {
    var toRemove = _list.getRange(start, end);
    _list.removeRange(start, end);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void removeWhere(bool test(StateElement element)) {
    var toRemove = _list.where(test);
    _list.removeWhere(test);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void replaceRange(int start, int end, Iterable replacement) {
    var toRemove = _list.getRange(start, end);
    _list.replaceRange(start, end, replacement);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  void retainWhere(bool test(StateElement element)) {
    var toRemove = _list.where((elem) => !test(elem));
    _list.retainWhere(test);
    toRemove.forEach(_remove);
    notifyChange();
  }

  @override
  setAll(int index, Iterable iterable) {
    var toRemove = _list.getRange(index, iterable.length - 1);
    int newIndex = index;
    for (var elem in iterable) {
      _list[newIndex] = _toStateElement(elem, this);
      index++;
    }
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
    _list.shuffle(random);
    notifyChange();
  }

  //TODO
//  sort([int compare(E a, E b)])
}

List<StateElement> _toStateElementList(List list, StateElement parent) {
  List<StateElement> newList = [];

  list.forEach((element) {
    newList.add(_toStateElement(element, parent));
  });

  return newList;
}

void _remove(element) {
  element. _removeFromStateTree();
}
