//
//  ANEArray.h
//  ANEWrappers
//
//  Created by thomasrzhao on 8/24/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

#import "ANEObject.h"

@interface ANEArrayEnumerator : NSEnumerator
- (ANEObject*) nextObject;
@end

@interface ANEArray : ANEObject <NSFastEnumeration>
+ (instancetype) arrayWithClassName:(NSString*)classname numElements:(uint32_t)numElements fixed:(BOOL)fixed;
+ (instancetype) arrayWithNumElements:(uint32_t)numElements;

@property (nonatomic, assign, readwrite) uint32_t length;

- (ANEObject*)objectAtIndex:(uint32_t)index;
- (void)setObject:(ANEObject*)object atIndex:(uint32_t)index;

- (ANEObject*)objectAtIndexedSubscript:(uint32_t)idx;
- (void)setObject:(ANEObject*)obj atIndexedSubscript:(uint32_t)idx;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len;
- (void)enumerateObjectsUsingBlock:(void (^)(ANEObject* obj, uint32_t idx, BOOL *stop))block;
- (ANEArrayEnumerator*) objectEnumerator;
@end
