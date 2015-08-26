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
ANEObject* result = [aneObject callMethod:@"aMethod" methodArgs:[ANEObject objectWithInt:42], [ANEObject objectWithString:@"Hello World"], nil];
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
ANEArray* array = (ANEArray*)[ANEObject objectWithFREObject:freArrayObject];
ANEArray* array2 = (ANEArray*)[aneObject callMethod:@"aMethodThatReturnsAnArray" methodArgs:nil];
```

```objective-c
//Alternatively, you can call objectWithFREObject: on the proper subclass directly and avoid having to cast
//However, if the FREObject passed in is not of the correct type, the return value will be nil
ANEArray* array = [ANEArray objectWithFREObject:freArrayObject];
```

To create a new ActionScript Array/ByteArray/BitmapData from Objective-C, just call the appropriate factory method:

```objective-c
ANEArray* array = [ANEArray arrayWithNumElements:10];
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
NSData* data = byteArray.data;
//Do stuff with data
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

To communicate asynchronously between the ANE and ActionScript, use the dispatchStatusEventAsyncWithCode:level: method:

```objective-c
[context dispatchStatusEventAsyncWithCode:@"DONE_LOADING" level:@"status"];
```


### Error Handling

If you attempt to do something that isn't allowed by the AIR runtime, like getting the doubleValue of a String:

```objective-c
ANEObject* obj = [ANEObject objectWithString:@"wat"];
double d = obj.doubleValue;
```

An NSException with the name ANEExceptionName will be thrown.