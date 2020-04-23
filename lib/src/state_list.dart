// import 'base.dart';
// import 'dart:collection';

part of 'base.dart';

//TODO: finish overriding List methods that mutate the list
class StateList extends StateElement with ListMixin<StateElement> {
  List<StateElement> _list;
  final StateElement _parent;
  bool notifyAncestors;
  bool useNums;

  StateList(List list, StateElement parent)
      : notifyAncestors = parent.notifyAncestors,
        _parent = parent,
        useNums = parent.useNums {
    _list = _toStateElementList(list, this, useNums);
  }

  List toPrimitive() {
    var iterable = _list.map((e) => e.toPrimitive());
    return List.from(iterable);
  }

  operator [](int index) {
    if (removedFromStateTree) {
      throw ('A value you tried to access has been removed from the state tree');
    }
    return _list[index];
  }

  operator []=(int index, StateElement value) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    }
    if (_list[index] != value) {
      _list[index] = _toStateElement(value, this, useNums);
      notifyChange();
    }
  }

  int get length {
    if (removedFromStateTree) {
      throw ('A value you tried to get has been removed from the state tree');
    }
    return _list.length;
  }

  //TODO: should replace new null elements with empty StateValues
  set length(int newLength) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    }
    _list.length = newLength;
  }

  @override
  void addAll(Iterable iterable) {
    iterable.forEach((element) {
      add(_toStateElement(element, this, useNums));
    });
    notifyChange();
  }

  @override
  void clear() {
    forEach((stateElement) {
      stateElement.removeFromStateTree();
    });
    _list.clear();
    notifyChange();
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
  void fillRange(int start, int end, [fillValue]) {
    for (int i = start; i < end; i++) {
      this[i].removeFromStateTree();
    }
    StateElement newFillValue = _toStateElement(fillValue, this, useNums);

    _list.fillRange(start, end, newFillValue);
    notifyChange();
  }

  @override
  void insert(int index, value) {
    this[index].removeFromStateTree();
    _list.insert(index, _toStateElement(value, this, useNums));
    notifyChange();
  }

  @override
  insertAll(int index, Iterable iterable) {
    iterable.forEach((element) {
      this.add(_toStateElement(element, this, useNums));
    });
    notifyChange();
  }

  @override
  bool remove(element) {
    var el = element as StateElement;
    el.removeFromStateTree();
    bool returnVal = _list.remove(element);
    notifyChange();
    return returnVal;
  }

  @override
  StateElement removeAt(int index) {
    var elem = this[index];
    elem.removeFromStateTree();
    _list.removeAt(index);
    return elem;
  }

// removeLast() → E
// Pops and returns the last object in this list. [...]

// removeRange(int start, int end) → void
// Removes the objects in the range start inclusive to end exclusive. [...]

// removeWhere(bool test(E element)) → void
// Removes all objects from this list that satisfy test. [...]

// replaceRange(int start, int end, Iterable<E> replacement) → void
// Removes the objects in the range start inclusive to end exclusive and inserts the contents of replacement in its place. [...]

// retainWhere(bool test(E element)) → void
// Removes all objects from this list that fail to satisfy test. [...]

// setAll(int index, Iterable<E> iterable) → void
// Overwrites objects of this with the objects of iterable, starting at position index in this list. [...]

// setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) → void
// Copies the objects of iterable, skipping skipCount objects first, into the range start, inclusive, to end, exclusive, of the list. [...]

// shuffle([Random random]) → void
// Shuffles the elements of this list randomly.

// sort([int compare(E a, E b)]) → void
// Sorts this list according to the order specified by the compare function. [...]
}

List<StateElement> _toStateElementList(
    List list, StateElement parent, bool useNums) {
  List<StateElement> newList = [];

  list.forEach((element) {
    newList.add(_toStateElement(element, parent, useNums));
  });

  return newList;
}
