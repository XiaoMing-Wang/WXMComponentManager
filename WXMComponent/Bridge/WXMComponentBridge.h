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

/** 发送信号 监听信号 */
+ (WXMSignalContext * (^)(WXM_SIGNAL signal, id _Nullable parameter))sendSignal;
+ (WXMObserveContext * (^)(id target, WXM_SIGNAL signal))observe;

#pragma mark 内部调用
#pragma mark 内部调用
#pragma mark 内部调用
+ (void)addSignalReceive:(id)target;

@end
NS_ASSUME_NONNULL_END
