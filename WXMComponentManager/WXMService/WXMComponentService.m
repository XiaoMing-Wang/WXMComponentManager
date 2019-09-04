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
@property (nonatomic, strong) WXMComponentError *responseCache;
@property (nonatomic, strong) NSMutableArray<ServiceCallBack> *callbackArray;
@property (nonatomic, strong, readonly) ServiceCallBack callback;
@property (nonatomic, strong, readonly) LoneCallBack loneCallback;
@end
@implementation WXMComponentService

- (WXMComponentError *_Nullable)cacheDataSource {
    return nil;
}

- (void)setServiceCallback:(ServiceCallBack)callback {
    if (self.isSingleton) {  /* 单例 */
        if (callback) [self.callbackArray addObject:callback];
        return;
    }
    
    _callback = [callback copy];
    if (callback == nil) return;
    if (self.responseCache) {
        
        /** 先调用后setServiceCallback 回调后释放service */
        callback(self.responseCache);
        [self releaseServiceSelf];
        
    } else if (self.cacheDataSource) {
        
        /** 加载缓存不释放service */
        callback(self.cacheDataSource);
        
    }
}

- (void)sendNext:(id _Nullable)response {
    if (self.isSingleton) {   /* 单例 */
        [self serviceArrayCallBack:response]; return;
    }
    
    if (self.callback) {
        self.callback(response);
        [self releaseServiceSelf];
    } else {
        self.responseCache = response;
    }
}

/** 释放service */
- (void)releaseServiceSelf {
    if (self.loneCallback) self.loneCallback();
}

/** 数组 */
- (void)serviceArrayCallBack:(id)response {
    for (ServiceCallBack call in self.callbackArray) {
        if (call) call(response);
    }
}

/** 释放的block赋值 */
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



