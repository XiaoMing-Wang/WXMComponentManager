//
//  WXMComponentContext.h
//  ModuleDebugging
//
//  Created by edz on 2019/7/19.
//  Copyright © 2019 wq. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WXMComponentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN
@class WXMSignalDisposable;

/** 监听信号 */
@interface WXMObserveContext : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, copy) WXM_SIGNAL signal;
- (WXMObserveContext *)coldSignal;
- (WXMSignalDisposable *)subscribeNext:(ObserveCallBack)callback;
@end

/** 发送信号 */
@interface WXMSignalContext : NSObject
@property (nonatomic, strong) id parameter;
@property (nonatomic, strong) WXM_SIGNAL signal;
@property (nonatomic, copy) SignalCallBack callback;
- (void)subscribeNext:(SignalCallBack)callback;
- (void)addSignal:(WXMSignal *)signal;
@end

/** 释放 */
@interface WXMSignalDisposable : NSObject
+ (instancetype)disposable:(void (^)(void))callback;

/** 取消掉当前信号 */
- (void)disposable;
@end
NS_ASSUME_NONNULL_END
