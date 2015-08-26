//
//  ANEObject_Protected.h
//  ANEWrappers
//
//  Created by thomasrzhao on 8/26/15.
//  Copyright (c) 2015 Thomas Zhao. All rights reserved.
//

@interface ANEObject ()
//This initializer is designed to be used by subclasses only. Clients should use the objectWithFREObject: factory method instead
- (instancetype) initWithFREObject:(FREObject)obj NS_DESIGNATED_INITIALIZER;
@end
