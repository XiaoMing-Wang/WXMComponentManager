//
//  WXMComponentBridge.m
//  Multi-project-coordination
//
//  Created by wq on 2019/7/12.
//  Copyright © 2019年 wxm. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMComponentData.h"
#import "WXMComponentBridge.h"
#import "WXMComponentContext.h"

static char parameterKey;
static char callbackKey;
static NSPointerArray *_allInstanceTarget;
@implementation WXMComponentBridge

+ (void)load {
    if (!_allInstanceTarget) _allInstanceTarget = [NSPointerArray weakObjectsPointerArray];
}

+ (void)handleParametersWithTarget:(id)target parameters:(id)parameter {
    if (!target || !parameter) return;
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
    BOOL isDictionary = [parameter isKindOfClass:NSDictionary.class];
    if (isDictionary) objc_setAssociatedObject(target, &parameterKey, parameter, policy);
    else objc_setAssociatedObject(target, &callbackKey, parameter, policy);
}

/** 获取路由传递下来的参数 */
+ (NSDictionary *)parameter:(id)target {
    return objc_getAssociatedObject(target, &parameterKey);
}

/** 路由调用时的回调 */
+ (SignalCallBack)signalCallBack:(id)target {
    SignalCallBack callback = objc_getAssociatedObject(target, &callbackKey);
    return callback ?: nil;
}

#pragma mark _____________________________ 收发信号

/** 监听*/
+ (WXMObserveContext * (^)(id target, WXM_SIGNAL signal))observe {
    return ^WXMObserveContext *(id target, WXM_SIGNAL signal) {
        WXMObserveContext *context = [[WXMObserveContext alloc] init];
        context.target = target;
        context.signal = signal;
        return context;
    };
}

/** 发送 */
+ (WXMSignalContext * (^)(WXM_SIGNAL signal, id _Nullable parameter))sendSignal {
    return ^WXMSignalContext *(WXM_SIGNAL signal, id _Nullable parameter) {
        WXMSignalContext *context = [[WXMSignalContext alloc] init];
        context.signal = signal;
        context.parameter = parameter;
        [self sendSignalWithContext:context];
        return context;
    };
}

/** 遍历数组发送信号 */
+ (void)sendSignalWithContext:(WXMSignalContext *)context {
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_queue_t queque = dispatch_queue_create("WXM_Goyakod", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    
    /** 删除nil指针 */
    [WXMComponentBridge cleanTargetArray];
    dispatch_async(queque, ^{
        for (id obj in _allInstanceTarget) {
            if (obj && context) [self handleSignalWithTarget:obj context:context];
        }
        dispatch_semaphore_signal(lock);
    });
}

/** 处理信号 */
+ (void)handleSignalWithTarget:(id)target context:(WXMSignalContext *)context {
    NSDictionary *listens = nil;
    listens = objc_getAssociatedObject(target, WXM_SIGNAL_KEY);
    if (!listens || listens.allKeys.count == 0) return;
    WXMListenObject *listenObjec = [listens valueForKey:context.signal];
    if (listenObjec && listenObjec.callback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WXMSignal *signal = [WXMComponentBridge achieve:context];
            listenObjec.callback(signal);
        });
    }
}

/** 获取一个YDOSignal */
+ (WXMSignal *)achieve:(WXMSignalContext *)context {
    WXMSignal * signal = [WXMSignal new];
    signal.signal = context.signal;
    signal.object = context.parameter;
    [context addSignal:signal];
    return signal;
}

/** 添加一个接收者 */
+ (void)addSignalReceive:(id)target {
    if (!target) return;
    BOOL haveTarget = NO;
    for (int i = 0; i < _allInstanceTarget.count; i++) {
        id obj = [_allInstanceTarget pointerAtIndex:i];
        if (obj == target) haveTarget = YES;
    }
    
    if(!haveTarget) [_allInstanceTarget addPointer:(__bridge void *)(target)];
}

/** 去掉nil对象 */
+ (void)cleanTargetArray {
    NSPointerArray *weekArray = [NSPointerArray weakObjectsPointerArray];
    for (int i = 0; i < _allInstanceTarget.count; i++) {
        id obj = [_allInstanceTarget pointerAtIndex:i];
        if (obj != nil) [weekArray addPointer:(__bridge void * _Nullable)(obj)];
    }
    _allInstanceTarget = weekArray;
}

@end
