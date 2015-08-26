//
//  ANECommon_Private.m
//  ANEWrappers
//
//  Created by thomasrzhao on 8/25/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

@import Foundation;

#import "ANECommon.h"
#import "ANECommon_Private.h"
#import "ANEObject.h"

void ANE_assertOKResultException(FREResult result, FREObject exceptionObj) {
    if(result != FRE_OK) {
        NSString* name;
        switch (result) {
            case FRE_NO_SUCH_NAME:
                name = @"No such name";
                break;
            case FRE_INVALID_OBJECT:
                name = @"Invalid object";
                break;
            case FRE_TYPE_MISMATCH:
                name = @"Type mismatch";
                break;
            case FRE_ACTIONSCRIPT_ERROR:
                name = @"ActionScript error";
                break;
            case FRE_INVALID_ARGUMENT:
                name = @"Invalid argument";
                break;
            case FRE_READ_ONLY:
                name = @"Read only";
                break;
            case FRE_WRONG_THREAD:
                name = @"Wrong thread";
                break;
            case FRE_ILLEGAL_STATE:
                name = @"Illegal state";
                break;
            case FRE_INSUFFICIENT_MEMORY:
                name = @"Insufficient Memory";
                break;
            default:
                name = @"Unknown";
                break;
        }
        
        NSDictionary* userInfo = nil;
        if(exceptionObj && result == FRE_ACTIONSCRIPT_ERROR) {
            userInfo = @{ANEExceptionErrorObjectKey: [ANEObject objectWithFREObject:exceptionObj]};
        }
        [NSException exceptionWithName:ANEExceptionName reason:[NSString stringWithFormat:@"FREResult returned error code %d (%@)", result, name] userInfo:userInfo];
    }
}

void ANE_assertOKResult(FREResult result) {
    ANE_assertOKResultException(result, NULL);
}
