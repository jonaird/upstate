library upstate;

import 'package:flutter/widgets.dart';
import 'dart:async';
import 'src/base.dart';
export 'src/base.dart';

//TODO: Remove unnecessary child from builder

class StateWidget extends InheritedWidget {
  final Widget child;
  final StateObject state;

  StateWidget({@required this.state, @required this.child, Key key})
      : super(key: key);

  @override
  bool updateShouldNotify(StateWidget oldWidget) {
    if (oldWidget.state != state) {
      oldWidget.state.unmount();
      return true;
    } else
      return false;
  }
}

mixin StateConsumerMixin<T extends StatefulWidget> on State<T> {
  List<StreamSubscription> subscriptions = [];

  subscribeToPaths(List<StatePath> paths, StateObject state) {
    for (var path in paths)
      subscriptions
          .add((state(path) as StateElement).subscribe(setStateCallback));
  }

  setStateCallback(event) {
    setState(() {});
  }

  cancelSubscriptions() {
    for (var sub in subscriptions) sub.cancel();
  }
}

class StateBuilder<T extends StateWidget> extends StatefulWidget {
  final List<StatePath> paths;
  final Widget Function(BuildContext context, StateObject state, Widget child)
      builder;
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
    return widget.builder(context, state, widget.child);
  }
}
