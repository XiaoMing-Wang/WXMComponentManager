//
//  WXMAllComponentProtocol.h
//  Multi-project-coordination
//
//  Created by wq on 2019/6/7.
//  Copyright © 2019年 wxm. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WXMComponentConfiguration.h"
@protocol WXMAllComponentProtocol <NSObject>

@end

static WXM_SIGNAL const WXM_MESSAGE_PHOTO_HEAD = @"WXM_MESSAGE_PHOTO_HEAD";
static WXM_SIGNAL const WXM_MESSAGE_PHOTO = @"WXM_MESSAGE_PHOTO";
@protocol WXMPhotoComponentProtocol <WXMServiceFeedBack>

@end

@protocol KVOViewControllerProcotol <WXMServiceFeedBack>

@end

@protocol WXMTestServiceProtocol <WXMServiceFeedBack>
- (void)haha;
@end
