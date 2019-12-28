//
//  WXMMediatorService.h
//  Multi-project-coordination
//
//  Created by wq on 2019/12/25.
//  Copyright © 2019 wxm. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WXMMediatorConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMMediatorBaseService : NSObject

/** 是否优先返回缓存 */
@property (nonatomic, assign) BOOL accessCache;

/** 设置回调 */
- (void)setServiceCallback:(WXMServiceCallBack)callback;

/** 回调数据 */
- (void)sendNext:(WXMMediatorError *_Nullable)response;

/** 返回缓存 */
- (WXMMediatorError *_Nullable)cacheMediatorError;

@end

NS_ASSUME_NONNULL_END

