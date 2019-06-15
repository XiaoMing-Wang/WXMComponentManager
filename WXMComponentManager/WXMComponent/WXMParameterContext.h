//
//  WXMParameterContext.h
//  Multi-project-coordination
//
//  Created by wq on 2019/6/15.
//  Copyright © 2019年 wxm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXMParameterContext : NSObject

typedef void (^RouterCallBack)(NSDictionary *);

/** 传递的参数 */
@property (nonatomic, strong) NSDictionary *parameter;

/** 回调 */
@property (nonatomic, strong) RouterCallBack callBack;

@end
