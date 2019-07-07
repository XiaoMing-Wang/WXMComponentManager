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
@interface WXMComponentManager : NSObject

+ (instancetype)sharedInstance;

/* 注册service 和 protocol */
- (void)addService:(NSString *)target protocol:(NSString *)protocol;

/** 获取service对象 */
- (id)serviceProvideForProtocol:(Protocol *)protocol;
- (id)serviceCacheProvideForProtocol:(Protocol *)protocol;
- (void)removeServiceCacheForProtocol:(Protocol *)protocol;

/** 添加信号接收者  */
- (void)addSignalReceive:(id)target;

/** 发送信号 */
- (void)sendEventModule:(WXM_SIGNAL)identify eventObj:(nullable id)eventObj;
@end

NS_ASSUME_NONNULL_END
