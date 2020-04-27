# Introducing Upstate: Simplified State Management for Flutter

When I first started using Flutter, it felt like a revelation. I had never used a framework that was so simple, easy, fun and powerful. With other UI frameworks, it wouldn’t be long before I had to hack a solution together to get the exact behavior that I wanted. It was like running into a brick wall that was the design decisions of whoever created the framework. In Flutter, whenever I needed something that wasn’t included as a built in widget, I could build it myself using the lower level apis. Not only that, but I could do it fast and just by reading the documentation! Flutter created the new world of developer experience (DX).
But there’s one part of writing Flutter apps that still feels like being stuck in the old world. That is, you guessed it, state management. Now that is not to say that the solutions out there are bad. But can you really say they’re as simple, easy, fun, and powerful as the rest of Flutter? This comment on a [presentation](https://www.youtube.com/watch?v=d_m5csmrf7I) where the Flutter team announced that they’re now recommending the Provider package instead of the BLoC pattern really sums it up pretty well. 
![comment](https://miro.medium.com/max/1400/1*JUNm5S9He87LvH2L-NmGqQ.png) 
Or how about this post on the Flutter subreddit:
![](https://miro.medium.com/max/1400/1*gvdq13Za66eBP5lb7jL77w.jpeg) 
 
 Can’t we do better than this? Why can’t state management be easy and powerful at the same time? That’s why I created Upstate. I wanted a state management solution that is both feet in this new world. Upstate is highly performant and powerful with advanced, dart specific typing functionality and yet is very easy to use. If all you need is something simple, you can be up and running in no time and if you need more advanced features, they’re available to you at your fingertips
## Features:
Built from the ground up in Dart with Dart features in mind
Completely reactive/declarative. Update your state anywhere and your app updates everywhere.
Highly performant.
See your state in code and modify it easily.
Interact with state in a similar way that you would with local variables.
Minimal API that feels native to the rest of the Framework.
Extremely small amount of boilerplate.
Powerful and extensible typing system with seamless conversion to and from JSON
Without further ado, let’s take a look into how it works:

## Usage 
In Upstate, our app state is stored in state objects that use a map/list tree to build itself:
var state = StateObject({'counter':0});
To use our state, we will use a state widget (who would have thunk?). Here’s what it looks like:
```void main() {
  runApp(StateWidget(
    state: StateObject({'counter':0}),
    child: MyApp())
  );
}
```
That’s all we have to do to initialize our state! Getting our state from somewhere else in our app is just as simple.  

`var state = StateObject.of(context);`  

The values in our state are stored in StateValue objects.  

`print(state['counter'].runtimeType); //prints StateValue<dynamic>`   

To access or change our state we use the value property.  

```print(state['counter'].value); // prints 0;
state['counter'].value++;
```
In Upstate we also have a helper class called StatePath. State paths are just simple lists that are used to represent a particular path in your state:
```var path = StatePath(['counter']);
print(path[0]); //prints 'counter'
```
We can use state paths as a shortcut to get state elements with a state object’s [call](https://dart.dev/guides/language/language-tour#callable-classes) method:
```
StateValue counter = state(path);
To update our UI upon a state change we can use a builder. Here we will need a state path.
StateBuilder( 
  // providing this path will call 
  // the builder on a change of the state element at that path
  paths:[StatePath(['counter'])], 
  //child:used to pass a child to the builder 
  builder:(context, state, child){ 
    return Text(state['counter'].value.toString());
})
```
That’s all you need to get started! You can also rebuild a stateful widget on value changes, use multiple state widgets in your widget tree, convert to or from JSON with one line of code and get hot and heavy with strong typing. Check out the [documentation](https://github.com/jonaird/upstate) on github for more info.

## State Models
Upstate works out of the box with primitive values making it perfect for new developers. However, Upstate is fully extensible and you can use it with traditional state models. Let’s create a counter model:
```class Counter{ 
  var value = 0; 
} 
class CounterModel extends StateElement{
  Counter _dataModel; 
  
  CounterStateValue(Counter model, 
    StateElement parent):super(parent){ 
      _dataModel=model;
  } 
  void increment(){ 
   _dataModel.value++; 
    notifyChange();
  } 
  
  int get count=> _dataModel.value; 
}
```
We also need a converter function that will automatically convert our counter data model to a state element:
```StateElement converter(obj, parent){ 
  if(obj is Counter){ 
    return CounterModel(obj, parent);
  } else { 
    return null;
  }}
```
Now we can use our models in our state:
```var state = StateObject({'counter':Counter()}, 
  converter:converter);
state['counter'].increment();
print(state['counter'].count); //prints 1
```
## Performance
Upstate is highly performant. If you don’t believe me check out this demo ([source code](https://github.com/jonaird/upstate_performance_test), [live demo](https://jonaird.github.io/upstate_perf_test_public/)). On the left is an image whose size is being set in a stateful widget using an animation controller. But that animation controller is also doing something else! It is also setting a size value using Upstate. On the right we have a stateless widget that is using Upstate to get its size and rebuilding automatically. That means our state is being set and our stateless widget is being rebuilt on every frame. This is possible because behind the scenes, Upstate is just using a stream and setState. Obviously, you shouldn’t actually do this!

## Considerations
All of that’s great but can you actually use this in a real production app? Frankly, this is a new pattern and I really don’t know. I suspect that it will work well up to medium sized apps. But it is very easy to integrate easily into existing apps and perfect for a smaller part of an app that only needs local state.
Conclusion
Flutter is still a nascent framework and there are often some kinks that you have to work through when developing a real, sizable app. But more likely than not, you can relate to me when I say that I cannot stop having fun with it! As someone who has been fascinated by and obsessed with UI’s since a young teenager, using Flutter to create them is the dream I never new was possible. I’ve done my best to create the state management library that should have been, something that completely aligns with the rest of the framework in its simplicity and elegance. Hopefully I’ve lived up to that goal!
Cheers and happy coding!