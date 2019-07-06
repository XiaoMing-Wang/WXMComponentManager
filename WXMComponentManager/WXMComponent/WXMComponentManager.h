//
//  WQComponentManager.h
//  ModulesProject
//
//  Created by wq on 2019/4/19.
//  Copyright © 2019年 wq. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXMAllComponentProtocol.h"

NS_ASSUME_NONNULL_BEGIN

static char managerCallback;

@interface WXMComponentManager : NSObject

+ (instancetype)sharedInstance;

/* 注册service 和 protocol */
- (void)addService:(NSString *)target protocol:(NSString *)protocol;

/* 获取service对象(服务调用者) */
- (id)serviceProvideForProtocol:(Protocol *)protocol;
- (id)serviceCacheProvideForProtocol:(Protocol *)protocol;
- (void)removeServiceCacheForProtocol:(Protocol *)protocol;

/** 发送消息 module模块类 event事件 */
- (void)sendEventModule:(NSString *)module event:(NSInteger)event eventObj:(id)eventObj;
- (void)sendEventModule:(WXM_MESSAGE)identify eventObj:(id)eventObj;
@end

NS_ASSUME_NONNULL_END
