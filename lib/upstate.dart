library upstate;

import 'package:flutter/widgets.dart';
import 'dart:async';
import 'src/base.dart';
export 'src/base.dart';

class StateWidget extends InheritedWidget {
  final Widget child;
  final StateObject state;

  StateWidget({@required this.state, @required this.child, Key key})
      : super(key: key);



  @override
  bool updateShouldNotify(StateWidget oldWidget) => oldWidget.state != this.state;
  
}

mixin StateConsumerMixin<T extends StatefulWidget> on State<T> {
  List<StreamSubscription> _subscriptions = [];

  subscribeToPaths(List<StatePath> paths, StateObject state) {
    paths.forEach((path) {
      _subscriptions
          .add(state.subscribeTo(path, _setStateSubscriptionCallback));
    });
  }

  _setStateSubscriptionCallback() {
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
  final Widget Function(BuildContext context, StateObject state, Widget child) builder;
  final Widget child;

  StateBuilder(
      {@required this.paths, @required this.builder, this.child, Key key})
      : super(key: key);

  @override
  _StateBuilderState createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T extends StateWidget> extends State<StateBuilder>
    with StateConsumerMixin {
  StateObject state;

  @override
  void didChangeDependencies() {
    cancelSubscriptions();
    state = StateObject.of<T>(context);
    subscribeToPaths(widget.paths, state);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context,state, widget.child);
  }
}
