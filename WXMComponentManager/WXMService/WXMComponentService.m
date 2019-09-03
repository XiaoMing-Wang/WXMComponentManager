//
//  WXMBaseService.m
//  ModuleDebugging
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 wq. All rights reserved.
//
#import "WXMComponentManager.h"
#import "WXMComponentService.h"
#import "WXMComponentServiceManager.h"

@interface WXMComponentService ()
@property (nonatomic, strong) NSMutableArray<ServiceCallBack> *callbackArray;
@property (nonatomic, strong, readonly) ServiceCallBack callback;
@property (nonatomic, strong, readonly) LoneCallBack loneCallback;
@end
@implementation WXMComponentService

- (void)setServiceCallback:(ServiceCallBack)callback {
    _callback = [callback copy];
    if (self.isSingleton && callback) [self.callbackArray addObject:callback];
}

- (void)sendNext:(id _Nullable)response {
    if (self.isSingleton) {
        for (ServiceCallBack call in self.callbackArray) {
            if (call) call(response);
        }
    } else {
        if (self.callback) self.callback(response);
        if (self.loneCallback) self.loneCallback();
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:WXM_REMOVE_CALLBACK] && value) {
        _loneCallback = (LoneCallBack) value;
    }
}

/** 释放 */
- (void)closeCurrentService {
    [[WXMComponentManager sharedInstance] removeServiceCache:self];
}

/** 是否是单例 */
- (BOOL)isSingleton {
    return [[WXMComponentManager sharedInstance] exsitCacheServiceCache:self];
}

- (NSMutableArray<ServiceCallBack> *)callbackArray {
    if (!_callbackArray) _callbackArray = @[].mutableCopy;
    return _callbackArray;
}

- (void)dealloc {
    if (WXMDEBUG) NSLog(@"%@ 释放", NSStringFromClass(self.class));
}

@end



