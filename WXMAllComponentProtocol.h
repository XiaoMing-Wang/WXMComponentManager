////
////  WXMAllComponentProtocol.h
////  Multi-project-coordination
////
////  Created by wq on 2019/6/7.
////  Copyright © 2019年 wxm. All rights reserved.
////
#import <Foundation/Foundation.h>
#import "WXMComponentHeader.h"
//@protocol WXMAllComponentProtocol <NSObject>
//
//@end
//
//__WCSIGNAL__(WXM_MESSAGE_PHOTO_HEAD, @"发送图片回调通知");
//__WCSIGNAL__(WXM_MESSAGE_PHOTO_HEAD1, @"发送图片回调通知");
//__WCSIGNAL__(WXM_MESSAGE_PHOTO_HEAD2, @"发送图片回调通知");
//__WCSIGNAL__(WXM_MESSAGE_PHOTO_HEAD3, @"发送图片回调通知");
//__WCSIGNAL__(WXM_MESSAGE_PHOTO_HEAD4_COLD, @"发送图片回调通知");
//
@protocol WXMTestServiceProtocol <WXMServiceFeedBack>
- (void)hahaServiceProtocol:(NSString *)aString;
- (void)heihei:(void (^)(void))block;
@end
