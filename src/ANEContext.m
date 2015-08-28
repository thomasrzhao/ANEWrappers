//
//  ANEContext.m
//  ANEWrappers
//
//  Created by thomasrzhao on 8/25/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

#import "ANEContext.h"
#import "ANECommon_Private.h"
#import "ANEObject.h"

@implementation ANEContext
- (instancetype) init {
    NSAssert(NO, @"init is not allowed, use initWithFREContext: instead");
    return nil;
}

- (instancetype) initWithFREContext:(FREContext)ctx {
    self = [super init];
    if(self) {
        if(!ctx) { return nil; }

        _FREContext = ctx;
    }
    return self;
}

+ (instancetype) contextWithFREContext:(FREContext)ctx {
    return [[self alloc] initWithFREContext:ctx];
}

- (ANEObject*) actionScriptData {
    FREObject obj;
    ANE_assertOKResult(FREGetContextActionScriptData(self.FREContext, &obj));
    return [ANEObject objectWithFREObject:obj];
}

- (void) setActionScriptData:(ANEObject*)actionScriptData {
    ANE_assertOKResult(FRESetContextActionScriptData(self.FREContext, actionScriptData.FREObject));
}

- (void*) nativeData {
    void* nativeData;
    FREGetContextNativeData(self.FREContext, &nativeData);
    return nativeData;
}

- (void) setNativeData:(void *)nativeData {
    ANE_assertOKResult(FRESetContextNativeData(self.FREContext, nativeData));
}

- (void) dispatchStatusEventAsyncWithCode:(NSString*)code level:(NSString*)level {
    ANE_assertOKResult(FREDispatchStatusEventAsync(self.FREContext, (uint8_t*)[code UTF8String], (uint8_t*)[level UTF8String]));
}
@end
