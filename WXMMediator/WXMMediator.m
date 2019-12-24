//
//  WXMMediator.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//

#import "WXMMediator.h"

@implementation WXMMediator

/** 单例 */
+ (instancetype)sharedInstance {
    static WXMMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[self alloc] init];
    });
    return mediator;
}

@end
