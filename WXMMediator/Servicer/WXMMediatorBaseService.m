//
//  WXMMediatorService.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/25.
//  Copyright © 2019 wxm. All rights reserved.
//
#import "WXMMediatorBaseService.h"

@interface WXMMediatorBaseService ()
@property (nonatomic, strong) WXMMediatorError *responseCache;
@property (nonatomic, strong, readonly) WXMServiceCallBack serviceCallBack;
@property (nonatomic, strong, readonly) WXMFreeServiceCallBack freeServiceCallBack;
@end

@implementation WXMMediatorBaseService

- (void)setServiceCallback:(WXMServiceCallBack)callback {
    
    _serviceCallBack = [callback copy];
    if (_serviceCallBack == nil) return;
  
    if (self.responseCache) {

        /** 先调用后setServiceCallback 回调后释放service */
        _serviceCallBack(self.responseCache);
        [self releaseServiceSelf];
        return;
    }
    
    WXMMediatorError *cacheMediatorError = nil;
    if ([self respondsToSelector:@selector(cacheMediatorError)] && self.accessCache) {
        cacheMediatorError = self.cacheMediatorError;
        if (cacheMediatorError) _serviceCallBack(cacheMediatorError);
    }
}

/** 回调数据 */
- (void)sendNext:(WXMMediatorError *_Nullable)response {
    self.responseCache = response;
    if (self.serviceCallBack) {
        self.serviceCallBack(response);
        [self releaseServiceSelf];
    }
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
    if ([key isEqualToString:WXMMEDIATOR_REMOVE_CALLBACK] && value) {
        _freeServiceCallBack = (WXMFreeServiceCallBack) value;
    }
}

/** 返回缓存 */
- (WXMMediatorError *_Nullable)cacheMediatorError {
    return nil;
}

@end
