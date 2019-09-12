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

@interface WXMObserveContext ()
@property (nonatomic, assign) BOOL coldSignals;
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
        
        /** 冷信号直接返回 */
        if (self.coldSignals && callback) {
            WXMSignal *cacheSignal = objc_getAssociatedObject(self, WXM_SIGNAL_CACHE);
            callback(cacheSignal);
        } else if(self.coldSignals == NO) {
            [WXMComponentBridge removeObserveKeyPath:(NSString *)self.signal];
        }
                
        /** disposable需要强持有context */
        WXMSignalDisposable *disposable = [WXMSignalDisposable disposable:^{
            NSArray *listens = objc_getAssociatedObject(self.target, WXM_SIGNAL_KEY);
            NSMutableArray *weekArrayMutable = listens ? listens.mutableCopy : @[].mutableCopy;
            for (WXMListenObject *listenObject in listens.reverseObjectEnumerator) {
                if ([listenObject.signal isEqualToString:self.signal]) {
                    [weekArrayMutable removeObject:listenObject];
                }
            }
            if (!self.target || !self) return;
            objc_setAssociatedObject(self.target, WXM_SIGNAL_KEY, weekArrayMutable.copy, 1);
        }];
        
        return disposable;
    }
}

- (void)addSignal:(WXMListenObject *)listenObject {
    NSArray *listens = objc_getAssociatedObject(self.target, WXM_SIGNAL_KEY);
    NSMutableArray *arrayMutable = listens ? listens.mutableCopy : @[].mutableCopy;
    [arrayMutable addObject:listenObject];
    
    if (!self.target) return;
    objc_setAssociatedObject(self.target, WXM_SIGNAL_KEY, arrayMutable, 1);
    [WXMComponentBridge addSignalReceive:self.target];
}

/** 删除当前对象同名信号 */
- (void)removeSameSignal {
    NSArray *listens = objc_getAssociatedObject(self.target, WXM_SIGNAL_KEY);
    NSMutableArray *arrayMutable = listens ? listens.mutableCopy : @[].mutableCopy;
    for (int i = 0; i < arrayMutable.count; i++) {
        WXMListenObject *listenObject = [arrayMutable objectAtIndex:i];
        if ([listenObject.signal isEqualToString:self.signal]) {
            [arrayMutable removeObject:listenObject];
        }
    }
    
    if (!self.target) return;
    objc_setAssociatedObject(self.target, WXM_SIGNAL_KEY, arrayMutable, 1);
}

- (WXMObserveContext *)coldSignal {
    self.coldSignals = YES;
    return self;
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
