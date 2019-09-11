//
//  WXMComponentBridge.h
//  Multi-project-coordination
//
//  Created by wq on 2019/7/12.
//  Copyright © 2019年 wxm. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WXMComponentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class WXMSignalContext;
@class WXMObserveContext;
@interface WXMComponentBridge : NSObject

#pragma mark A-B单向传递

/** 获取路由传递下来的参数 */
+ (NSDictionary * (^)(id target))parameter;
+ (void (^)(id target, NSDictionary *_Nullable parameter))callBackForward;

/** 发送信号 监听信号 */
+ (WXMSignalContext * (^)(WXM_SIGNAL signal, id _Nullable parameter))sendSignal;
+ (WXMObserveContext * (^)(id target, WXM_SIGNAL signal))observe;

#pragma mark 内部调用
+ (void)removeObserveKeyPath:(id)signal;
+ (void)addSignalReceive:(id)target;
+ (void)handleParametersWithTarget:(id)target parameters:(id)parameter;
@end
NS_ASSUME_NONNULL_END
