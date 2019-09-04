//
//  WXMComponentServiceManager.m
//  ModuleDebugging
//
//  Created by edz on 2019/8/28.
//  Copyright © 2019 wq. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMComponentService.h"
#import "WXMComponentManager.h"
#import "WXMComponentConfiguration.h"
#import "WXMComponentServiceManager.h"

@interface WXMComponentServiceManager ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableArray *>*serviceDictionary;
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
- (id)serviceProvide:(Protocol *)protocol depend:(id)depend {
    id service = [[WXMComponentManager sharedInstance] serviceProvideForProtocol:protocol];
    if (![service respondsToSelector:@selector(setServiceCallback:)]) return nil;
    if (![service isKindOfClass:WXMComponentService.class]) return nil;
    [self addService:service dependKey:[self dependKey:depend]];
    [self managerServicerDealloc:depend];
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
- (void)addService:(WXMComponentService *)service dependKey:(NSString *)dependKey {
    if (!service || !dependKey) return;
    if ([self exitService:service dependKey:dependKey]) return;
    @synchronized (self) {
        NSMutableArray *serviceArray = [self.serviceDictionary objectForKey:dependKey];
        serviceArray = serviceArray ? serviceArray.mutableCopy : @[].mutableCopy;
        [serviceArray addObject:service];
        [self.serviceDictionary setObject:serviceArray forKey:dependKey];
        [self addLoneCallBack:service];
    }
}

/** 替换dealloc提前释放掉servicer */
- (void)managerServicerDealloc:(id)depend {
    WXMPreventCrashBegin
    
    __block SEL serviceDeallocSEL = NSSelectorFromString(@"serviceDealloc");
    if ([depend respondsToSelector:serviceDeallocSEL]) return;
    
    id serviceDealloc = ^(__unsafe_unretained id dependInstance) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([dependInstance respondsToSelector:serviceDeallocSEL] && dependInstance) {
            [[WXMComponentServiceManager sharedInstance] freeServiceWithDepend:dependInstance];
            [dependInstance performSelector:serviceDeallocSEL];
        }
#pragma clang diagnostic pop
    };
    
    Class class = [depend class];
    class_addMethod(class, serviceDeallocSEL, imp_implementationWithBlock(serviceDealloc), "v@:@");
    Method deallocMethod = class_getInstanceMethod(class, NSSelectorFromString(@"dealloc"));
    Method serviceMethod = class_getInstanceMethod(class, serviceDeallocSEL);
    method_exchangeImplementations(deallocMethod, serviceMethod);
    
    WXMPreventCrashEnd
}

/** 释放 */
- (void)freeRetainService:(WXMComponentService *)service {
    if (!service) return;
    @synchronized (self) {
        [self.serviceDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray * _Nonnull serviceArray, BOOL * _Nonnull stop) {
            for (WXMComponentService *cacheService in serviceArray.reverseObjectEnumerator) {
                dispatch_queue_t queue = dispatch_get_main_queue();
                int64_t delta = (int64_t)(.15 * NSEC_PER_SEC);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), queue, ^{
                    if (cacheService == service) [serviceArray removeObject:cacheService];
                });
            }
        }];
    }
}

/** 释放当前对象的所有servicer */
- (void)freeServiceWithDepend:(id)depend {
    if (self.serviceDictionary.allKeys.count == 0 || !self.serviceDictionary) return;
    if (!depend) return;
    NSString *dependKey = [self dependKey:depend];
    if ([self.serviceDictionary objectForKey:dependKey]) {
        [self.serviceDictionary removeObjectForKey:dependKey];
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

/** 是否存在当前service */
- (BOOL)exitService:(WXMComponentService *)service dependKey:(NSString *)dependKey {
    @synchronized (self) {
        NSMutableArray *serviceArray = [self.serviceDictionary objectForKey:dependKey];
        if (serviceArray.count == 0 || !serviceArray) return NO;
        if (![serviceArray isKindOfClass:NSArray.class]) return NO;
        for (WXMComponentService *cacheService in serviceArray.reverseObjectEnumerator) {
            if (cacheService == service) return YES;
        }
    }
    return NO;
}

/** 获取依赖的key */
- (NSString *)dependKey:(id)depend {
    NSString *aClass = NSStringFromClass([depend class]);
    NSInteger hash = [depend hash];
    return [NSString stringWithFormat:@"%@_%zd",aClass, hash];
}

- (NSMutableDictionary <NSString *, NSMutableArray *>*)serviceDictionary {
    if (!_serviceDictionary) _serviceDictionary = @{}.mutableCopy;
    return _serviceDictionary;
}
@end

