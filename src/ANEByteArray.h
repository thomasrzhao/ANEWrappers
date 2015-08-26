//
//  ANEByteArray.h
//  ANEWrappers
//
//  Created by thomasrzhao on 8/24/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

#import "ANEObject.h"

@interface ANEByteArray : ANEObject
+ (instancetype) byteArray;
+ (instancetype) byteArrayWithData:(NSData*)data;

//Must call acquireByteArray before accessing these properties
@property (readonly) uint32_t length;
@property (readonly) uint8_t* bytes;
@property (readonly) NSData* data;

- (void) acquireByteArray;
- (void) releaseByteArray;

@end
