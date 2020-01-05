//
//  WXMBaseService.h
//  ModuleDebugging
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXMComponentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMComponentError : NSObject

/** 是否缓存 */
@property (nonatomic, assign) BOOL isCache;

/** 是否成功 */
@property (nonatomic, assign) BOOL success;

/** 错误码 */
@property (nonatomic, assign) NSInteger errorCode;

/** 错误信息 */
@property (nonatomic, strong) NSString *errorMessage;

/** object */
@property (nonatomic, strong) id object;

/** 初始化 */
+ (instancetype)error:(NSInteger)code message:(NSString *)message object:(id)object;

@end

@interface WXMComponentBaseService : NSObject

/** 判断是否需要返回缓存 外部设置 */
@property (nonatomic, assign, readwrite) BOOL accessCache;

/** 返回缓存 */
- (nullable WXMComponentError *)cacheComponentError;

/** f回调数据 */
- (void)sendNext:(WXMComponentError *_Nullable)response;

@end

NS_ASSUME_NONNULL_END

