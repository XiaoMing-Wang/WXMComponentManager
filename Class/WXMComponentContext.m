//
//  WXMComponentContext.m
//  Multi-project-coordination
//
//  Created by wq on 2019/7/9.
//  Copyright © 2019年 wxm. All rights reserved.
//

#import <objc/runtime.h>
#import "WXMComponentData.h"
#import "WXMComponentBridge.h"
#import "WXMComponentContext.h"

@interface WXMSignalContext ()
@property (nonatomic, strong) NSMutableArray *signArray;
@end

@interface WXMSignalDisposable ()
@property (nonatomic, weak) id removeTarget;
@property (nonatomic, copy) WXM_SIGNAL remoSignal;
@property (nonatomic, copy) void (^callback)(void);
@end
@implementation WXMObserveContext

#pragma mark 监听

- (WXMSignalDisposable *)subscribeNext:(ObserveCallBack)callback {
    if (!self.signal) return nil;
    
    @synchronized (self.target) {
        [self removeSameSignal];
        
        WXMListenObject *listenObject = [WXMListenObject new];
        listenObject.signal = self.signal;
        listenObject.callback = [callback copy];
        [self addSignal:listenObject];
        
        /** disposable需要强持有context */
        WXMSignalDisposable *disposable = [WXMSignalDisposable disposable:^{
            NSDictionary *dic = objc_getAssociatedObject(self.target, WXM_SIGNAL_KEY);
            NSMutableDictionary *dictionaryM = dic ? dic.mutableCopy : @{}.mutableCopy;
            [dictionaryM setValue:nil forKey:self.signal];
            objc_setAssociatedObject(self.target, WXM_SIGNAL_KEY, dictionaryM, 1);
        }];
        
        return disposable;
    }
}

- (void)addSignal:(WXMListenObject *)listenObject {
    NSDictionary *listens = objc_getAssociatedObject(self.target, WXM_SIGNAL_KEY);
    NSMutableDictionary *dictionaryM = listens ? listens.mutableCopy : @{}.mutableCopy;
    [dictionaryM setValue:listenObject forKey:listenObject.signal];
    objc_setAssociatedObject(self.target, WXM_SIGNAL_KEY, dictionaryM, 1);
    [WXMComponentBridge addSignalReceive:self.target];
}

/** 删除当前对象同名信号 */
- (void)removeSameSignal {
    NSDictionary *listens = objc_getAssociatedObject(self.target, WXM_SIGNAL_KEY);
    NSMutableDictionary *dictionaryM = listens ? listens.mutableCopy : @{}.mutableCopy;
    [dictionaryM setValue:nil forKey:self.signal];
    objc_setAssociatedObject(self.target, WXM_SIGNAL_KEY, dictionaryM, 1);
}
@end

#pragma mark 发送信号

@implementation WXMSignalContext

- (void)addSignal:(WXMSignal *)signal {
    [self.signArray addObject:signal];
    [self bindCallbackWithAllSignal];
}

- (void)subscribeNext:(SignalCallBack)callback {
    self.callback = callback;
    [self bindCallbackWithAllSignal];
}

- (void)bindCallbackWithAllSignal {
    if (!self.callback) return;
    for (WXMSignal *signal in self.signArray) {
        [signal setValue:self.callback forKey:WXM_SIGNAL_CALLBACK];
    }
}

- (NSMutableArray *)signArray {
    if (!_signArray) _signArray = @[].mutableCopy;
    return _signArray;
}

@end

#pragma mark WXMSignalDisposable

@implementation WXMSignalDisposable
+ (instancetype)disposable:(void (^)(void))callback {
    WXMSignalDisposable *disposable = [[WXMSignalDisposable alloc] init];
    disposable.callback = [callback copy];
    return disposable;
}

- (void)disposable {
    @synchronized(self) {
        if (self.callback) self.callback();
    }
}

@end
