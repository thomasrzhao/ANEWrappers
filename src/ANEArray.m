//
//  ANEArray.m
//  ANEWrappers
//
//  Created by thomasrzhao on 8/24/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

#import "ANEArray.h"
#import "ANECommon_Private.h"
#import "ANEObject_Protected.h"

@implementation ANEArrayEnumerator {
    ANEArray* _array;
    uint32_t _curIndex;
    uint32_t _length;
}

- (instancetype) initWithArray:(ANEArray*)array {
    self = [super init];
    if (self) {
        _array = array;
        _curIndex = 0;
        _length = array.length;
    }
    return self;
}

- (ANEObject*) nextObject {
    if(_curIndex > _length) {
        return nil;
    }
    ANEObject* object = _array[_curIndex];
    _curIndex++;
    return object;
}

@end
@implementation ANEArray {
    unsigned long mutationCounter;
}

- (instancetype) initWithFREObject:(FREObject)obj {
    self = [super initWithFREObject:obj];
    if(self) {
        if(self.freObjectType != FRE_TYPE_ARRAY && self.freObjectType != FRE_TYPE_VECTOR) {
            return nil;
        }
    }
    return self;
}

+ (instancetype) arrayWithClassName:(NSString*)className numElements:(uint32_t)numElements fixed:(BOOL)fixed {
    return [self objectWithClassName:[NSString stringWithFormat:@"Vector.<%@>", className] constructorArgs:[ANEObject objectWithUnsignedInt:numElements], [ANEObject objectWithBool:fixed], nil];
}

+ (instancetype) arrayWithNumElements:(uint32_t)numElements {
    return [self objectWithClassName:@"Array" constructorArgs:[ANEObject objectWithUnsignedInt:numElements], nil];
}

- (uint32_t) length {
    uint32_t len;
    ANE_assertOKResult(FREGetArrayLength(self.freObject, &len));
    return len;
}

- (void) setLength:(uint32_t)length {
    ANE_assertOKResult(FRESetArrayLength(self.freObject, length));
    mutationCounter++;
}

- (ANEObject*) objectAtIndex:(uint32_t)index {
    FREObject obj;
    ANE_assertOKResult(FREGetArrayElementAt(self.freObject, index, &obj));
    return [ANEObject objectWithFREObject:obj];
}

- (void) setObject:(ANEObject*)object atIndex:(uint32_t)index {
    ANE_assertOKResult(FRESetArrayElementAt(self.freObject, index, object.freObject));
    mutationCounter++;
}

- (ANEObject*) objectAtIndexedSubscript:(uint32_t)idx {
    return [self objectAtIndex:(uint32_t)idx];
}

- (void) setObject:(ANEObject*)obj atIndexedSubscript:(uint32_t)idx {
    return [self setObject:obj atIndex:(uint32_t)idx];
}

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count {
    if(!state->state) {
        state->mutationsPtr = &mutationCounter;
    }
    
    state->itemsPtr = buffer;

    uint32_t length = self.length;
    NSUInteger objCount = 0;
    
    for(NSUInteger i = state->state; i < length && objCount < count; i++, objCount++) {
        buffer[objCount] = [self objectAtIndex:(uint32_t)i];
    }
    
    state->state += objCount;
    
    return objCount;
}

- (void) enumerateObjectsUsingBlock:(void (^)(ANEObject* obj, uint32_t idx, BOOL *stop))block {
    BOOL stop = NO;
    
    uint32_t length = self.length;
    
    for (uint32_t i = 0; i < length; i++) {
        block([self objectAtIndex:i], i, &stop);
        
        if (stop) break;
    }
}

- (ANEArrayEnumerator*) objectEnumerator {
    return [[ANEArrayEnumerator alloc] initWithArray:self];
}
@end
