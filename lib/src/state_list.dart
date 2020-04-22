import 'base.dart';
import 'dart:collection';

//TODO: finish overriding List methods that mutate the list
class StateList extends StateElement with ListMixin {
  List<StateElement> _list;
  final StateElement parent;
  bool notifyAncestors;

  StateList(List list, this.parent) : notifyAncestors = parent.notifyAncestors {
    _list = toStateElementList(list, this);
  }

  operator [](int index) {
    if (removedFromStateTree) {
      throw ('A value you tried to access has been removed from the state tree');
    }
    return _list[index];
  }

  operator []=(int index, value) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    }
    if (_list[index] != value) {
      _list[index] = value;
      notifyChange();
    }
  }

  int get length {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    }
    return _list.length;
  }

  set length(int newLength) {
    if (removedFromStateTree) {
      throw ('A value you tried to change has been removed from the state tree');
    }
    _list.length = newLength;
  }

  @override
  void addAll(Iterable iterable) {
    iterable.forEach((element) {
      add(toStateElement(element, this));
    });
    notifyChange();
  }

  @override
  void clear() {
    forEach((element) {
      element.removeFromTree();
    });
    _list.clear();
    notifyChange();
  }

  //Many List methods make multiple changes to the List in one go.
  //We don't need to update our app state for every change and if we did so we 
  //can run into errors. Thus we have to override these methods to only
  //notify a change once all the mutations have finished.
  //We use this[i] instead of list[i] to throw an error if the StateList
  //has been removed from the state tree.

  @override
  void fillRange(int start, int end, [fillValue]) {
    for (int i = start; i < end; i++) {
      this[i].removeFromTree();
    }
    StateElement  newFillValue = toStateElement(fillValue, this);
    
    _list.fillRange(start, end, newFillValue);
    notifyChange();
  }

  @override
  void insert(int index, value) {
    this[index].removeFromTree();
    _list.insert(index, toStateElement(value, this));
    notifyChange();
  }

  @override
  insertAll(int index, Iterable iterable) {
    iterable.forEach((element) {
      this.add(toStateElement(element, this));
    });
    notifyChange();
  }

  //We need to override remove to remove the state element from the tree
  @override
  bool remove(element) {
    var el = element as StateElement;
    el.removeFromTree();
    bool returnVal = _list.remove(element);
    notifyChange();
    return returnVal;
  }
}

List<StateElement> toStateElementList(List list, StateElement parent) {
  List<StateElement> newList = [];

  for (int i = 0; i < list.length; i++) {
    newList.add(toStateElement(list[i], parent));
  }

  return newList;
}
