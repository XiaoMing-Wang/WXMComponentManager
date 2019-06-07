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

/** 发送者 */
@property (nonatomic, strong) NSString *module;

/** 事件类型 */
@property (nonatomic, assign) NSInteger event;

/** 发送的数据 */
@property (nonatomic, strong) id obj;

@end

