//
//  WXMBaseService.h
//  ModuleDebugging
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 wq. All rights reserved.
//
#import "WXMComponentError.h"
#import <Foundation/Foundation.h>
#import "WXMComponentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMComponentService : NSObject 

/** 是否优先返回缓存 */
@property (nonatomic, assign) BOOL accessCache;

@end

NS_ASSUME_NONNULL_END
