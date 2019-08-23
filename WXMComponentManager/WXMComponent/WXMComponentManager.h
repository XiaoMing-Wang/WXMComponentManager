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

/** 获取service对象(多个service)*/
- (id)serviceProvideForProtocol:(Protocol *)protocol;

/** 获取service对象(缓存独一份) */
- (id)serviceCacheProvideForProtocol:(Protocol *)protocol;

/** 删除service对象 */
- (void)removeServiceCacheForProtocol:(Protocol *)protocol;
- (void)removeServiceCache:(id)service;
@end

NS_ASSUME_NONNULL_END
