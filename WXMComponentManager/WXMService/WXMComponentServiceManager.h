//
//  WXMComponentServiceManager.h
//  ModuleDebugging
//
//  Created by edz on 2019/8/28.
//  Copyright © 2019 wq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXMComponentService;
@interface WXMComponentServiceManager : NSObject

+ (instancetype)sharedInstance;

/** 创建service(回调或者depend被释放时service销毁) */
- (id)serviceProvide:(Protocol *)protocol depend:(id)depend;

/** 创建单例service */
- (id)serviceCacheProvide:(Protocol *)protocol;


- (id)serviceCacheProvide:(Protocol *)protocol depend:(id)depend;

@end

NS_ASSUME_NONNULL_END
