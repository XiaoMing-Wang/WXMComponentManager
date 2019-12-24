//
//  WXMMediatorBridgeContext.h
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXMMediatorConfiguration.h"

@class WXMMediatorSignal;
@class WXMMediatorDisposable;
NS_ASSUME_NONNULL_BEGIN

/** 监听信号 */
@interface WXMMediatorObserveContext : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, copy) WXM_MEDIATOR_SIGNAL signal;
- (WXMMediatorDisposable *)subscribeNext:(WXMObserveCallBack)callback;
@end

/** 发送信号 */
@interface WXMMediatorSendContext : NSObject
@property (nonatomic, strong) id object;
@property (nonatomic, strong) WXM_MEDIATOR_SIGNAL signal;
@property (nonatomic, strong) WXMSignalCallBack callback;
- (void)subscribeNext:(WXMSignalCallBack)callback;
- (void)addSignal:(WXMMediatorSignal *)signal;
@end

/** 释放 */
@interface WXMMediatorDisposable : NSObject
+ (instancetype)disposable:(void (^)(void))callback;
- (void)disposable;
@end


NS_ASSUME_NONNULL_END
