//
//  ANEBitmapData.h
//  ANEWrappers
//
//  Created by thomasrzhao on 8/25/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

#import "ANEObject.h"

@interface ANEBitmapData : ANEObject
+ (instancetype) bitmapDataWithWidth:(uint32_t)width height:(uint32_t)height transparent:(BOOL)transparent fillColor:(uint32_t)fillColor;

//Must call acquireBitmapData before accessing these properties
@property (readonly) uint32_t width;
@property (readonly) uint32_t height;
@property (readonly) BOOL hasAlpha;
@property (readonly) BOOL isPremultiplied;
@property (readonly) uint32_t lineStride32;
@property (readonly) uint32_t* bits;
@property (readonly) BOOL isInvertedY;

//Must call acquireBitmapData before calling this method
- (void)invalidateRectX:(uint32_t)x y:(uint32_t)y width:(uint32_t)width height:(uint32_t)height;

- (void)acquireBitmapData;
- (void)releaseBitmapData;

@end
