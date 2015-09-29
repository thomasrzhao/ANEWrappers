//
//  ANEObject.m
//  ANEWrappers
//
//  Created by thomasrzhao on 8/24/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

#import "ANEObject.h"
#import "ANECommon_Private.h"
#import "ANEArray.h"
#import "ANEByteArray.h"
#import "ANEBitmapData.h"

static NSUInteger ANE_countVarargs(ANEObject* firstArg, va_list argsList) {
    va_list countList;
    va_copy(countList, argsList);
    
    NSUInteger count = 0;
    
    for(ANEObject* arg = firstArg; arg != nil; arg = va_arg(countList, ANEObject*)) {
        count++;
    }
    
    va_end(countList);
    
    return count;
}

static void ANE_freObjectsFromVarargs(ANEObject* firstArg, va_list argsList, FREObject* freObjects) {
    va_list copyList;
    va_copy(copyList, argsList);
    
    NSUInteger i;
    ANEObject* arg;
    
    for(i = 0, arg = firstArg; arg != nil; i++, arg = va_arg(copyList, ANEObject*)) {
        freObjects[i] = arg.FREObject;
    }
    
    va_end(copyList);
}

static FREObjectType ANE_getObjectType(FREObject obj) {
    FREObjectType type;
    ANE_assertOKResult(FREGetObjectType(obj, &type));
    return type;
}

@implementation ANEObject
- (instancetype) init {
    NSAssert(NO, @"init is not allowed, use the objectWithX: methods instead");
    return nil;
}

- (instancetype) initWithFREObject:(FREObject)obj {
    self = [super init];
    if(self) {
        if(!obj) { return nil; }

        _FREObject = obj;
    }
    return self;
}

+ (ANEObject*) objectWithInt:(int32_t)value {
    FREObject obj;
    ANE_assertOKResult(FRENewObjectFromInt32(value, &obj));
    return [ANEObject objectWithFREObject:obj];
}

+ (ANEObject*) objectWithUnsignedInt:(uint32_t)value {
    FREObject obj;
    ANE_assertOKResult(FRENewObjectFromUint32(value, &obj));
    return [ANEObject objectWithFREObject:obj];
}

+ (ANEObject*) objectWithBool:(BOOL)value {
    FREObject obj;
    ANE_assertOKResult(FRENewObjectFromBool(value, &obj));
    return [ANEObject objectWithFREObject:obj];
}

+ (ANEObject*) objectWithDouble:(double)value {
    FREObject obj;
    ANE_assertOKResult(FRENewObjectFromDouble(value, &obj));
    return [ANEObject objectWithFREObject:obj];
}

+ (ANEObject*) objectWithString:(NSString*)value {
    FREObject obj;
    NSData* stringData = [value dataUsingEncoding:NSUTF8StringEncoding];
    ANE_assertOKResult(FRENewObjectFromUTF8((uint32_t)(stringData.length), (uint8_t*)stringData.bytes, &obj));
    return [ANEObject objectWithFREObject:obj];
}

+ (instancetype) objectWithClassName:(NSString*)className constructorArgs:(ANEObject*)args, ... {
    ANEObject* result;
    
    va_list argsList;
    va_start(argsList, args);
    
    result = [self objectWithClassName:className constructorArgs:args vaList:argsList];
    
    va_end(argsList);
    
    return result;
}

+ (instancetype) objectWithClassName:(NSString *)className constructorArgs:(ANEObject*)firstArg vaList:(va_list)vaList {
    FREObject resultObj;
    
    NSUInteger count = ANE_countVarargs(firstArg, vaList);
    
    FREObject exception;
    if(count) {
        FREObject freArgs[count];
        ANE_freObjectsFromVarargs(firstArg, vaList, freArgs);
        
        ANE_assertOKResultException(FRENewObject((uint8_t*)[className UTF8String], (uint32_t)count, freArgs, &resultObj, &exception), exception);
    } else {
        ANE_assertOKResultException(FRENewObject((uint8_t*)[className UTF8String], 0, NULL, &resultObj, &exception), exception);
    }
    
    return [self objectWithFREObject:resultObj];
}

+ (instancetype) objectWithClassName:(NSString *)className constructorArgsArray:(NSArray *)argsArray {
    FREObject resultObj;
    
    FREObject exception;
    if(argsArray.count) {
        FREObject freArgs[argsArray.count];
        
        for(NSUInteger i = 0; i < argsArray.count; i++) {
            freArgs[i] = ((ANEObject*)argsArray[i]).FREObject;
        }
        
        ANE_assertOKResultException(FRENewObject((uint8_t*)[className UTF8String], (uint32_t)argsArray.count, freArgs, &resultObj, &exception), exception);
    } else {
        ANE_assertOKResultException(FRENewObject((uint8_t*)[className UTF8String], 0, NULL, &resultObj, &exception), exception);
    }
    
    return [self objectWithFREObject:resultObj];
}

+ (instancetype) objectWithFREObject:(FREObject)obj {
    if([self class] == [ANEObject class]) {
        FREObjectType type = ANE_getObjectType(obj);
        
        if(type == FRE_TYPE_ARRAY || type == FRE_TYPE_VECTOR) {
            return [[ANEArray alloc] initWithFREObject:obj];
        } else if (type == FRE_TYPE_BYTEARRAY) {
            return [[ANEByteArray alloc] initWithFREObject:obj];
        } else if (type == FRE_TYPE_BITMAPDATA) {
            return [[ANEBitmapData alloc] initWithFREObject:obj];
        }
    }
    
    return [[self alloc] initWithFREObject:obj];
}

- (int32_t) intValue {
    int32_t val;
    ANE_assertOKResult(FREGetObjectAsInt32(self.FREObject, &val));
    return val;
}

- (uint32_t) unsignedIntValue {
    uint32_t val;
    ANE_assertOKResult(FREGetObjectAsUint32(self.FREObject, &val));
    return val;
}

- (BOOL) boolValue {
    uint32_t val;
    ANE_assertOKResult(FREGetObjectAsBool(self.FREObject, &val));
    return val;
}

- (double) doubleValue {
    double val;
    ANE_assertOKResult(FREGetObjectAsDouble(self.FREObject, &val));
    return val;
}

- (NSString*) stringValue {
    uint32_t len;
    const uint8_t* str;
    ANE_assertOKResult(FREGetObjectAsUTF8(self.FREObject, &len, &str));
    
    return [NSString stringWithUTF8String:(char*)str];
}

- (ANEObject*) getProperty:(NSString*)propertyName {
    FREObject propertyValue;
    FREObject exception;
    ANE_assertOKResultException(FREGetObjectProperty(self.FREObject, (uint8_t*)[propertyName UTF8String], &propertyValue, &exception), exception);
    return [ANEObject objectWithFREObject:propertyValue];
}

- (void) setProperty:(NSString*)propertyName value:(ANEObject*)propertyValue {
    FREObject exception;
    ANE_assertOKResultException(FRESetObjectProperty(self.FREObject, (uint8_t*)[propertyName UTF8String], propertyValue.FREObject, &exception), exception);
}

- (ANEObject*) callMethod:(NSString*)methodName methodArgs:(ANEObject*)args, ... {
    ANEObject* result;
    
    va_list argsList;
    va_start(argsList, args);
 
    result = [self callMethod:methodName methodArgs:args vaList:argsList];
    
    va_end(argsList);
    return result;
}

- (ANEObject*) callMethod:(NSString*)methodName methodArgs:(ANEObject*)firstArg vaList:(va_list)vaList {
    NSUInteger count = ANE_countVarargs(firstArg, vaList);

    FREObject exception;
    FREObject result;
    if(count) {
        FREObject freArgs[count];
        ANE_freObjectsFromVarargs(firstArg, vaList, freArgs);
        ANE_assertOKResultException(FRECallObjectMethod(self.FREObject, (uint8_t*)[methodName UTF8String], (uint32_t)count, freArgs, &result, &exception), exception);
    } else {
        ANE_assertOKResultException(FRECallObjectMethod(self.FREObject, (uint8_t*)[methodName UTF8String], 0, NULL, &result, &exception), exception);
    }
    return [ANEObject objectWithFREObject:result];
}

- (ANEObject*) callMethod:(NSString *)methodName methodArgsArray:(NSArray *)argsArray {
    FREObject result;
    FREObject exception;
    if(argsArray.count) {
        FREObject freArgs[argsArray.count];
        for(NSUInteger i = 0; i < argsArray.count; i++) {
            freArgs[i] = ((ANEObject*)argsArray[i]).FREObject;
        }
        ANE_assertOKResultException(FRECallObjectMethod(self.FREObject, (uint8_t*)[methodName UTF8String], (uint32_t)argsArray.count, freArgs, &result, &exception), exception);
    } else {
        ANE_assertOKResultException(FRECallObjectMethod(self.FREObject, (uint8_t*)[methodName UTF8String], 0, NULL, &result, &exception), exception);
    }
    return [ANEObject objectWithFREObject:result];
}

- (ANEObject*) objectForKeyedSubscript:(NSString*)key {
    return [self getProperty:key];
}

- (void) setObject:(ANEObject*)obj forKeyedSubscript:(NSString*)key {
    [self setProperty:key value:obj];
}

- (FREObjectType) type {
    return ANE_getObjectType(self.FREObject);
}

- (BOOL) isNull {
    return self.type == FRE_TYPE_NULL;
}

@end