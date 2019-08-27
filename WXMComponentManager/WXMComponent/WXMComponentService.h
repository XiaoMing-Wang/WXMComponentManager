//
//  WXMBaseService.h
//  ModuleDebugging
//
//  Created by edz on 2019/8/23.
//  Copyright © 2019 wq. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WXMComponentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMComponentService : NSObject <WXMServiceFeedBack>
@property (nonatomic, copy, readonly) NSString *privateKey;
@end

NS_ASSUME_NONNULL_END
