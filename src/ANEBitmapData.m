//
//  ANEBitmapData.m
//  ANEWrappers
//
//  Created by thomasrzhao on 8/25/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

#import "ANEBitmapData.h"
#import "ANECommon_Private.h"
#import "ANEObject_Protected.h"

@import UIKit;

#define RET_IF_DATA_VALID(retVal, fallback) do { \
    if(_dataValid) { return retVal; } \
    else { NSLog(@"Must call acquireBitmapData before accessing ANEBitmapData properties"); return fallback; } \
} while (0)

@implementation ANEBitmapData {
    FREBitmapData2 _data;
    BOOL _dataValid;
}

- (instancetype) initWithFREObject:(FREObject)obj {
    self = [super initWithFREObject:obj];
    if(self) {
        if(self.freObjectType != FRE_TYPE_BITMAPDATA) {
            return nil;
        }
    }
    return self;
}

+ (instancetype) bitmapDataWithWidth:(uint32_t)width height:(uint32_t)height transparent:(BOOL)transparent fillColor:(uint32_t)fillColor {
    return [self objectWithClassName:@"BitmapData"
                     constructorArgs:[ANEObject objectWithUnsignedInt:width],
                                     [ANEObject objectWithUnsignedInt:height],
                                     [ANEObject objectWithBool:transparent],
                                     [ANEObject objectWithUnsignedInt:fillColor], nil];
}

- (uint32_t)width {
    RET_IF_DATA_VALID(_data.width, 0);
}
- (uint32_t)height {
    RET_IF_DATA_VALID(_data.height, 0);
}
- (BOOL)hasAlpha {
    RET_IF_DATA_VALID(_data.hasAlpha, NO);
}
- (BOOL)isPremultiplied {
    RET_IF_DATA_VALID(_data.isPremultiplied, NO);
}
- (uint32_t)lineStride32 {
    RET_IF_DATA_VALID(_data.lineStride32, 0);
}
- (uint32_t*)bits {
    RET_IF_DATA_VALID(_data.bits32, NULL);
}
- (BOOL)isInvertedY {
    RET_IF_DATA_VALID(_data.isInvertedY, NO);
}
- (void)acquireBitmapData {
    ANE_assertOKResult(FREAcquireBitmapData2(self.freObject, &_data));
    _dataValid = true;
}
- (void)releaseBitmapData {
    ANE_assertOKResult(FREReleaseBitmapData(self.freObject));
    _dataValid = false;
}
- (void)invalidateRectX:(uint32_t)x y:(uint32_t)y width:(uint32_t)width height:(uint32_t)height {
    ANE_assertOKResult(FREInvalidateBitmapDataRect(self.freObject, x, YES, width, height));
}
- (void)dealloc {
    if(_dataValid) {
        [self releaseBitmapData];
    }
}
@end
