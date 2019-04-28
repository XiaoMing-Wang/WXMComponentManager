//
//  WQComponentManager.h
//  ModulesProject
//
//  Created by wq on 2019/4/19.
//  Copyright © 2019年 wq. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface WQComponentManager : NSObject

+ (instancetype)sharedInstance;

/* 注册service 和 protocol */
- (void)addService:(id)target protocol:(NSString *)protocol;

/* 获取service对象(服务调用者) */
- (id)serviceProvideForProtocol:(Protocol *)protocol;
- (id)serviceCacheProvideForProtocol:(Protocol *)protocol;

/** 发送消息 spe发射频段 */
- (void)sendEventType:(NSString *)eventType eventObj:(id)eventObj;
@end
NS_ASSUME_NONNULL_END
