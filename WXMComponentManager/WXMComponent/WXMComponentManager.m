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
    
    [self showAlertController:protosString];
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

/** 添加一个接收者 */
- (void)addSignalReceive:(id)target {
    if (!target) return;
    [self.allInstanceTarget addPointer:(__bridge void *_Nullable)(target)];
}

/** 发送消息 */
- (void)sendEventModule:(WXM_SIGNAL)identify eventObj:(id)eventObj {
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<WXMComponentFeedBack> obj in self.allInstanceTarget) {
            if (!obj || obj == self) return;
            
            WXMSignalObject *signalObject = [WXMSignalObject new];
            signalObject.signalName = identify;
            if ([eventObj isKindOfClass:[NSDictionary class]] && eventObj) {
                signalObject.parameter = (NSDictionary *)eventObj;
            } else if(eventObj != nil) {
                signalObject.callback = (RouterCallBack) eventObj;
            }
            
            /** 信息传递方式1.协议 */
            /** 信息传递方式1.协议 */
            /** 信息传递方式1.协议 */
            if ([obj respondsToSelector:@selector(wc_signals)]) {
                NSArray <WXM_SIGNAL>*signalArray = [obj wc_signals];
                if ([signalArray isKindOfClass:NSArray.class] && signalArray.count > 0){
                    BOOL exist = [signalArray containsObject:identify];
                    BOOL response = [obj respondsToSelector:@selector(wc_receivesSignalObject:)];
                    if (exist && response) [obj wc_receivesSignalObject:signalObject];
                }
            }
            
            /** 信息传递方式2.信号 */
            /** 信息传递方式2.信号 */
            /** 信息传递方式2.信号 */
            [WXMComponentContext handleSignalWithTarget:obj signalObject:signalObject];
        }
    });
    
    dispatch_semaphore_signal(lock);
}

/** 显示弹窗 */
- (void)showAlertController:(NSString *)title {
    if(WXMDEBUG == NO) return;
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


