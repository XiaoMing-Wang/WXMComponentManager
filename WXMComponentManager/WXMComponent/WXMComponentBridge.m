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
static NSMutableDictionary *_allObserveObject;
@implementation WXMComponentBridge

+ (void)load {
    if (!_allInstanceTarget) _allInstanceTarget = [NSPointerArray weakObjectsPointerArray];
    if (!_allObserveObject) _allObserveObject = @{}.mutableCopy;
}

+ (void)handleParametersWithTarget:(id<WXMComponentFeedBack>)target parameters:(id)parameter {
    if (!target || !parameter) return;
    
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
    WXMParameterObject *parameterObject = [WXMParameterObject new];
    BOOL isDictionary = [parameter isKindOfClass:NSDictionary.class];
    if (isDictionary) {
        parameterObject.parameter = (NSDictionary *) parameter;
        objc_setAssociatedObject(target, &parameterKey, parameter, policy);
    } else {
        parameterObject.callback = (SignalCallBack) parameter;
        objc_setAssociatedObject(target, &callbackKey, parameter, policy);
    }
    
    /** 代理回调 */
    if ([target respondsToSelector:@selector(wc_receiveParameters:)]) {
        [target wc_receiveParameters:parameterObject];
    }
}

/** 获取路由传递下来的参数 */
+ (NSDictionary *(^)(id obj))parameter {
    return ^NSDictionary *(id obj) {
        return objc_getAssociatedObject(obj, &parameterKey);
    };
}

/** 路由调用时的回调 */
+ (void (^)(id target, NSDictionary *_Nullable parameter))callBackForward {
    return ^(id target, NSDictionary *parameter) {
        SignalCallBack callback = objc_getAssociatedObject(target, &callbackKey);
        if (callback) callback(parameter);
    };
}

#pragma mark _____________________________ 收发信号

/** 监听*/
+ (WXMObserveContext * (^)(id target, WXM_SIGNAL signal))observe {
    return ^WXMObserveContext *(id target, WXM_SIGNAL signal) {
        WXMObserveContext *context = [[WXMObserveContext alloc] init];
        context.target = target;
        context.signal = signal;
        WXMSignal *cacheSignal = [_allObserveObject objectForKey:signal];
        if (cacheSignal) objc_setAssociatedObject(context, WXM_SIGNAL_CACHE, cacheSignal, 1);
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
    
    /** 缓存传递参数 */
    NSString *keyPath = context.signal ?: @"";
    WXMSignal *signalObjs = [WXMComponentBridge achieve:context];
    if (keyPath && signalObjs) [_allObserveObject setObject:signalObjs forKey:keyPath];
    if (keyPath && signalObjs == nil) [_allObserveObject removeObjectForKey:keyPath];
    
    dispatch_async(queque, ^{
        for (id<WXMComponentFeedBack> obj in _allInstanceTarget) {
            
            /** 信息传递方式1.协议 */
            /** 信息传递方式1.协议 */
            /** 信息传递方式1.协议 */
            if ([obj respondsToSelector:@selector(wc_signals)]) {
                NSArray <WXM_SIGNAL>*signalArray = [obj wc_signals];
                if ([signalArray isKindOfClass:NSArray.class] && signalArray.count > 0){
                    BOOL exist = [signalArray containsObject:context.signal];
                    BOOL res = [obj respondsToSelector:@selector(wc_receivesSignalObject:)];
                    if (exist && res) [obj wc_receivesSignalObject:signalObjs];
                }
            }
            
            /** 信息传递方式2.信号 */
            /** 信息传递方式2.信号 */
            /** 信息传递方式2.信号 */
            if (obj && context) [self handleSignalWithTarget:obj context:context];
        }
        dispatch_semaphore_signal(lock);
    });
}

/** 处理信号 */
+ (void)handleSignalWithTarget:(id)target context:(WXMSignalContext *)context {
    NSArray <WXMListenObject *>*listens = objc_getAssociatedObject(target, WXM_SIGNAL_KEY);
    if (!listens || listens.count == 0) return;
    
    for (WXMListenObject *listenObjec in listens) {
        if ([listenObjec.signal isEqualToString:context.signal]) {
            WXMSignal *signal = [WXMComponentBridge achieve:context];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (listenObjec.callback) listenObjec.callback(signal);
            });
        }
    }
}

+ (void)removeObserveKeyPath:(WXM_SIGNAL)signal {
    if ([_allObserveObject objectForKey:signal]) {
        [_allObserveObject removeObjectForKey:signal];
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
