//
//  ANEContext.h
//  ANEWrappers
//
//  Created by thomasrzhao on 8/25/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import "ANECommon.h"

@class ANEObject;

@interface ANEContext : NSObject
@property (readonly) FREContext FREContext;

@property (nonatomic, strong, readwrite) ANEObject* actionScriptData;
@property (nonatomic, assign, readwrite) void* nativeData;

- (instancetype) init __attribute__((unavailable("use initWithFREContext: instead")));

- (instancetype) initWithFREContext:(FREContext)ctx NS_DESIGNATED_INITIALIZER;
+ (instancetype) contextWithFREContext:(FREContext)ctx;

- (void) dispatchStatusEventAsyncWithCode:(NSString*)code level:(NSString*)level;
@end
