//
//  WQComponentHeader.h
//  ModulesProject
//
//  Created by wq on 2019/4/20.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMMessageContext.h"
#import "WXMComponentManager.h"
#import "WXMComponentRouter.h"
#import "WXMComponentAnnotation.h"
#import "WXMAllComponentProtocol.h"
#import "WXMComponentHeader.h"
#ifndef WQComponentHeader_h
#define WQComponentHeader_h

/** 存在data区字段 */
#define WXMKitSerName "WXMModuleClass"
#define WXMKitDATA(sectName) __attribute((used,section("__DATA,"#sectName" ")))

#define WXMService(procotol,impl) \
class FDLrpc;\
char * k##procotol##_ser \
WXMKitDATA(WXMModuleClass) = "{ \""#procotol"\" : \""#impl"\"}";

#define WXMCPManger [WXMComponentManager sharedInstance]
#define WXMCPRouter [WXMComponentRouter sharedInstance]

/** 消息传递协议 需要处理消息的遵循该协议  */
@protocol WXMComponentFeedBack <NSObject>
@optional

/**
 * module_event标准
 
 * WXMPhotoInterFaceProtocol(100)
 * WXMPhotoInterFaceProtocol(100,104,105)
 * WXMPhotoInterFaceProtocol(100-200)
 * WXMPhotoInterFaceProtocol(100-105,200)
 * WXMPhotoInterFaceProtocol(-)
 
 */
- (BOOL)cacheImplementer;
- (NSArray *)modules_events;
- (void)providedEventModule_event:(WXMMessageContext *)context;
@end
#endif /* WQComponentHeader_h */

