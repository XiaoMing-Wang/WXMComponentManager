//
//  WXMComponentError.h
//  ModuleDebugging
//
//  Created by edz on 2019/9/3.
//  Copyright © 2019 wq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXMComponentError : NSObject

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

NS_ASSUME_NONNULL_END
