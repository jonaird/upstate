import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:upstate/upstate.dart';

void main() {
  Map a = <String, dynamic>{
    'a': 1,
    "b": 2.2,
    "c": [
      'a',
      'b',
      2.6,
      {"a": false}
    ],
    "d": {
      "deeper": {"evenDeeper": 'a string'}
    }
  };

  test('to and from json should result in same values', () {
    var first = StateObject(a);
    var json = first.toJson();
    var second = StateObject.fromJson(json);

    expect(first.toJson(), second.toJson());
  });

  test('Json encoding works for nested values', () {
    var path = StatePath(['c', 3, 'a']);
    var obj = StateObject(a);
    var json = obj.toJson();
    var obj2 = StateObject.fromJson(json);

    expect(obj2(path).value, false);
  });

  test('remove from state tree works recursively', () {
    var path = StatePath(['c', 3, 'a']);
    var obj = StateObject(a);
    var value = obj(path);
    obj.removeFromStateTree();

    expect(value.removedFromStateTree, true);
  });

  test('change in value notifies ancestors', () {
    var path = StatePath(['c', 3, 'a']);
    var obj = StateObject(a);
    bool notified = false;

    var subscription = obj.changes.listen((event) {
      notified = true;
      expect(notified, true);
    });

    obj(path).value = true;

    subscription.cancel();
  });

  test('initializing a null state value works', () {
    var b = StateObject({'a': null});
    var c = b['a'] as StateValue;
    c = c.initialize<int>(5);

    expect(c.value, 5);
  });
  test('initializing a null state value removes it from the tree', () {
    var b = StateObject({'a': null});
    var c = b['a'] as StateValue;
    bool removed = false;
    var sub = c.changes.listen((event) {
      if (event == StateElementChangeRecord.removedFromStateTree) {
        removed = true;
      }
    });
    c = c.initialize<int>(5);
   
    Timer(Duration(milliseconds: 200), () {
      sub.cancel();
      expect(removed, true);
    });
  });

  test('useNums:true allows int and double interchangeably', () {
    var b = StateObject({'a': 1}, useNums: true);
    var c = b['a'] as StateValue;
    c.value = 5.5;

    expect(c.value, 5.5);
  });

  test('useNum:false disallows int and double interchangeably', () {
    var b = StateObject({'a': 1}, useNums: false);
    var c = b['a'] as StateValue;
    bool err = false;
    try {
      c.value = 5.5;
    } catch (error) {
      err = true;
    }

    expect(err, true);
  });

  test('stronglyTyped:false allows any value', (){
    var b = StateObject(a, stronglyTyped: false);
    var path = StatePath(['a']);
    bool err = false;

    try{
      b(path).value=1;
      b(path).value=null;
    }catch(error){
      err=true;
    }
    expect(err,false);
  });
}
