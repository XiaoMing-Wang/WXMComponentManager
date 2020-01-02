//
//  WXMComponentServiceManager.m
//  ModuleDebugging
//
//  Created by edz on 2019/8/28.
//  Copyright © 2019 wq. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMComponentBaseService.h"
#import "WXMComponentManager.h"
#import "WXMComponentConfiguration.h"
#import "WXMComponentServiceHelp.h"
@interface WXMComponentServiceHelp ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *serviceDictionary;
@end

@implementation WXMComponentServiceHelp

+ (instancetype)sharedInstance {
    static WXMComponentServiceHelp *serviceManager;
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
    if (![service isKindOfClass:WXMComponentBaseService.class]) return nil;
    [self addService:service dependKey:[self dependKey:depend]];
    [self addFreeServiceCallBack:service];
    
    WXMPreventCrashBegin
    [self managerServicerDealloc:depend];
    WXMPreventCrashEnd
    
    return service;
}

/** 创建单例service */
- (id)serviceCacheProvide:(Protocol *)protocol {
    id service = [[WXMComponentManager sharedInstance] serviceCacheProvideForProtocol:protocol];
    if (![service respondsToSelector:@selector(setServiceCallback:)]) return nil;
    if (![service isKindOfClass:WXMComponentBaseService.class]) return nil;
    return service;
}

/** 强引用 */
- (void)addService:(WXMComponentBaseService *)service dependKey:(NSString *)dependKey {
    if (!service || !dependKey) return;
    if ([self exitService:service dependKey:dependKey]) return;
    @synchronized (self) {
        NSMutableArray *serviceArray = [self.serviceDictionary objectForKey:dependKey];
        serviceArray = serviceArray ? serviceArray.mutableCopy : @[].mutableCopy;
        [serviceArray addObject:service];
        [self.serviceDictionary setValue:serviceArray forKey:dependKey];
    }
}

/** 替换dealloc提前释放掉servicer */
- (void)managerServicerDealloc:(id)depend {
    WXMPreventCrashBegin
    
    SEL serviceDeallocSEL = NSSelectorFromString(@"serviceDealloc");
    if ([depend respondsToSelector:serviceDeallocSEL]) return;
    
    id serviceDealloc = ^(__unsafe_unretained id dependInstance) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
        __unsafe_unretained id self_instance = dependInstance;
        if ([self_instance respondsToSelector:serviceDeallocSEL] && self_instance) {
            WXMPreventCrashBegin
            [[WXMComponentServiceHelp sharedInstance] freeServiceWithDepend:self_instance];
            if (self_instance) [self_instance performSelector:serviceDeallocSEL];
            WXMPreventCrashEnd
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

/** 添加block */
- (void)addFreeServiceCallBack:(WXMComponentBaseService *)service {
    FreeServiceCallBack serviceCallBack = ^(WXMComponentBaseService *service) {
        [[WXMComponentServiceHelp sharedInstance] freeRetainService:service];
    };
    [service setValue:serviceCallBack forKey:WXM_REMOVE_CALLBACK];
}

/** 释放 */
- (void)freeRetainService:(WXMComponentBaseService *)service {
    if (!service) return;
    @synchronized (self) {
        [self.serviceDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray * _Nonnull serviceArray, BOOL * _Nonnull stop) {
            for (WXMComponentBaseService *cacheService in serviceArray.reverseObjectEnumerator) {
                if (cacheService == service) [serviceArray removeObject:cacheService];
            }
        }];
    }
}

/** 释放当前对象的所有servicer */
- (void)freeServiceWithDepend:(id)depend {
    if (self.serviceDictionary.allKeys.count == 0 || !self.serviceDictionary) return;
    NSString *dependKey = [self dependKey:depend];
    if (!depend || !dependKey) return;
    [self.serviceDictionary setValue:nil forKey:dependKey];
    
}

/** 是否存在当前service */
- (BOOL)exitService:(WXMComponentBaseService *)service dependKey:(NSString *)dependKey {
    @synchronized (self) {
        NSMutableArray *serviceArray = [self.serviceDictionary objectForKey:dependKey];
        if (serviceArray.count == 0 || !serviceArray) return NO;
        if (![serviceArray isKindOfClass:NSArray.class]) return NO;
        for (WXMComponentBaseService *cacheService in serviceArray.reverseObjectEnumerator) {
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

