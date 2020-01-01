//
//  WXMComponentError.m
//  ModuleDebugging
//
//  Created by edz on 2019/9/3.
//  Copyright © 2019 wq. All rights reserved.
//

#import "WXMComponentError.h"

@implementation WXMComponentError

+ (instancetype)error:(NSInteger)code message:(NSString *)message object:(id)object {
    WXMComponentError *error = [[WXMComponentError alloc] init];
    error.errorCode = code;
    error.errorMessage = message;
    error.object = object;
    error.success = (code == 0);
    return error;
}

@end
