//
//  WXMComponentDataObject.h
//  ModuleDebugging
//
//  Created by edz on 2019/7/7.
//  Copyright © 2019 wq. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WXMComponentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/** 路由传递参数对象 */
@interface WXMParameterObject : NSObject
@property (nonatomic, copy) NSDictionary *parameter;
@property (nonatomic, copy) RouterCallBack callback;
@end

/** 模块发送信号对象 */
@interface WXMSignalObject : NSObject
@property (nonatomic, copy) WXM_SIGNAL signalName;
@property (nonatomic, copy) NSDictionary *parameter;
@property (nonatomic, copy) RouterCallBack callback;
@end

/** 监听者对象 */
@interface WXMListenObject : NSObject
@property (nonatomic, copy) NSString *listenKey;
@property (nonatomic, copy) RouterCallBack callback;
@end

NS_ASSUME_NONNULL_END
