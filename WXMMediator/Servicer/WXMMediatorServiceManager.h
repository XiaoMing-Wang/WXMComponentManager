//
//  WXMMediatorServiceManager.h
//  Multi-project-coordination
//
//  Created by wq on 2019/12/25.
//  Copyright © 2019 wxm. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXMMediatorError : NSObject

/** 是否缓存 */
@property (nonatomic, assign) BOOL isCache;

/** 是否成功 */
@property (nonatomic, assign) BOOL success;

/** 错误码 */
@property (nonatomic, assign) NSInteger code;

/** 错误信息 */
@property (nonatomic, strong) NSString *message;

/** object */
@property (nonatomic, strong) id object;

+ (instancetype)error:(NSInteger)code message:(NSString *)message object:(id)object;

@end

@class WXMMediatorBaseService;
@interface WXMMediatorServiceManager : NSObject

/** service管理类 */
+ (instancetype)sharedInstance;

/** 创建service(回调或者depend被释放时service销毁) */
- (WXMMediatorBaseService *)serviceForClass:(Class)aClass dependObject:(id)dependObject;

@end

NS_ASSUME_NONNULL_END
