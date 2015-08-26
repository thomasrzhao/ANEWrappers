//
//  ANEObject.m
//  ANEWrappers
//
//  Created by thomasrzhao on 8/24/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

@import Foundation;
#import "FlashRuntimeExtensions.h"
#import "ANECommon.h"

@interface ANEObject : NSObject

@property (readonly) FREObject freObject;

- (instancetype) init __attribute__((unavailable("use the objectWithX: factory methods instead")));

+ (instancetype) objectWithInt:(int32_t)value;
+ (instancetype) objectWithUnsignedInt:(uint32_t)value;
+ (instancetype) objectWithBool:(BOOL)value;
+ (instancetype) objectWithDouble:(double)value;
+ (instancetype) objectWithString:(NSString*)value;

+ (instancetype) objectWithClassName:(NSString*)className constructorArgs:(ANEObject*)args, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype) objectWithClassName:(NSString*)className constructorArgs:(ANEObject*)firstArg vaList:(va_list)vaList;

//The NSArray argument should only contain ANEObject*
+ (instancetype) objectWithClassName:(NSString*)className constructorArgsArray:(NSArray*)argsArray;

//This factory method will return an ANEObject that can be downcasted to a subtype (ANEArray, ANEByteArray, ANEBitmapData) if the underlying FREObject corresponds to one of those types
//This magic boxing only works if you call objectWithFREObject: on the ANEObject class. For example, [ANEArray objectWithFREObject:obj] will only ever return an ANEArray object or nil (if the FREObject is not an array type).
+ (instancetype) objectWithFREObject:(FREObject)value;

@property (readonly) int32_t intValue;
@property (readonly) uint32_t unsignedIntValue;
@property (readonly) BOOL boolValue;
@property (readonly) double doubleValue;
@property (readonly) NSString* stringValue;
@property (readonly) FREObjectType freObjectType;
@property (readonly, getter=isNull) BOOL null;

- (ANEObject*) getProperty:(NSString*)propertyName;
- (void) setProperty:(NSString*)propertyName value:(ANEObject*)propertyValue;

- (ANEObject*) callMethod:(NSString*)methodName methodArgs:(ANEObject*)args, ... NS_REQUIRES_NIL_TERMINATION;
- (ANEObject*) callMethod:(NSString*)methodName methodArgs:(ANEObject*)firstArg vaList:(va_list)vaList;
- (ANEObject*) callMethod:(NSString*)methodName methodArgsArray:(NSArray*)argsArray;

- (ANEObject*) objectForKeyedSubscript:(NSString*)key;
- (void) setObject:(ANEObject*)obj forKeyedSubscript:(NSString*)key;
@end