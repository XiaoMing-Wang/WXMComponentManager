//
//  WXMMediatorBridgeContext.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMMediatorBridge.h"
#import "WXMMediatorBridgeData.h"
#import "WXMMediatorBridgeContext.h"

@interface WXMMediatorSendContext ()
@property (nonatomic, strong) NSMutableArray<WXMMediatorSignal *> *signArray;
@end

@interface WXMMediatorDisposable ()
@property (nonatomic, weak) id removeTarget;
@property (nonatomic, copy) WXM_MEDIATOR_SIGNAL remoSignal;
@property (nonatomic, copy) void (^callback)(void);
@end

#pragma mark 监听信号
#pragma mark 监听信号
#pragma mark 监听信号

@implementation WXMMediatorObserveContext

/** 添加一个信号-target */
- (WXMMediatorDisposable *)subscribeNext:(WXMObserveCallBack)callback {
    if (!self.signal) return nil;
    
    @synchronized (self.target) {
        [self removeSameSignal];
       
        WXMMediatorListen *listenObject = [WXMMediatorListen new];
        listenObject.signal = self.signal;
        listenObject.callback = [callback copy];
        [self addSignal:listenObject];
                
        /** disposable需要强持有context */
        WXMMediatorDisposable *disposable = [WXMMediatorDisposable disposable:^{
            NSDictionary *dic = objc_getAssociatedObject(self.target, WXMMEDIATOR_SIGNAL_KEY);
            NSMutableDictionary *dictionaryM = dic ? dic.mutableCopy : @{}.mutableCopy;
            [dictionaryM removeObjectForKey:self.signal];
            
            if (!self.target || !self) return;
            NSDictionary *newDict = dictionaryM.copy;
            objc_setAssociatedObject(self.target, WXMMEDIATOR_SIGNAL_KEY, newDict, 1);
        }];
        
        return disposable;
    }
}

/** 添加信号 */
- (void)addSignal:(WXMMediatorListen *)listenObject {
    NSDictionary *listens = objc_getAssociatedObject(self.target, WXMMEDIATOR_SIGNAL_KEY);
    NSMutableDictionary *dictionaryM = listens ? listens.mutableCopy : @{}.mutableCopy;
    
    if (dictionaryM && listenObject.signal) {
        [dictionaryM setValue:listenObject forKey:listenObject.signal];
    }
    
    if (!self.target) return;
    objc_setAssociatedObject(self.target, WXMMEDIATOR_SIGNAL_KEY, dictionaryM, 1);
    [WXMMediatorBridge addSignalReceive:self.target];
}

/** 删除当前对象同名信号 */
- (void)removeSameSignal {
    NSArray *listens = objc_getAssociatedObject(self.target, WXMMEDIATOR_SIGNAL_KEY);
    NSMutableArray *arrayMutable = listens ? listens.mutableCopy : @[].mutableCopy;
    for (int i = 0; i < arrayMutable.count; i++) {
        WXMMediatorListen *listenObject = [arrayMutable objectAtIndex:i];
        if ([listenObject.signal isEqualToString:self.signal]) {
            [arrayMutable removeObject:listenObject];
        }
    }
    if (!self.target) return;
    objc_setAssociatedObject(self.target, WXMMEDIATOR_SIGNAL_KEY, arrayMutable, 1);
}

@end

#pragma mark 发送信号
#pragma mark 发送信号
#pragma mark 发送信号

@implementation WXMMediatorSendContext

- (void)addSignal:(WXMMediatorSignal *)signal {
    [self.signArray addObject:signal];
    [self bindCallbackWithAllSignal];
}

- (void)subscribeNext:(WXMSignalCallBack)callback {
    self.callback = callback;
    [self bindCallbackWithAllSignal];
}

- (void)bindCallbackWithAllSignal {
    if (!self.callback) return;
    for (WXMMediatorSignal *signal in self.signArray) {
        [signal setValue:self.callback forKey:WXMMEDIATOR_SIGNAL_CALLBACK];
    }
}

- (NSMutableArray <WXMMediatorSignal *>*)signArray {
    if (!_signArray) _signArray = @[].mutableCopy;
    return _signArray;
}

@end

#pragma mark WXMSignalDisposable
#pragma mark WXMSignalDisposable
#pragma mark WXMSignalDisposable

@implementation WXMMediatorDisposable
+ (instancetype)disposable:(void (^)(void))callback {
    WXMMediatorDisposable *disposable = [[WXMMediatorDisposable alloc] init];
    disposable.callback = [callback copy];
    return disposable;
}

- (void)disposable {
    @synchronized(self) {
        if (self.callback) self.callback();
    }
}

@end
