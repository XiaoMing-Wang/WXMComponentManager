//
//  WXMMediatorServiceManager.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/25.
//  Copyright © 2019 wxm. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMMediatorBaseService.h"
#import "WXMMediatorConfiguration.h"
#import "WXMMediatorServiceManager.h"
@implementation WXMMediatorError
+ (instancetype)error:(NSInteger)code message:(NSString *)message object:(id)object {
    WXMMediatorError *error = [[WXMMediatorError alloc] init];
    error.code = code;
    error.message = message;
    error.object = object;
    error.success = (code == 0);
    return error;
}
@end

@interface WXMMediatorServiceManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray *> *serviceDictionary;
@end

@implementation WXMMediatorServiceManager

+ (instancetype)sharedInstance {
    static WXMMediatorServiceManager *serviceManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceManager = [[self alloc] init];
    });
    return serviceManager;
}

/** 创建service(回调或者depend被释放时service销毁) */
- (WXMMediatorBaseService *)serviceForClass:(Class)aClass dependObject:(id)dependObject {
    __kindof WXMMediatorBaseService *service = [[aClass alloc] init];
    if (![service respondsToSelector:@selector(setServiceCallback:)]) return nil;
    if (![service isKindOfClass:WXMMediatorBaseService.class]) return nil;
    [self addService:service dependKey:[self dependObjectKey:dependObject]];
    [self addFreeServiceCallBack:service];
    [self managerServicerDealloc:dependObject];
    return service;
}

/** 强引用 */
/** 用object的哈希值和类名保证key唯一性 保存该类所有的servicer数组 */
- (void)addService:(WXMMediatorBaseService *)service dependKey:(NSString *)dependKey {
    if (!service || !dependKey) return;
    if ([self exitService:service dependKey:dependKey]) return;
    @synchronized (self) {
        NSArray *array = [self.serviceDictionary objectForKey:dependKey];
        NSMutableArray *serviceArray = array ? array.mutableCopy : @[].mutableCopy;
        [serviceArray addObject:service];
        [self.serviceDictionary setObject:serviceArray.copy forKey:dependKey];
    }
}

/** 是否存在当前service */
- (BOOL)exitService:(WXMMediatorBaseService *)service dependKey:(NSString *)dependKey {
    @synchronized (self) {
        NSArray *serviceArray = [self.serviceDictionary objectForKey:dependKey];
        if (serviceArray.count == 0 || !serviceArray) return NO;
        if (![serviceArray isKindOfClass:NSArray.class]) return NO;
        for (WXMMediatorBaseService *cacheService in serviceArray.reverseObjectEnumerator) {
            if (cacheService == service) return YES;
        }
    }
    return NO;
}

/** 添加block */
- (void)addFreeServiceCallBack:(WXMMediatorBaseService *)service {
    WXMFreeServiceCallBack serviceCallBack = ^(WXMMediatorBaseService *service) {
        [[WXMMediatorServiceManager sharedInstance] freeRetainService:service];
    };
    [service setValue:serviceCallBack forKey:WXMMEDIATOR_REMOVE_CALLBACK];
}

/** 释放 */
- (void)freeRetainService:(WXMMediatorBaseService *)service {
    if (!service) return;
    @synchronized (self) {
        [self.serviceDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray * _Nonnull array, BOOL * _Nonnull stop) {
            for (WXMMediatorBaseService *cacheService in array.reverseObjectEnumerator) {
                if (cacheService == service) {
                    NSMutableArray *mutableArray = array.mutableCopy;
                    [mutableArray removeObject:service];
                    [self.serviceDictionary setObject:mutableArray forKey:key];
                    *stop = YES;
                }
            }
        }];
    }
}

/** 释放当前对象的所有servicer */
- (void)freeServiceWithDepend:(id)depend {
    if (self.serviceDictionary.allKeys.count == 0 || !self.serviceDictionary) return;
    NSString *dependKey = [self dependObjectKey:depend];
    if (!depend || !dependKey) return;
    if ([self.serviceDictionary objectForKey:dependKey]) {
        [self.serviceDictionary removeObjectForKey:dependKey];
    }
}

/** 替换dealloc提前释放掉servicer */
- (void)managerServicerDealloc:(id)depend {
    WXMMediatorCrashBegin
    
    __block SEL serDeallocSEL = NSSelectorFromString(@"serviceDealloc");
    if (!depend) return;
    if ([depend respondsToSelector:serDeallocSEL]) return;
    
    id serviceDealloc = ^(__unsafe_unretained id dependInstance) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if (!dependInstance) return;
        if ([dependInstance respondsToSelector:serDeallocSEL] && dependInstance) {
            WXMMediatorCrashBegin
            [[WXMMediatorServiceManager sharedInstance] freeServiceWithDepend:dependInstance];
            [dependInstance performSelector:serDeallocSEL];
            WXMMediatorCrashEnd
        }
#pragma clang diagnostic pop
    };
    
    Class class = [depend class];
    class_addMethod(class, serDeallocSEL, imp_implementationWithBlock(serviceDealloc), "v@:@");
    Method deallocMethod = class_getInstanceMethod(class, NSSelectorFromString(@"dealloc"));
    Method serviceMethod = class_getInstanceMethod(class, serDeallocSEL);
    method_exchangeImplementations(deallocMethod, serviceMethod);
    WXMMediatorCrashEnd
}

/** 获取依赖的key */
- (NSString *)dependObjectKey:(id)dependObject {
    NSString *aClass = NSStringFromClass([dependObject class]);
    NSInteger hash = [dependObject hash];
    return [NSString stringWithFormat:@"%@_%zd", aClass, hash];
}

- (NSMutableDictionary<NSString *, NSArray *> *)serviceDictionary {
    if (!_serviceDictionary) _serviceDictionary = @{}.mutableCopy;
    return _serviceDictionary;
}
@end
