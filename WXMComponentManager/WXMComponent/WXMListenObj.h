//
//  WXMMessageCallbackObj.h
//  ModuleDebugging
//
//  Created by edz on 2019/7/6.
//  Copyright © 2019 wq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RouterCallBack)(NSDictionary *);
@interface WXMListenObj : NSObject

/** 监听的key */
@property (nonatomic, copy) NSString *listen;

/** 回调 */
@property (nonatomic, strong) RouterCallBack callBack;

@end

NS_ASSUME_NONNULL_END
