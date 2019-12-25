//
//  WXMMediatorBridge.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMMediatorBridgeData.h"
#import "WXMMediatorBridge.h"
#import "WXMMediatorBridgeContext.h"

static NSPointerArray *_allInstanceTarget;
@implementation WXMMediatorBridge

+ (void)load {
    if (!_allInstanceTarget) _allInstanceTarget = [NSPointerArray weakObjectsPointerArray];
}

/** 发送信号 */
+ (WXMMediatorSendContext * (^)(WXM_MEDIATOR_SIGNAL signal, id _Nullable object))sendSignal {
    return ^WXMMediatorSendContext *(WXM_MEDIATOR_SIGNAL signal, id _Nullable object) {
        WXMMediatorSendContext *context = [[WXMMediatorSendContext alloc] init];
        context.signal = signal;
        context.object = object;
        [self sendSignalWithContext:context];
        return context;
    };
}

/** 遍历数组发送信号 */
+ (void)sendSignalWithContext:(WXMMediatorSendContext *)context {
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{ lock = dispatch_semaphore_create(1); });
    
    dispatch_queue_t queque = dispatch_queue_create("WXM_Goyakod", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    dispatch_async(queque, ^{
        for (id target in _allInstanceTarget) {
            [self handleSignalWithTarget:target context:context];
        }
        dispatch_semaphore_signal(lock);
    });
}

/** 处理信号 */
+ (void)handleSignalWithTarget:(id)target context:(WXMMediatorSendContext *)context {
    NSDictionary *listens = nil;
    listens = objc_getAssociatedObject(target, WXMMEDIATOR_SIGNAL_KEY);
    if (!listens || listens.allKeys.count == 0) return;

    WXMMediatorListen *listenObjec = [listens objectForKey:context.signal];
    if (listenObjec && listenObjec.callback) {
        dispatch_async(dispatch_get_main_queue(), ^{
            WXMMediatorSignal *signal = [WXMMediatorBridge achieve:context];
            listenObjec.callback(signal);
        });
    }
}

/** 获取一个WXMMediatorSignal */
+ (WXMMediatorSignal *)achieve:(WXMMediatorSendContext *)context {
    WXMMediatorSignal *signal = [WXMMediatorSignal new];
    signal.signal = context.signal;
    signal.object = context.object;
    [context addSignal:signal];
    return signal;
}

/** 监听信号 */
+ (WXMMediatorObserveContext * (^)(id target, WXM_MEDIATOR_SIGNAL signal))observe {
    return ^WXMMediatorObserveContext *(id target, WXM_MEDIATOR_SIGNAL signal) {
        WXMMediatorObserveContext *context = [[WXMMediatorObserveContext alloc] init];
        context.target = target;
        context.signal = signal;
        return context;
    };
}

/** 数组保存字典 */
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
