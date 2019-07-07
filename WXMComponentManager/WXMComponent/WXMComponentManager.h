//
//  WQComponentManager.h
//  ModulesProject
//
//  Created by wq on 2019/4/19.
//  Copyright © 2019年 wq. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXMComponentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

static char managerCallback;

@interface WXMComponentManager : NSObject

+ (instancetype)sharedInstance;

/* 注册service 和 protocol */
- (void)addService:(NSString *)target protocol:(NSString *)protocol;

/** 获取service对象
 @param protocol 协议
 @return service对象  */
- (id)serviceProvideForProtocol:(Protocol *)protocol;
- (id)serviceCacheProvideForProtocol:(Protocol *)protocol;
- (void)removeServiceCacheForProtocol:(Protocol *)protocol;

/** 添加一个信号接收者(接收者不是通过 WXMComponentManager创建出来)
 @param target 信号接收者 */
- (void)addSignalReceive:(id)target;

/** 发送信号
 @param identify 信号标识(字符枚举)
 @param eventObj 携带参数 */
- (void)sendEventModule:(WXM_SIGNAL)identify eventObj:(nullable id)eventObj;
@end

NS_ASSUME_NONNULL_END
