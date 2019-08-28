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
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) id object;

+ (instancetype)error:(NSInteger)code message:(NSString *)message object:(id)object;

@end

@interface WXMComponentService : NSObject <WXMServiceFeedBack>

@end

NS_ASSUME_NONNULL_END
