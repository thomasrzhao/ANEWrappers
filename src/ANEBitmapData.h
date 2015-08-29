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
@property (readonly, getter=isPremultiplied) BOOL premultiplied;
@property (readonly) uint32_t lineStride32;
@property (readonly) uint32_t* bits;
@property (readonly, getter=isInvertedY) BOOL invertedY;

//Must call acquireBitmapData before calling this method
- (void) invalidateRectX:(uint32_t)x y:(uint32_t)y width:(uint32_t)width height:(uint32_t)height;

- (void) acquireBitmapData;
- (void) releaseBitmapData;

//Can use this method as an alternative to manually calling acquire and release. Do not call acquire or release within the block
- (void) performBitmapDataOperation:(void (^)(ANEBitmapData* bitmapData))operation;

@end
