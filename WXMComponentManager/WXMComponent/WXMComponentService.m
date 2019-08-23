//
//  WXMBaseService.m
//  ModuleDebugging
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 wq. All rights reserved.
//
#import "WXMComponentManager.h"
#import "WXMComponentService.h"

@interface WXMComponentService ()
@property (nonatomic, copy) ServiceCallBack callback;
@end
@implementation WXMResponse @end
@implementation WXMComponentService

- (void)setServiceCallback:(ServiceCallBack)callback {
    self.callback = [callback copy];
}

- (void)sendNext:(WXMResponse *)response {
    if (self.callback) self.callback(response);
}

- (void)closeCurrentService {
    [[WXMComponentManager sharedInstance] removeServiceCache:self];
}
@end
