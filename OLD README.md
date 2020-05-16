This readme is outdated but may contain useful information

# upstate
 
Upstate is a simplified state management library for Flutter. 

## Installation  
To use Upstate, add it to your dependencies in your pubspec.yaml file: 
```
dependencies:
  upstate:
``` 

## Usage 
To get started quickly check out the [examples](https://github.com/jonaird/upstate/tree/master/example/lib).  
 
(This tutorial is a bit long and messy. Will update it asap and include how to use state models.)
 
### State Model

Just like how everything onscreen is made up of a tree of widgets, in Upstate, your state is stored in a tree of state elements. There are 4 kinds of of state elements; StateMap, StateList, StateValue, and StateObject. As their names imply, StateMap is a map that contains StateElements as values, StateList is a list of StateElements, and StateValues contain the values of your state (Technically StateMap and StateList are StateElements that implement map and list mixins respectively). Pretty simple, right? StateObject is a StateMap that is the root element of the state tree. StateMap keys must be strings. Each StateElement uses a broadcast stream behind the scenes to notify and update widgets if the state has changed. Upstate uses the "lifting state up" pattern to provide its state to all descendent widgets.:
```
void main() {
  runApp(StateWidget(
    state: StateObject({"counter": 0}),
    child: MyApp())
  );
}
```
Notice that while our state data is being stored as state elements, StateObject accepts a map/list tree with normal objects. This should be very familiar to those coming from React as it is similar to a components state.
While StateLists and StateMaps implement their respective mixins, they don't behave exactly the same way as lists and maps. StateMaps are immutable (with one exception that we will get into later on) and StateLists return StateElements but accept regular objects as new elements (the conversion to StateElements is handled automatically including deep maps and lists).
Why are StateMaps immutable? To achieve our vision of completely reactive state management we need to clearly define the structure of our state from the get go. If we start changing the structure of our state implicitly, widgets that depend on a particular part of our state may no longer be able to access the data they need. If you really need to modify the structure of your state at runtime, you can use StateLists.
Getting State
To access our state conveniently we will need StatePaths. A StatePath is simply a list that only accepts strings or ints as elements and represents a certain path in a state tree. There are two ways of updating widget upon state changes; with a State mixin (for stateful widgets) or with a builder.
Let's look at a stateful widget using the counter example (see the full source code for all here). First we need to use our mixin:
```
class _MyHomePageState extends State<MyHomePage> with StateConsumerMixin { 
  StateObject state;
  var countPath = StatePath(['counter']);
  //...widget body
}
```
Then we need to override two methods; didChangeDependencies and dispose:
```
@override
void didChangeDependencies() {
  cancelSubscriptions();
  state = StateObject.of(context);
  subscribeToPaths([countPath], state);
  super.didChangeDependencies();
}
@override
void dispose() {
  cancelSubscriptions();
  super.dispose();
}
```
What's going on here? We need to use didChangeDependencies because StateWidget is an inherited widget (and dependOnInheritedWidgetOfExactType  is called in StateObject.of). Don't worry though! This method is NOT called every time the state changes. It is only called when the entire StateObject is replaced with a new one. By subscribing to a path, setState is called automatically whenever the StateElement at that path changes. If the entire StateObject has been replaced, that state element has been removed from the tree and is no longer the valid one for the path so we need to cancel our subscriptions if that happens at the beginning of didChangeDepenencies.
By default, if a StateElement has changed, it will notify all of its ancestors up the tree that they have changed as well. This means that we could have used the following:
  `subscribeToPaths([StatePath([])],state);` 
   

This would have subscribed us to the root state object which is notified when one of its descendants  changes. To disable this we can set the optional argument to our state object:
var state= StateObject({'counter':0},elementsShouldNotifyParents:false);
Using State
To get a state value, we use the call method on the instantiated state object and pass the state path. To access or change the value we use the value property:
```void _incrementCounter() {
   state(counterPath).value++;
}
And in our build method:
Text(
  state(counterPath).value.toString(),
  style: Theme.of(context).textTheme.headline4,
),
```
Instead of the call method you can also use [] operators:
`int deepValue = state['some']['deep']['path'][1]['counter'].value` 
 

We can store the state value element in a variable but we should do so in our build method for reasons we'll get to later on.
```class _MyHomePageState extends State<MyHomePage> with StateConsumerMixin { 
  StateObject state;
  var countPath = StatePath(['counter']);
  StateValue count;
  @override
  void didChangeDependencies() {
    cancelSubscriptions();
    state = StateObject.of(context);
    subscribeToPaths([countPath], state); 
    super.didChangeDependencies();
    }
  void _incrementCounter() {
     count.value++;
  }
  @override 
  Widget build(BuildContext context){ 
  count = state(counterPath);
//...widget body
}
```
Using the builder is even simpler and removes almost all the boilerplate:
```class MyHomePage extends StatelessWidget { 
  final counterPath = StatePath(['counter']);
  @override
  Widget build(BuildContext context) { 
    // getting state is O(1) so it's totally
    // fine to put it in our build method 
    var state = StateObject.of(context);
    void _incrementCounter() {
      state(counterPath).value++;
    }
    return //..rest of the build method
    
      StateBuilder(
        paths: [counterPath],
        //child: you can specify a child that's passed to builder
        builder: (context, state, child) {
          return Text(
            state(counterPath).value.toString(),
            style: Theme.of(context).textTheme.headline4,
        );})
  //...rest of the build method
```
You should make sure that your builder is as shallow as possible using 'child:' so Flutter only rebuilds what is necessary upon a state change. The paths argument is the paths that the builder will subscribe to in order to rebuild. Notice that if a widget only needs to change state but doesn't need rebuild (i.e. it's not actually using the state to display something), you can get the state in the build method of a stateless widget and mutate it when you need to. Alternatively, if you just need to display state, you can use the builder without getting state in the build method.
Using Multiple States
But what if you want to use multiple StateWidgets? For example, you may need a global state for your whole app and a state for a particular section of your app. Doing this is very easy. First extend StateWidget with your own widget class:
```void main() {
  runApp(GlobalState(
    state: StateObject({"counter": 0}),
    child: MyApp())
  );
}
class GlobalState extends StateWidget{ 
  GlobalState({@required StateObject state, @required Widget child}) 
    :super(state:state, child:child);
}
```
Then specify your new class using generics when getting your state:
```var state = StateObject.of<GlobalState>(context);
or
StateBuilder<GlobalState>( 
  //...
)
```
If you don't provide the generic types, it will look for a StateWidget specifically and not a subclass.
Using JSON
It is very common to store and retrieve app state as JSON. Thus, Upstate comes with convenience methods for doing so:
```var state = StateObject({"counter": 0});
var json = state.toJson();
var newState = StateObject.fromJson(json);
print(newState['counter'].value); //prints 0
```
With this feature, you can even easily store your users' app state on the backend!
Types
By default, Upstate is dynamically typed. This means that you can set a state value to any new value regardless of type. If you want type checking, you can set the typing argument and then state values can only be replaced with values of the same type. This is useful if functionality in your app requires a specific type and you want to make sure never to provide a value of a different type.
```var state = StateObject({"counter": 0} , typing: StateValueTyping.strongTyping);
print(state['counter'].runtimeType); //prints StateValue<double>
state['counter'].value = 'hello'; //throws an error
Luckily the built in JSON encoding will recognize ints and use a decimal place in the resulting string. But what if you're getting data from a restful API that doesn't distinguish between ints and doubles? You can use the built in numConverter (we will get more into converters later on).
var state = StateObject({"counter": 0},
  typing:StateValueTyping.strongTyping,   
  converter:numConverter); 
state(counterPath).value=1.2; //runs without error
print(obj(counterPath).runtimeType); //  prints StateValue<num>
```
### The Null Exception
Having a null value in your state is a tricky situation. By default, nulls will be stored in a StateValue<dynamic> so you can change it to anything without any issues. But if you want full strong typing that's possible as well
```var state = StateObject({"counter": null}, typing: StateValueTyping.nonNullable);
print(state(counterPath).runtimeType); //  prints StateValue<Null>
state(counterPath).value=0; //throws an error 
```
Note that this does not implement Darts new non-nullable types. It just enforces strong typing for all values including null and prevents new values from being null.
To modify the value we need to instantiate the path with a new value:
```var state = StateObject({"counter": null}, typing:
  StateValueTyping.nonNullable); 
var count = state(counterPath); 
print(count.runtimeType); // prints StateValue<Null>
count = count.instantiate(0);
print(count.runtimeType) //  prints StateValue<int>
We can do this much more simply without saving our state value as a variable:
var state = StateObject({"counter": null}, typing: StateValueTyping.nonNullable); 
state(counterPath).instantiate(0);
print(state(counterPath).runtimeType) //  prints StateValue<int> 
```
Please note if you are using nonNullable and you are storing state values in variables in initState or in didChangeDependencies you will run into issues (it's best never to do this). This is because instantiating actually replaces the null state value with a completely new value (this is the exception to StateMap immutability). Instead just store them in your build method.
Advanced Features
Upstate works out of the box with primitive values (int, double, bool, String, Map and List) but what if you want to store any type of object in your state? The easiest way is with dynamic typing. You can even mutate objects instead of replacing them and still update your state using the notifyChange method:
```void main() {
  runApp(StateWidget(
    state: StateObject({"counter": Counter()}),
    child: MyApp())
  );
}
class Counter{ 
  int count=0; 
  void increment(){
    count++;
  }
}
and when accessing your state:
void _increment(){ 
   var count = state(counterPath)
   count.value.increment(); 
   count.notifyChange();
} 
```
If you instead replace the value with a new object, you don't have to notify changes.
If you want to use non-primitives and strong typing you can do so with the converter argument:
```void main() {
  runApp(StateWidget(
    state: StateObject({"counter": Counter()}, typing: StateValueTyping.strongTyping, converter:converter),
    child: MyApp())
  );
}
StateValue converter(value, StateElement parent){
  if(value is Counter){
    return StateValue<Counter>(value, parent)
  } else{
   return null;
} 
```
The Cherry on top:  Strongly Typed JSON serialization!
Being able to use non-primitives is great but, we will almost always have to save our state as JSON locally when our app closes. It would be great if we could automatically restore our non-primitives. Well, we can! To convert from JSON we just use our converter:
```StateValue converter(value, StateElement parent){
  if(value is DateTime){
    return StateValue<DateTime>(value, parent)
  } 
  //This is the JSON condition
  if(value is String){ 
    bool isDate = true; 
    DateTime date; 

    //It would be much better to use RegEx here 
    //but you get the idea...
    try{
      date=DateTime.parse(value); 
    } catch(err){ 
       isDate=false;
    } 
    if(isDate){ 
      return StateValue<DateTime>(date, parent);
    } else {
       return null
    }
  } else{
   return null;
} 
```
For converting to JSON we just need to give DateTime a toPrimitive method:
```extension on DateTime{ 
  toPrimitive()=>this.toIso8601String();
} 
```
Now we can do this!
```var state = StateObject({'birthday':DateTime.utc(1991, 11, 29)},
  typing: StateValueTyping.strongTyping, converter:converter); 
var json = state.toJson(); 
state=StateObject.fromJson(json, typing:
  StateValueTyping.strongTyping, converter:converter); 
print(state['birthday'].value.day) //prints 29```
Magic!
We can even have complex objects that store multiple variables:
```class Person { 
  String name; 
  DateTime birthday; 
  Person(this.name, this.birthday); 
  
  toPrimitive(){
    return {
      'type':'Person', 
      'name':name, 
      'birthday':birthday.toPrimitive()
    }} 
```
In our converter method:
```StateValue converter(value, StateElement parent){ 
  if(value is map && value['type']=='Person'){ 
    var birthday = DateTime.parse(value['birthday']);
    var person = Person(value['name'], birthday);
    return StateValue<Person>(person, parent);
  }
  //... rest of the converter method
} 
```
### Quick Tips

If you're changing the structure of your state around a lot you can save your commonly used state paths in a different file and import it so you only have to change them once.