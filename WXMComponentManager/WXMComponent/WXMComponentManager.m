//
//  WQComponentManager.m
//  ModulesProject
//
//  Created by wq on 2019/4/19.
//  Copyright © 2019年 wq. All rights reserved.
//
#import <objc/runtime.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/ldsyms.h>
#import "WXMComponentHeader.h"
#import "WXMComponentManager.h"

@interface WXMComponentManager ()

/** 协议和实例 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *registeredDic;

/** 缓存实例对象 引用计数+1 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *cacheTarget;

/** 保存所有初始化的对象(用于发送信息) */
@property (nonatomic, strong) NSPointerArray *allInstanceTarget;
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
        mediator.allInstanceTarget = [NSPointerArray weakObjectsPointerArray];
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
    id<WXMComponentFeedBack> target = [self.cacheTarget objectForKey:targetString];
    if (target) return target;
    
    target = [NSClassFromString(targetString) new];
    if ([target conformsToProtocol:protocol] && target) {
        
        /** 目前存在的实例对象 发送消息使用 弱引用 */
        [self.allInstanceTarget addPointer:(__bridge void *_Nullable)(target)];
        
        /** NSObject做中间类会被释放 接收消息需要强引用不被释放 */
        BOOL needCache = NO;
        SEL cacheImp = @selector(wc_cacheImplementer);
        if ([target respondsToSelector:cacheImp]) needCache = [target wc_cacheImplementer];
        if (needCache && [target isKindOfClass:[NSObject class]]) {
            [self.cacheTarget setValue:target forKey:targetString];
        }
        return target;
    }
    
#ifdef DEBUG
    [self showAlertController:protosString];
#endif
    return nil;
}

/** 缓存target */
- (id)serviceCacheProvideForProtocol:(Protocol *)protocol {
    id target = [self serviceCacheProvideForProtocol:protocol];
    if (target != nil) {
        NSString *protosString = NSStringFromProtocol(protocol);
        NSString *targetString = [self.registeredDic objectForKey:protosString];
        [self.cacheTarget setValue:target forKey:targetString];
        return target;
    }
    return nil;
}

/** 删除缓存的target */
- (void)removeServiceCacheForProtocol:(Protocol *)protocol {
    NSString *protosString = NSStringFromProtocol(protocol);
    NSString *targetString = [self.registeredDic objectForKey:protosString];
    [self.cacheTarget removeObjectForKey:targetString];
}

/** 发送消息 */
- (void)sendEventModule:(NSString *)module event:(NSInteger)event eventObj:(id)eventObj {
    
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<WXMComponentFeedBack> obj in self.allInstanceTarget) {
            if (!obj || obj == self) return;
        
            BOOL response = YES;
            if ([obj respondsToSelector:@selector(modules_events)]) {
                NSArray *array = [obj wc_modules_events];
                response = [self determineWhetherSend:module event:event modulearray:array];
            }
            
            if ([obj respondsToSelector:@selector(wc_receivesMessageWithEventModule:)]) {
                WXMMessageContext *context = [WXMMessageContext new];
                context.module = module;
                context.event = event;
                if ([eventObj isKindOfClass:[NSDictionary class]] && eventObj) {
                    NSDictionary *parameters = (NSDictionary *)eventObj;
                    context.parameter = parameters;
                } else if(eventObj != nil) {
                    objc_AssociationPolicy policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
                    RouterCallBack callBack = (RouterCallBack) eventObj;
                    context.callBack = callBack;
                    objc_setAssociatedObject(obj, &managerCallback, callBack, policy);
                }
                [obj wc_receivesMessageWithEventModule:context];
            }
        }
    });
    
    dispatch_semaphore_signal(lock);
}

/** 判断是否响应 */
- (BOOL)determineWhetherSend:(NSString *)module
                       event:(NSInteger)event
                 modulearray:(NSArray *)modulearray {
    NSString * module_event = [NSString stringWithFormat:@"%@(%zd)",module,event];
    NSString * module_all = [NSString stringWithFormat:@"%@(-)",module];
    if (modulearray == nil) return NO;
    if ([modulearray containsObject:module_all]) return YES;
    if ([modulearray containsObject:module_event]) return YES;
    
    /** 不支持数组里有多个相同协议头的string 会增加遍历次数 */
    __block BOOL response = NO;
    [modulearray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([obj hasPrefix:module]) {
            NSString * number = [obj stringByReplacingOccurrencesOfString:module withString:@""];
            response = [self matchingEvent:event qualified:number];
            *stop = YES;
        }
    }];
    return response;
}

- (BOOL)matchingEvent:(NSInteger)event qualified:(NSString *)qualified {
    __block BOOL response = NO;
    NSString *eventString = @(event).stringValue;
    qualified = [qualified stringByReplacingOccurrencesOfString:@"(" withString:@""];
    qualified = [qualified stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSArray *numberArray = [qualified componentsSeparatedByString:@","];
    if ([numberArray containsObject:eventString]) return YES;
    [numberArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * stop) {
        if ([obj containsString:@"-"]) {
            NSInteger start = [obj componentsSeparatedByString:@"-"].firstObject.integerValue;
            NSInteger end = [obj componentsSeparatedByString:@"-"].lastObject.integerValue;
            if (event >= start && event <= end) {
                response = YES;
                *stop = YES;
            }
        }
    }];
    return response;
}

/** 显示弹窗 */
- (void)showAlertController:(NSString *)title {
    UIAlertController *aler = nil;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NSString * msg = [NSString stringWithFormat:@"协议:%@ 没有注册",title];
  
    aler = [UIAlertController alertControllerWithTitle:@"提示"message:msg preferredStyle:1];
    UIAlertAction *can = [UIAlertAction actionWithTitle:@"取消" style:1 handler:nil];
    [aler addAction:can];
    [window.rootViewController presentViewController:aler animated:YES completion:nil];
}
#pragma clang diagnostic pop
@end


