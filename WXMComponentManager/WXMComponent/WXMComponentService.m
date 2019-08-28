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
@property (nonatomic, strong) ServiceCallBack callback;
@property (nonatomic, strong) LoneCallBack loneCallback;
@end
#pragma mark ____________________________________ WXMComponentError

@implementation WXMComponentError
+ (instancetype)error:(NSInteger)code message:(NSString *)message object:(id)object {
    WXMComponentError *error = [[WXMComponentError alloc] init];
    error.code = code;
    error.message = message;
    error.object = object;
    error.success = (code == 0);
    return error;
}
@end

#pragma mark ____________________________________ WXMComponentService

@implementation WXMComponentService

- (void)setServiceCallback:(ServiceCallBack)callback {
    self.callback = [callback copy];
    if (self.isSingleton) [self.callbackArray addObject:callback];
}

- (void)sendNext:(id _Nullable)response {
    if (self.isSingleton) {
        for (ServiceCallBack call in self.callbackArray) { if (call) call(response); }
    } else {
        if (self.callback) self.callback(response);
        if (self.loneCallback) self.loneCallback();
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:WXM_REMOVE_CALLBACK] && value) {
        self.loneCallback = (LoneCallBack) value;
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



