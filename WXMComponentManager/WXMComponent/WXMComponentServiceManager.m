//
//  WXMComponentServiceManager.m
//  ModuleDebugging
//
//  Created by edz on 2019/8/28.
//  Copyright © 2019 wq. All rights reserved.
//
#import "WXMComponentService.h"
#import "WXMComponentManager.h"
#import "WXMComponentConfiguration.h"
#import "WXMComponentServiceManager.h"

@interface WXMComponentServiceManager ()
@property (nonatomic, strong) NSMutableArray *serviceArray;
@end

@implementation WXMComponentServiceManager

+ (instancetype)sharedInstance {
    static WXMComponentServiceManager *serviceManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceManager = [[self alloc] init];
    });
    return serviceManager;
}

/** 创建service */
- (id)serviceProvide:(Protocol *)protocol {
    id service = [[WXMComponentManager sharedInstance] serviceProvideForProtocol:protocol];
    if (![service respondsToSelector:@selector(setServiceCallback:)]) return nil;
    if (![service isKindOfClass:WXMComponentService.class]) return nil;
    [self addRetainService:service];
    return service;
}

/** 创建单例service */
- (id)serviceCacheProvide:(Protocol *)protocol {
    id service = [[WXMComponentManager sharedInstance] serviceCacheProvideForProtocol:protocol];
    if (![service respondsToSelector:@selector(setServiceCallback:)]) return nil;
    if (![service isKindOfClass:WXMComponentService.class]) return nil;
    return service;
}

/** 强引用 */
- (void)addRetainService:(WXMComponentService *)service {
    if (!service) return;
    if ([self exitService:service]) return;
    @synchronized (self) {
        [self.serviceArray addObject:service];
        [self addLoneCallBack:service];
    }
}

/** 释放 */
- (void)freeRetainService:(WXMComponentService *)service {
    if (!service) return;
    @synchronized (self) {
        for (WXMComponentService *cacheService in self.serviceArray.reverseObjectEnumerator) {
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC));
            dispatch_after(time_t, queue, ^{
                if (cacheService == service) [self.serviceArray removeObject:cacheService];
            });
        }
    }
}

/** 添加block */
- (void)addLoneCallBack:(WXMComponentService *)service {
    [service setValue:[self loneCallBack:service] forKey:WXM_REMOVE_CALLBACK];
}

/** 获取销毁的block */
- (LoneCallBack)loneCallBack:(WXMComponentService *)service  {
    __weak typeof(service) weakService = service;
    return ^{
        __strong __typeof(weakService) strongService = weakService;
        [[WXMComponentServiceManager sharedInstance] freeRetainService:strongService];
    };
}

- (BOOL)exitService:(WXMComponentService *)service {
    @synchronized (self) {
        for (WXMComponentService *cacheService in self.serviceArray.reverseObjectEnumerator) {
            if (cacheService == service) return YES;
        }
    }
    return NO;
}

- (NSMutableArray *)serviceArray {
    if (!_serviceArray) _serviceArray = @[].mutableCopy;
    return _serviceArray;
}
@end
