library upstate;

import 'package:flutter/widgets.dart';
import 'dart:async';
import 'src/base.dart';
export 'src/base.dart';


///A simple inherited widget that is used to hold onto a [StateObject] or your own
///subclass of [RootStateElement] so that they can be accessed by children.
class StateWidget extends InheritedWidget {
  final Widget child;
  final RootStateElement state;

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

///Provides convenience functions for reducing the amount of boilerplate required
///for subscribing to changes to [StateElement]s within stateful widgets
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

/// Widget that will will call the builder on changes to any [StateElement] that is specified using [paths]. This
/// widget will use nearest [StateWidget] parent in the state tree to get its state. If you need a different
/// state higher up in the tree, you must create an empty subclass of StateWidgeth and then use
/// StateBuilder<YourStateWidget>.
class StateBuilder<T extends StateWidget> extends StatefulWidget {
  final List<StatePath> paths;
  final Widget Function(BuildContext context, StateObject state)
      builder;

  StateBuilder(
      {@required this.paths, @required this.builder, Key key})
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
    return widget.builder(context, state);
  }
}

/// CustomStateBuilder can be used to rebuild on state changes in multiple states in the widget tree or with a
/// custom state object that doesn't use [StatePath]s. Since the builder has access to the build context,
/// you can get whichever state you want or multiple states within the builder. Instead of a list of paths,
/// CustomStateBuilder takes a list of state elements and rebuilds on changes to any of them. This way you 
/// can subscribe to elements from different states.
class CustomStateBuilder extends StatefulWidget {
  final List<StateElement> elements;
  final Widget Function(BuildContext context)
      builder;

  CustomStateBuilder(
      {@required this.elements, @required this.builder, Key key})
      : super(key: key);

  @override
  _CustomStateBuilderState createState() => _CustomStateBuilderState();
}

class _CustomStateBuilderState extends State<CustomStateBuilder>
    with StateConsumerMixin {
 

  @override
  void didChangeDependencies() {
    cancelSubscriptions();
    for(var element in widget.elements)
      subscriptions.add(element.subscribe(setStateCallback));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}