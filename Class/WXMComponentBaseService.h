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

@interface WXMComponentBaseService : NSObject
@property (nonatomic, assign, readwrite) BOOL accessCache;
- (nullable WXMComponentError *)cacheComponentError;
- (void)sendNext:(WXMComponentError *_Nullable)response;
@end

NS_ASSUME_NONNULL_END

