library upstate;

import 'package:observable/observable.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';


class StateWidget extends StatelessWidget {
  final Widget child;
  final ObservableMap _state;
  var _context;

  StateWidget({@required this.child, @required Map state, Key key})
      : _state = toObservable(state),
        super(key: key);

  StreamSubscription subscribeTo(StatePath path, Function callback) {
    var stateValue;
    var stateIntermediatePath = _state;

    //travels down the state Map tree

    path.forEach((key) {
      key != path.last
          ? stateIntermediatePath = stateIntermediatePath[key]
          : stateValue = stateIntermediatePath[key];
    });

    //If your state value isn't a primitive, you can extend the Observable class to trigger changes.
    //otherwise, you will be subscribed to the [ObservableMap] that contains your state value.
    //Thus if your state value isn't a primitive or an Observable,
    //subscribed widgets will not update if you mutate your value object.
    //instead you can replace it with a new object.
    if (stateValue is Observable) {
      return stateValue.changes.listen((event) {
        callback();
      });
    } else {
      //listens to changes in the containing ObservableMap but only
      //fires the callback when the desired value is changed.
      return stateIntermediatePath.changes.listen((event) {
        for (ChangeRecord change in event) {
          if (change is MapChangeRecord && change.key == path.last) {
            callback();
          }
        }
      });
    }
  }

  StateWidget findAncestorStateWithKey(Key key){
    if(key==this.key){
      return this;
    } else{
      return StateWidget.of(_context)?.findAncestorStateWithKey(key);
    }
  }

  ObservableMap get state {
    return _state;
  }

  static of(BuildContext context, [Key key]) {
    var nearestAncestorState =
        context.findAncestorWidgetOfExactType<StateWidget>();
    if (key == null) {
      return nearestAncestorState;
    } else {
     return nearestAncestorState.findAncestorStateWithKey(key);
    }
  }

  operator [](var keyOrStatePath) {
    if (keyOrStatePath is StatePath) {
      var intermediateStatePath = _state;
      for (var key in keyOrStatePath) {
        if (key != keyOrStatePath.last) {
          intermediateStatePath = intermediateStatePath[key];
        } else {
          return intermediateStatePath[keyOrStatePath.last];
        }
      }
    } else {
      return _state[keyOrStatePath];
    }
  }

  operator []=(var keyOrStatePath, var value) {
    if (keyOrStatePath is StatePath) {
      var intermediateStatePath = _state;
      keyOrStatePath.forEach((key) {
        if (key != keyOrStatePath.last) {
          intermediateStatePath = intermediateStatePath[key];
        } else {
          intermediateStatePath[key] = value;
        }
      });
    } else {
      _state[key] = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return child;
  }
}

class StatePath extends ListBase {
  final List _path;

  StatePath(List path) : _path = path;

  int get length {
    return _path.length;
  }

  operator [](int index) => _path[index];

  void operator []=(int index, var value) {
    _path[index] = value;
  }

  set length(int newLength) {
    _path.length = newLength;
  }
}

mixin StateWidgetConsumer<T extends StatefulWidget> on State<T> {
  List<StreamSubscription> subscriptions = [];

  subscribeTo(StateWidget state, StatePath path) {
    subscriptions.add(state.subscribeTo(path, setStateSubscriptionCallback));
  }

  setStateSubscriptionCallback() {
    setState(() {});
  }

  cancelSubscriptions() {
    subscriptions.forEach((element) {
      element.cancel();
    });
  }
}

class StateBuilder extends StatefulWidget {
  final StateWidget state;
  final List<StatePath> paths;
  final Function builder;
  final Widget child;

  StateBuilder({@required this.state, @required this.paths, @required this.builder, this.child});

  @override
  _StateBuilderState createState() => _StateBuilderState();
}

class _StateBuilderState extends State<StateBuilder> with StateWidgetConsumer {

  @override
  void initState() {
    widget.paths.forEach((path){
      subscribeTo(widget.state, path);
    });
    super.initState();
  }

  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return widget.builder(context,widget.state, widget.child);
  }
}