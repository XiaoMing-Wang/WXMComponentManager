//
//  WQComponentManager.m
//  ModulesProject
//
//  Created by wq on 2019/4/19.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WQComponentManager.h"
#import <objc/runtime.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/ldsyms.h>
#import "WQComponentHeader.h"
//#import "WXMGeneralMacros.h"

@interface WQComponentManager ()

/** 协议和实例 */
@property (nonatomic) NSDictionary<NSString *,id> *registeredDic;
@property (nonatomic) NSDictionary<NSString *,id> *cacheTarget;
@end

@implementation WQComponentManager
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"

+ (instancetype)sharedInstance {
    static WQComponentManager *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[WQComponentManager alloc] init];
    });
    return mediator;
}

/* 注册service 和 protocol */
- (void)addService:(NSString *)service protocol:(NSString *)protocol {
    if (!self.registeredDic) self.registeredDic = @{}.mutableCopy;
    if (!self.cacheTarget) self.cacheTarget = @{}.mutableCopy;
    [self.registeredDic setValue:service forKey:protocol];
    NSLog(@"%@ ----- %@",service,protocol);
}
/* 获取service对象(服务调用者) */
- (id)serviceProvideForProtocol:(Protocol *)protocol {
    NSString *protosString = NSStringFromProtocol(protocol);
    NSString *targetString = [self.registeredDic objectForKey:protosString];
    id target = [self.cacheTarget objectForKey:targetString];
    if (target) return target;
    
    target = [NSClassFromString(targetString) new];
    if ([target conformsToProtocol:protocol] && target) {
        return target;
    }
    
#if DEBUG
    [self showAlertController:protosString];
#endif
    return nil;
}
/** 缓存target */
- (id)serviceCacheProvideForProtocol:(Protocol *)protocol {
    NSString *protosString = NSStringFromProtocol(protocol);
    NSString *targetString = [self.registeredDic objectForKey:protosString];
    id target = [self serviceCacheProvideForProtocol:protocol];
    if (target != nil) {
        [self.cacheTarget setValue:target forKey:targetString];
        return target;
    }
    return nil;
}

/** 发送消息 spe发射频段 */
- (void)sendEventModule:(NSString *)module event:(NSInteger)event eventObj:(id)eventObj {
    [self.registeredDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        Class class = NSClassFromString(obj);
        SEL sel = NSSelectorFromString(@"modules");
        SEL selEvents = NSSelectorFromString(@"events");
        
        BOOL respon = YES;
        if ([class respondsToSelector:sel]) {
            NSArray * array = [class performSelector:sel];
            respon = [array containsObject:module];
        }
        
        if ([class respondsToSelector:selEvents]) {
            NSArray * arrayEvents = [class performSelector:selEvents];
            respon = [arrayEvents containsObject:@(event).stringValue];
        }
        
        NSString * module_event = [NSString stringWithFormat:@"%@:%zd",module,event];
        SEL selRespond = NSSelectorFromString(@"providedEventModule_event:eventObj:");
        if (respon && [class respondsToSelector:selRespond]) {
            [class performSelector:selRespond withObject:module_event withObject:eventObj];
        }
    }];
}

/** 显示弹窗 */
- (void)showAlertController:(NSString *)title {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSString * msg = [NSString stringWithFormat:@"协议:%@ 没有注册",title];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *can = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:can];
    [window.rootViewController presentViewController:alertController animated:YES completion:nil];
}
#pragma clang diagnostic pop
@end


