//
//  WXMMediatorServiceManager.h
//  Multi-project-coordination
//
//  Created by wq on 2019/12/25.
//  Copyright © 2019 wxm. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WXMMediatorBaseService;
@interface WXMMediatorServiceManager : NSObject

/** service管理类 */
+ (instancetype)sharedInstance;

/** 创建service(回调或者depend被释放时service销毁) */
- (WXMMediatorBaseService *)serviceForClass:(Class)aClass dependObject:(id)dependObject;

@end

NS_ASSUME_NONNULL_END
