//
//  WXMComponentBridge.h
//  Multi-project-coordination
//
//  Created by wq on 2019/7/12.
//  Copyright © 2019年 wxm. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WXMComponentSignalContext.h"
#import "WXMComponentConfiguration.h"
#import "WXMComponentObserveContext.h"

NS_ASSUME_NONNULL_BEGIN
@interface WXMComponentBridge : NSObject

/** 获取路由传递下来的参数 */
+ (NSDictionary * (^)(id target))parameter;

/** 路由调用时的回调 */
+ (void (^)(id target, NSDictionary *_Nullable parameter))callBackForward;

/** 获取一个ObserveContext */
+ (WXMComponentObserveContext * (^)(id target, WXM_SIGNAL signal))observe;

/** 获取一个SignContext */
+ (WXMComponentSignalContext * (^)(WXM_SIGNAL signal, id _Nullable parameter))sendSignal;

@end
NS_ASSUME_NONNULL_END
