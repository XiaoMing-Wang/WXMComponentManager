//
//  WXMBaseService.m
//  ModuleDebugging
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 wq. All rights reserved.
//
#import "WXMComponentManager.h"
#import "WXMComponentBaseService.h"
#import "WXMComponentServiceHelp.h"

@interface WXMComponentBaseService ()
@property (nonatomic, strong) WXMComponentError *responseCache;
@property (nonatomic, strong, readonly) ServiceCallBack serviceCallBack;
@property (nonatomic, strong, readonly) FreeServiceCallBack freeServiceCallBack;
@end

@implementation WXMComponentBaseService

- (void)setServiceCallback:(ServiceCallBack)callback {
    
    _serviceCallBack = [callback copy];
    if (callback == nil) return;
    
    if (self.responseCache) {
        
        /** 先调用后setServiceCallback 回调后释放service */
        _serviceCallBack(self.responseCache);
        [self releaseServiceSelf];
        return;
    }
    
    WXMComponentError *cacheMediatorError = nil;
    if ([self respondsToSelector:@selector(cacheComponentError)] && self.accessCache) {
        cacheMediatorError = self.cacheComponentError;
        if (cacheMediatorError) _serviceCallBack(cacheMediatorError);
    }
}

- (void)sendNext:(id _Nullable)response {
    if (self.serviceCallBack) {
        self.serviceCallBack(response);
        [self releaseServiceSelf];
    }
    else if (response) self.responseCache = response;
    else [self releaseServiceSelf];
}

/** 释放service */
- (void)releaseServiceSelf {
    dispatch_queue_t queue = dispatch_get_main_queue();
    int64_t delta = (int64_t)(.12f * NSEC_PER_SEC);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), queue, ^{
        if (self.freeServiceCallBack && self) self.freeServiceCallBack(self);
    });
}

/** 释放的block赋值 */
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:WXM_REMOVE_CALLBACK] && value) {
        _freeServiceCallBack = (FreeServiceCallBack) value;
    }
}

/** 返回缓存 */
- (WXMComponentError *_Nullable)cacheComponentError {
    return nil;
}

- (void)dealloc {
    if (WXMDEBUG) NSLog(@"%@ 释放", NSStringFromClass(self.class));
}

@end



