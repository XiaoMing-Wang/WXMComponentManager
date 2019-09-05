//
//  WQComponentManager.m
//  ModulesProject
//
//  Created by wq on 2019/4/19.
//  Copyright © 2019年 wq. All rights reserved.
//
#include <dlfcn.h>
#include <mach-o/dyld.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <objc/runtime.h>
#include <mach-o/loader.h>
#include <mach-o/ldsyms.h>
#include <mach-o/getsect.h>
#import "WXMComponentHeader.h"
#import "WXMComponentManager.h"

@interface WXMComponentManager ()

/** 协议和实例 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *registeredDic;

/** 缓存实例对象 引用计数 + 1 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *cacheTarget;

@end

@implementation WXMComponentManager
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"

+ (instancetype)sharedInstance {
    static WXMComponentManager *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[self alloc] init];
    });
    return mediator;
}

/* 注册service 和 protocol */
- (void)addService:(NSString *)service protocol:(NSString *)protocol {
    if (!self.registeredDic) self.registeredDic = @{}.mutableCopy;
    if (!self.cacheTarget) self.cacheTarget = @{}.mutableCopy;
    if (service && protocol) [self.registeredDic setObject:service forKey:protocol];
    NSLog(@"%@ ----- %@", service, protocol);
}

/* 获取service对象(服务调用者) */
- (id)serviceProvideForProtocol:(Protocol *)protocol {
    NSString *protosString = NSStringFromProtocol(protocol);
    NSString *targetString = [self.registeredDic objectForKey:protosString];
    id<WXMComponentFeedBack> target = [NSClassFromString(targetString) new];
    
    if ([target conformsToProtocol:protocol] && target) {
        
        /** NSObject做中间类会被释放 接收消息需要强引用不被释放 */
        BOOL needCache = NO;
        SEL cacheImp = @selector(wc_cacheImplementer);
        if ([target respondsToSelector:cacheImp]) needCache = [target wc_cacheImplementer];
        if (needCache && [target isKindOfClass:[NSObject class]] && target && targetString) {
            [self.cacheTarget setObject:target forKey:targetString];
        }
    }
    
    if (target) return target;
    [self showAlertController:protosString];
    return nil;
}

/** 缓存target */
- (id)serviceCacheProvideForProtocol:(Protocol *)protocol {
    NSString *protosString = NSStringFromProtocol(protocol);
    NSString *targetString = [self.registeredDic objectForKey:protosString];
    id<WXMComponentFeedBack> target = [self.cacheTarget objectForKey:targetString];
    if (target) return target;
    
    target = [self serviceProvideForProtocol:protocol];
    if (target) [self.cacheTarget setObject:target forKey:targetString];
    return target ?: nil;
}

/** 删除缓存的target */
- (void)removeServiceCacheForProtocol:(Protocol *)protocol {
    NSString *protosString = NSStringFromProtocol(protocol);
    NSString *targetString = [self.registeredDic objectForKey:protosString];
    [self.cacheTarget removeObjectForKey:targetString];
}

/** 删掉Service */
- (void)removeServiceCache:(id)service {
    __block NSString *targetString = nil;
    [self.cacheTarget enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (obj == service) {
            targetString = key.copy;
            *stop = YES;
        }
    }];
    if (targetString) [self.cacheTarget removeObjectForKey:targetString];
}

/** 是否存在缓存 */
- (BOOL)exsitCacheServiceCache:(id)service {
    __block BOOL exsit = NO;
    [self.cacheTarget enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (obj == service) exsit = YES;
    }];
    return exsit;
}

/** 显示弹窗 */
- (void)showAlertController:(NSString *)title {
    if(WXMDEBUG == NO) return;
    UIAlertController *aler = nil;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSString * msg = [NSString stringWithFormat:@"协议:%@ 没有注册或类无法实例化",title];
  
    aler = [UIAlertController alertControllerWithTitle:@"提示"message:msg preferredStyle:1];
    UIAlertAction *can = [UIAlertAction actionWithTitle:@"取消" style:1 handler:nil];
    [aler addAction:can];
    [window.rootViewController presentViewController:aler animated:YES completion:nil];
}
#pragma clang diagnostic pop
@end


