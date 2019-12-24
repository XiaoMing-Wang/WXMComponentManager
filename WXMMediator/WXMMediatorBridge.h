//
//  WXMMediatorBridge.h
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WXMMediatorConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class WXMMediatorSendContext;
@class WXMMediatorObserveContext;
@interface WXMMediatorBridge : NSObject

/** 发送信号 监听信号 */
+ (WXMMediatorSendContext * (^)(WXM_MEDIATOR_SIGNAL signal, id _Nullable object))sendSignal;

/** 监听 */
+ (WXMMediatorObserveContext * (^)(id target, WXM_MEDIATOR_SIGNAL signal))observe;

#pragma mark 内部调用
#pragma mark 内部调用
#pragma mark 内部调用
+ (void)addSignalReceive:(id)target;

@end

NS_ASSUME_NONNULL_END
