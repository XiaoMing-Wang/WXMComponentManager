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

/** 模块发送信号对象 */
@interface WXMSignal : NSObject
@property (nonatomic, copy) WXM_SIGNAL signal;
@property (nonatomic, strong) id object;
- (void)sendNext:(id)parameter;
@end

/** 监听者对象 */
@interface WXMListenObject : NSObject
@property (nonatomic, copy) WXM_SIGNAL signal;
@property (nonatomic, copy) ObserveCallBack callback;
@end

NS_ASSUME_NONNULL_END
