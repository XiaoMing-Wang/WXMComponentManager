//
//  WXMMessageContext.h
//  Multi-project-coordination
//
//  Created by wq on 2019/6/7.
//  Copyright © 2019年 wxm. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface WXMMessageContext : NSObject

typedef void (^RouterCallBack)(NSDictionary *);

/** 发送者 */
@property (nonatomic, strong) NSString *module;

/** 事件类型 */
@property (nonatomic, assign) NSInteger event;

/** 传递的参数 */
@property (nonatomic, strong) NSDictionary *parameter;

/** 回调 */
@property (nonatomic, strong) RouterCallBack callBack;

@end

