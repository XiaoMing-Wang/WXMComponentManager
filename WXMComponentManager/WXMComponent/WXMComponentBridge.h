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

#pragma mark 初始化传值

/** 获取路由传递下来的参数 */
+ (NSDictionary * (^)(id target))parameter;

/** 路由调用时的回调 */
+ (void (^)(id target, NSDictionary *_Nullable parameter))callBackForward;

#pragma mark 收发信号

/** 发送 */
+ (WXMSignalContext * (^)(WXM_SIGNAL signal, id _Nullable parameter))sendSignal;

/** 监听*/
+ (WXMObserveContext * (^)(id target, WXM_SIGNAL signal))observe;

#pragma mark 内部调用
+ (void)addSignalReceive:(id)target;
+ (void)handleParametersWithTarget:(id)target parameters:(id)parameter;
@end
NS_ASSUME_NONNULL_END
