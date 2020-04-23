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

  test('Json encoding works for nested values',(){
    var path = StatePath(['c',3,'a']);
    var obj  = StateObject(a);
    var json = obj.toJson();
    var obj2 = StateObject.fromJson(json);

    expect(obj2(path).value,false);

  });

  test('remove from state tree works recursively',(){
    var path = StatePath(['c',3,'a']);
    var obj  = StateObject(a);
    var value = obj(path);
    obj.removeFromStateTree();

    expect(value.removedFromStateTree,true);
  });

  test('change in value notifies ancestors',(){
    var path = StatePath(['c',3,'a']);
    var obj  = StateObject(a);
    bool notified = false;

    var subscription = obj.changes.listen((event) {notified=true;
      expect(notified,true);
    });

    obj(path).value=true;

    
    subscription.cancel();


  });

  test('double/int test', (){
    double z =1;
    var obj = StateObject({'a':z});
    obj = StateObject.fromJson(obj.toJson());
    var path = StatePath(['a']);

    print(obj.toJson()+' hello');
    print(obj(path).value.runtimeType);
    expect(1.2,1.2);

  });

}
