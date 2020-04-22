library upstate;

import 'package:flutter/material.dart';
import 'dart:async';
import 'src/base.dart';
import 'src/maps.dart';

class StateWidget extends InheritedWidget {
  final Widget child;
  final StateObject _state;

  StateWidget({@required this.child, @required state, Key key})
      : _state = state,
        super(key: key);

  StateObject get state {
    return _state;
  }

  @override
  bool updateShouldNotify(StateWidget oldWidget) {
    oldWidget.state.removeFromStateTree();
    return oldWidget.state != this._state;
  }
}

mixin StateWidgetConsumer<T extends StatefulWidget> on State<T> {
  List<StreamSubscription> _subscriptions = [];

  subscribeToPaths(List<StatePath> paths, StateObject state) {
    paths.forEach((path) {
      _subscriptions.add(state.subscribeTo(path, setStateSubscriptionCallback));
    });
  }

  setStateSubscriptionCallback() {
    setState(() {});
  }

  cancelSubscriptions() {
    _subscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }
}

class StateBuilder<T extends StateWidget> extends StatefulWidget {
  final List<StatePath> paths;
  final Function builder;
  final Widget child;

  StateBuilder(
      {@required
          this.paths,
      @required
          this.builder(BuildContext context, StateObject state, Widget child),
      this.child});

  @override
  _StateBuilderState createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T extends StateWidget> extends State<StateBuilder>
    with StateWidgetConsumer {
  StateObject _state;

  @override
  void didChangeDependencies() {
    cancelSubscriptions();
    _state = context.dependOnInheritedWidgetOfExactType<T>().state;
    subscribeToPaths(widget.paths, _state);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state, widget.child);
  }
}
