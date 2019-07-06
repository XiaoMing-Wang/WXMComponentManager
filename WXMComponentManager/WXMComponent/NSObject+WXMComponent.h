//
//  NSObject+WXMComponent.h
//  ModuleDebugging
//
//  Created by edz on 2019/7/6.
//  Copyright © 2019 wq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RouterCallBack)(NSDictionary *_Nullable);
@interface NSObject (WXMComponent)

- (instancetype (^)(NSString *))observeKey;

- (void)wxm_subscribeNext:(RouterCallBack)callback;

@end

NS_ASSUME_NONNULL_END
