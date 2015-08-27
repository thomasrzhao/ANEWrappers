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
                name = @"No such name: The name of a class, property, or method passed as a parameter does not match an ActionScript class name, property, or method.";
                break;
            case FRE_INVALID_OBJECT:
                name = @"Invalid object: An ANEObject parameter is invalid. Any ANEObject variable is valid only until the first FREFunction function on the call stack returns.";
                break;
            case FRE_TYPE_MISMATCH:
                name = @"Type mismatch: An ANEObject parameter does not represent an object of the ActionScript class expected by the called function.";
                break;
            case FRE_ACTIONSCRIPT_ERROR:
                name = @"ActionScript error: An ActionScript error occurred, and an Error object was thrown. The error ANEObject can be retrieved from the NSException object's userInfo dictionary with key ANEExceptionErrorObjectKey.";
                break;
            case FRE_INVALID_ARGUMENT:
                name = @"Invalid argument: A pointer parameter is NULL.";
                break;
            case FRE_READ_ONLY:
                name = @"Read only: An attempt was made to modify a read-only property of an ActionScript object.";
                break;
            case FRE_WRONG_THREAD:
                name = @"Wrong thread: A method was called from a thread other than the one on which the runtime has an outstanding call to a native extension function.";
                break;
            case FRE_ILLEGAL_STATE:
                name = @"Illegal state: A call was made to a native extension C API function when the extension context was in an illegal state for that call. You may not call any ANEObject methods aside from the one specifcally marked in ANEByteArray and ANEBitmapData while an ANEByteArray or ANEBitmapData's lock is acquired.";
                break;
            case FRE_INSUFFICIENT_MEMORY:
                name = @"Insufficient memory: The runtime could not allocate enough memory to change the size of an Array or Vector object.";
                break;
            default:
                name = @"Unknown: An unknown error occurred.";
                break;
        }
        
        NSDictionary* userInfo = nil;
        if(exceptionObj && result == FRE_ACTIONSCRIPT_ERROR) {
            userInfo = @{ANEExceptionErrorObjectKey: [ANEObject objectWithFREObject:exceptionObj]};
        }
        [[NSException exceptionWithName:ANEException reason:[NSString stringWithFormat:@"%@ (FREResult code %d)", name, result] userInfo:userInfo] raise];
    }
}

void ANE_assertOKResult(FREResult result) {
    ANE_assertOKResultException(result, NULL);
}
