//
//  WXMBaseService.m
//  ModuleDebugging
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 wq. All rights reserved.
//
#import "WXMComponentManager.h"
#import "WXMComponentService.h"
#import "WXMComponentServiceHelp.h"

@interface WXMComponentService ()
@property (nonatomic, copy) ServiceCallBack callback;
@property (nonatomic, copy, readwrite) NSString *privateKey;
@property (nonatomic, strong) void (^removeBlock)(void);
@end
@implementation WXMComponentService

- (void)setServicePrivateKey:(NSString * _Nonnull)privateKey {
    self.privateKey = [privateKey copy];
}

- (void)setServiceCallback:(ServiceCallBack)callback {
    self.callback = [callback copy];
}

- (void)sendNext:(WXMResponse *)response {
    if (self.callback) self.callback(response);
}

- (void)closeCurrentService {
    if (self.privateKey) {
        if (self.removeBlock) self.removeBlock();
    } else [[WXMComponentManager sharedInstance] removeServiceCache:self];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:WXM_REMOVE_CALLBACK] && value) {
        self.removeBlock = (void (^)(void)) value;
    }
}

- (void)dealloc {
#if DEBUG
    NSLog(@"%@ 释放", NSStringFromClass(self.class));
#endif
}
@end
