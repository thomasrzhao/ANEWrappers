# ANEWrappers
Objective-C wrappers around the Adobe AIR Native Extension (ANE) C API

## Why?
Because it turns this:

```objective-c
FREObject obj = argv[0];
uint32_t len;
const uint8_t* str;
if(FREGetObjectAsUTF8(obj, &len, &str) == FRE_OK) {
	NSLog(@"%@", [NSString stringWithUTF8String:(char*)str]);
}
```

into this:

```objective-c
NSLog(@"%@", [ANEObject objectWithFREObject:argv[0]].stringValue);
```

(If you're wondering why *now* when Flash is already in the throes of death, it's a long story involving Japan and an internship with lots of anime princesses)
## Setup
Add the files under src/ to your ANE project. 
**You will also need a copy of the FlashRuntimeExtensions.h header file** (not included for legal reasons). This can be found in the include folder present in the AIR SDK download.

## Usage
The two core classes are ANEObject and ANEContext. The APIs for both were designed to mirror that of the Java ANE API as closely as possible.

### ANEObject

ANEObject and its subclasses (ANEArray, ANEByteArray, ANEBitmapData) are wrappers around the FREObject opaque type, which is in turn a wrapper around an ActionScript object.

The ANEObject class makes it less annoying to pass data back and forth between ActionScript and Objective-C. For example, let's create a class that just prints something to the native device log from ActionScript.

```actionscript
public function nsLogMessage(message:String):void {
	_extensionContext.call("nsLogMessage", message);
}
```

```objective-c
FREObject nsLogMessage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	FREObject messageFREObject = argv[0]; //Retrieve the FREObject from the arguments
	ANEObject* messageWrapper = [ANEObject objectWithFREObject:messageFREObject]; //Wrap the FREObject into an ANEObject
	NSString* messageString = messageWrapper.stringValue; //Get the underlying string
	
	NSLog(@"%@", messageString); //Log the string
	return NULL;
}
```

Of course, there's no need to have so many variables, so the same thing can be written as:

```objective-c
FREObject nsLogMessage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	NSLog(@"%@", [ANEObject objectWithFREObject:argv[0]].stringValue);
	return NULL;
}
```

To pass data back to ActionScript, simply make a new ANEObject and return the underlying FREObject:

```objective-c
FREObject divideDoubleByTwo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
	double answer = [ANEObject objectWithFREObject:argv[0]].doubleValue / 2;
 	
	return [ANEObject objectWithDouble:answer].freObject;
}
```

#### Calling methods, setting properties

To call a method on an ActionScript object, just use callMethod:methodArgs: like so:

```objective-c
ANEObject* result = [aneObject callMethod:@"doSomething" methodArgs:[ANEObject objectWithInt:42], [ANEObject objectWithString:@"Life"], nil];
```

To get and set properties, you can use the getProperty: and setProperty:value: methods, or, more conveniently, the keyed subscripting syntax in Objective C:

```objective-c
aneObject[@"aProperty"] = [ANEObject objectWithInt:42];
ANEObject* value = aneObject[@"aProperty"];
```

#### ANEArray, ANEByteArray, ANEBitmapData

These subclasses offer more convenient access to their corresponding ActionScript types. To wrap an FREObject of one of these types, do one of the following:

```objective-c
//The object returned from [ANEObject objectWithFREObject:] will be of the correct subclass type, so just downcast to the right type
//This also applies to any methods in ANEObject that return an ANEObject*, such as callMethod:methodArgs: and setProperty:
ANEArray* anArray = (ANEArray*)[ANEObject objectWithFREObject:freArrayObject];
ANEArray* alsoAnArray = (ANEArray*)[aneObject callMethod:@"aMethodThatReturnsAnArray" methodArgs:nil];
```

```objective-c
//Alternatively, you can call objectWithFREObject: on the proper subclass directly and avoid having to cast
//However, if the FREObject passed in is not of the correct type, the return value will be nil
ANEArray* thisTooIsAnArray = [ANEArray objectWithFREObject:freArrayObject];
```

To create a new ActionScript Array/ByteArray/BitmapData from Objective-C, just call the appropriate factory method:

```objective-c
ANEArray* wowIMadeAnArray = [ANEArray arrayWithNumElements:10];
```

##### ANEArray

You can use normal NSArray-style syntax with ANEArray:

```objective-c
ANEObject* value = aneArray[42];
aneArray[42] = [ANEObject objectWithInt:0];
```

You can also use a foreach loop to iterate through the array:

```objective-c
for(ANEObject* obj in aneArray) {
	...
}
```

##### ANEByteArray and ANEBitmapData
These subclasses offer super-efficient access to their underlying data stores. However, to protect against concurrent memory access issues you must first acquire a lock before performing any access to their data. However, you **must not** call any other ANEObject methods while the lock is acquired.

```objective-c
ANEByteArray* byteArray = [ANEByteArray byteArray];
byteArray[@"length"] = 100; //Must set length _before_ acquiring lock
[byteArray acquireByteArray];
uint8_t* bytes = byteArray.bytes;
//Do stuff with bytes
[byteArray releaseByteArray];
```

### ANEContext

Just like how ANEObject is a wrapper around FREObject, ANEContext is a wrapper around FREContext:

```objective-c
ANEContext* context = [ANEContext contextWithFREContext:freContext];
```

You can set and get a shared ActionScript object by accessing the actionScriptData property:

```objective-c
ANEObject* sharedObject = context.actionScriptData;
```

The nativeData property is a convenient way to hold context-specific data, like so:
```objective-c
NSString* contextID = ...;
context.nativeData = (void*)CFBridgingRetain(contextID);
```

Because the nativeData is passed as-is to the C-side, make sure to insert the appropriate bridging calls for memory management.

To communicate asynchronously between native code and ActionScript, use the dispatchStatusEventAsyncWithCode:level: method:

```objective-c
[context dispatchStatusEventAsyncWithCode:@"DONE_DOING_THING" level:@"status"];
```


### Error Handling

If you attempt to do something that isn't allowed by the AIR runtime, like getting the doubleValue of a String:

```objective-c
ANEObject* obj = [ANEObject objectWithString:@"wat"];
double d = obj.doubleValue;
```

an NSException with the name ANEExceptionName will be thrown.

Most of the time, these exceptions should not be caught because they result from bugs in the Objective-C code. However, there is one case where you might need to catch the thrown exception. Methods that directly interact with or create ActionScript objects—objectWithClassName:, get/setProperty:, and callMethod:—may cause an ActionScript Error to be thrown. Ideally, you would handle this on the ActionScript side, but if that's not possible, you can retrieve the ActionScript Error object as follows:

```objective-c
@try {
    [anObject callMethod:@"aMethodThatThrows" methodArgs:nil];
}
@catch(NSException* e) {
    ANEObject* as3Error = e.userInfo[ANEExceptionErrorObjectKey];
    NSString* message = as3Error[@"message"].stringValue;
}
```

If you need to do this, make sure to enable the -fobjc-arc-exceptions compiler flag to prevent memory leaks.

### Potential Pitfalls

#### ANEObject Lifetime
Because FREObjects are only valid until the first FREFunction function on the call stack returns, it's important **NOT** to keep any ANEObjects around after. For example, if your ActionScript code calls myFunction:

```objective-c
FREObject myFunction(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    ... //Make as many ANEObjects you want here or in functions you call here
} //<- But there should be no more ANEObjects accessible at this point
```

If you attempt to keep an ANEObject beyond its valid lifetime, you'll get an exception when you try to manipulate it later. Don't do that.

#### ANEByteArray/ANEBitmapData Locks
As mentioned above, you need to lock ANEByteArray/ANEBitmapData objects before you can use them. However, it's important to note that **NO** other ANE API functions can be called in between the acquire and release statements. This is really easy to mess up and will result in a crash:

```objective-c
ANEObject* canIDoThis = ...
ANEByteArray* byteArray = ...
[byteArray acquireByteArray];
if (canIDoThis.boolValue) { ... } //BAD! This will crash
[byteArray releaseByteArray];
```

You can, however, acquire multiple ByteArray or BitmapData objects (but not both at the same time), as long as you don't call any other ANE methods in between. So this is legal:

```objective-c
//Must create the objects BEFORE acquiring any locks
ANEByteArray* src = ...
ANEByteArray* dest = ...
[src acquireByteArray];
[dest acquireByteArray];
memcpy(dest.bytes, src.bytes, src.length);
[dest releaseByteArray];
[src releaseByteArray];
```

Basically just don't touch anything except ANEByteArray/ANEBitmapData properties in between the acquire and release statements and you'll be fine.

#### Callbacks from Objective-C
The actionScriptData property of ANEContext is a convenient way to keep an ActionScript object alive between FREFunction calls. However, you **cannot** use it as a callback mechanism.

```objective-c
//This will NOT work!
- (void)didReceiveSuperImportantNotification:(NSNotification*)notification {
    [self.context.actionScriptData callMethod:@"didReceiveNotification" methodArgs:nil];
}
```

You can only call actionScriptData methods while inside a FREFunction call from ActionScript. In other words, you can't use it in between calls. In that case, use the dispatchStatusEventAsyncWithCode:level: method instead.

#### objectWithFREObject: Caveats
The objectWithFREObject: call behaves differently depending on the actual class in which it's executing.

[ANEObject objectWithFREObject:] will actually return the correct subclass depending on the FREObject that's passed in. So if you pass in an FREObject that represents an ActionScript ByteArray, you'll actually get an ANEByteArray object back, but upcasted to ANEObject. 

This does not apply to any of the subclasses however. If you attempt to call objectWithFREObject: on any ANEObject subclass, you will always get that subclass or nil. This also means that the objectWithInt:, objectWithBool:, etc. methods will always return nil if you call them on anything that's not an ANEObject.

This is to prevent the weird case of getting an ANEByteArray back from an ANEBitmapImage class method.

```objective-c
FREObject byteArrayObj = ...
ANEByteArray* byteArray = (ANEByteArray*)[ANEObject objectWithFREObject:byteArrayObj]; //OK
ANEByteArray* byteArrayToo = [ANEByteArray objectWithFREObject:byteArrayObj]; //OK
ANEBitmapImage* notABitmap = (ANEByteArray*)[ANEBitmapImage objectWithFREObject:byteArrayObj]; //returns nil
ANEByteArray* whatAreYouDoing = [ANEByteArray objectWithInt:42]; //returns nil
```
