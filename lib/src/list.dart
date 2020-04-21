import 'base.dart';
import 'dart:collection';


//TODO: should override List methods to only notify once for batch changes
class StateList extends StateElement with ListMixin {
  List<StateElement> _list;
  final StateElement parent;
  final StatePath path;

  StateList(List list, this.path, this.parent) {
    _list = toStateElementList(list, path, this);
  }

  operator [](int index) => _list[index];

  operator []=(int index, value) {
    if (_list[index] != value) {
      _list[index] = value;
      notifyChange();
    }
  }

  int get length => _list.length;

  set length(int newLength) {
    _list.length = newLength;
  }

  @override 
  void addAll(Iterable iterable){
    iterable.forEach((element) {
      StatePath newPath = StatePath.from(path);
      newPath.add(_list.length);
      _list.add(toStateElement(element,newPath,this));
    });
    notifyChange();
  }

  @override 
  void clear(){
    _list.forEach((element) {element.removeFromTree();});
    _list.clear();
    notifyChange();
  }

  @override 
  void fillRange(int start, int end, [fillValue]){
    var newFillValue = fillValue;
    if(fillValue!=null){
      newFillValue = toStateElement(fillValue, path, this);
    }
    _list.fillRange(start, end, newFillValue);
    notifyChange();
  }

}

List<StateElement> toStateElementList(
    List list, StatePath path, StateElement parent) {

  List<StateElement> newList = [];

  for (int i = 0; i < list.length; i++) {
    StatePath newPath = StatePath.from(path);
    newPath.add(i);
    newList.add(toStateElement(list[i], newPath, parent));
  }

  return newList;
}
