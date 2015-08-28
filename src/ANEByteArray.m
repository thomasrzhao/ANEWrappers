//
//  ANEByteArray.m
//  ANEWrappers
//
//  Created by thomasrzhao on 8/24/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

#import "ANEByteArray.h"
#import "ANECommon_Private.h"
#import "ANEObject_Protected.h"

#define RET_IF_DATA_VALID(retVal, fallback) do { \
if(_dataValid) { return retVal; } \
else { NSLog(@"Must call acquireByteArray before accessing ANEByteArray properties"); return fallback; } \
} while (0)

@implementation ANEByteArray {
    FREByteArray _byteArray;
    BOOL _dataValid;
}

- (instancetype) initWithFREObject:(FREObject)obj {
    self = [super initWithFREObject:obj];
    if(self) {
        if(self.type != FRE_TYPE_BYTEARRAY) {
            return nil;
        }
    }
    return self;
}

+ (instancetype) byteArray {
    return [self byteArrayWithData:nil];
}

+ (instancetype) byteArrayWithData:(NSData*)data {
    ANEByteArray* byteArray = [self objectWithClassName:@"flash.utils.ByteArray" constructorArgs: nil];
    
    if(byteArray && data) {        
        byteArray[@"length"] = [ANEObject objectWithUnsignedInt:(uint32_t)data.length];
        [byteArray acquireByteArray];
        if(byteArray.bytes) {
            memcpy(byteArray.bytes, data.bytes, data.length);
        }
        [byteArray releaseByteArray];
    }
    
    return byteArray;
}

- (uint32_t) length {
    RET_IF_DATA_VALID(_byteArray.length, 0);
}

- (uint8_t*) bytes {
    RET_IF_DATA_VALID(_byteArray.bytes, 0);
}

- (void) acquireByteArray {
    ANE_assertOKResult(FREAcquireByteArray(self.FREObject, &_byteArray));
    _dataValid = true;
}

- (void) releaseByteArray {
    ANE_assertOKResult(FREReleaseByteArray(self.FREObject));
    _dataValid = false;
}

- (NSData*) data {
    return [NSData dataWithBytesNoCopy:_byteArray.bytes length:_byteArray.length freeWhenDone:NO];
}

- (void) dealloc {
    if(_dataValid) {
        [self releaseByteArray];
    }
}
@end
