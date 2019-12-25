//
//  WXMMediatorData.h
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WXMMediatorConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/** 信号对象 */
@interface WXMMediatorSignal : NSObject
@property (nonatomic, copy) WXM_MEDIATOR_SIGNAL signal;
@property (nonatomic, strong) id object;
- (void)sendNext:(id)parameter;
@end

/** 监听者对象 */
@interface WXMMediatorListen : NSObject
@property (nonatomic, copy) WXM_MEDIATOR_SIGNAL signal;
@property (nonatomic, copy) WXMObserveCallBack callback;
@end

NS_ASSUME_NONNULL_END
