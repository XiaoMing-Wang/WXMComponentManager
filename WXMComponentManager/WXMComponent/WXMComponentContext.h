//
//  WXMComponentContext.h
//  ModuleDebugging
//
//  Created by edz on 2019/7/7.
//  Copyright © 2019 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXMComponentConfiguration.h"
#import "WXMComponentData.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMComponentContext : NSObject

/** 获取路由传递下来的参数 NSDictionary *param = WXMComponentContext.parameter(self);  */
+ (NSDictionary *(^)(id obj))parameter;

/** 路由调用时的回调  WXMComponentContext.callBackForward(self, parameter); */
+ (void (^)(id target, NSDictionary* _Nullable parameter))callBackForward;

/** 获取一个WXMComponentContext对象 */
+ (WXMComponentContext *(^)(id target, WXM_SIGNAL signal))observe;

/** 保存 */
- (void)subscribeNext:(RouterCallBack)callback;

#pragma mark 内部调用
+ (void)handleParametersWithTarget:(id)target parameters:(id)parameter;
+ (void)handleSignalWithTarget:(id)target signalObject:(WXMSignalObject *)signalObject;
@end

NS_ASSUME_NONNULL_END
