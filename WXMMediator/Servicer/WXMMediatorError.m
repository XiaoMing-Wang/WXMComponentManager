//
//  WXMMediatorError.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/25.
//  Copyright © 2019 wxm. All rights reserved.
//

#import "WXMMediatorError.h"

@implementation WXMMediatorError

+ (instancetype)error:(NSInteger)code message:(NSString *)message object:(id)object {
    WXMMediatorError *error = [[WXMMediatorError alloc] init];
    error.code = code;
    error.message = message;
    error.object = object;
    error.success = (code == 0);
    return error;
}

@end
