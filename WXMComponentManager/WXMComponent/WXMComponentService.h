//
//  WXMBaseService.h
//  ModuleDebugging
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 wq. All rights reserved.
//
#define  NullB id _Nullable
#import <Foundation/Foundation.h>
#import "WXMComponentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMResponse : NSObject
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) NSString *errorMsg;
@property (nonatomic, strong) id object;
@end

static inline WXMResponse *__WXMResponse(int errorCode, NullB errorMsg, NullB object) {
    WXMResponse *response = [[WXMResponse alloc] init];
    response.errorCode = errorCode;
    response.errorMsg = errorMsg;
    response.object = object;
    return response;
}

@interface WXMComponentService : NSObject <WXMComponentFeedBack>

/** 设置callback */
- (void)setServiceCallback:(ServiceCallBack)callback;

/** 释放当前Service */
- (void)closeCurrentService;

/** 回调 */
- (void)sendNext:(WXMResponse *)response;
@end
NS_ASSUME_NONNULL_END
