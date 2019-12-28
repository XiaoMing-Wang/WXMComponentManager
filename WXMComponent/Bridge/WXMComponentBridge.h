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

/** 跨界面传数据 */
+ (void)setObject:(id)object keyPath:(WXM_SIGNAL)keyPath;
+ (id)objectForKeyPath:(WXM_SIGNAL)keyPath;

/** 发送信号 监听信号 */
+ (WXMSignalContext * (^)(WXM_SIGNAL signal, id _Nullable parameter))sendSignal;
+ (WXMObserveContext * (^)(id target, WXM_SIGNAL signal))observe;

/** 获取上一个界面数据 */
+ (NSDictionary *)parameter:(id)target;
+ (void)sendNext:(id)target parameter:(NSDictionary * _Nullable)parameter;

#pragma mark 内部调用
#pragma mark 内部调用
#pragma mark 内部调用
+ (void)addSignalReceive:(id)target;
+ (void)handleParametersWithTarget:(id)target parameters:(id)parameter;
@end
NS_ASSUME_NONNULL_END
