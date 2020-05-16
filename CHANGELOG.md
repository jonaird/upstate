## [0.6.0] - Added ability for custom state objects plus first breaking change
 
First breaking change: StateBuilder no longer has a child argument. Passing a child to a builder
is used in cases where high performance is needed in the case that the builder is being called
on every frame for example. Instead of doing this, consider storing a stream in upstate and use a 
stream builder. 

For more information on custom state objects see [this article](https://medium.com/@jonathan.aird/using-upstate-with-any-kind-of-state-object-599b01ec4751)

## [0.5.2] - Added option for complete type safety

## [0.5.1] - updated readme and small changes to enable state models

## [0.5.0] - initial beta release


