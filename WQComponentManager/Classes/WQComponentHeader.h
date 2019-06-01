//
//  WQComponentHeader.h
//  ModulesProject
//
//  Created by wq on 2019/4/20.
//  Copyright © 2019年 wq. All rights reserved.
//
/** 存在data区字段 */
#define WXMKitSerName "WXMModuleClass"
#define WXMKitDATA(sectName) __attribute((used,section("__DATA,"#sectName" ")))
#define WXMService(procotol,impl) \
class FDLrpc;\
char * k##procotol##_ser WXMKitDATA(WXMModuleClass) = "{ \""#procotol"\" : \""#impl"\"}";

#define WXMCPManger [WQComponentManager sharedInstance]
#define WXMCPRouter [WQComponentRouter sharedInstance]
#ifndef WQComponentHeader_h
#define WQComponentHeader_h

#import "WQComponentManager.h"
#import "WQComponentRouter.h"
#import "WQComponentAnnotation.h"

/** 消息传递协议 需要处理回调的遵循该协议即可  */
@protocol WQComponentFeedBack <NSObject>
@optional

/**
 module_event标准
 WXMPhotoInterFaceProtocol(100)
 WXMPhotoInterFaceProtocol(100,104,105)
 WXMPhotoInterFaceProtocol(100-200)
 WXMPhotoInterFaceProtocol(100-105,200)
 WXMPhotoInterFaceProtocol(-)
*/
/** 接收的某个module某个event的消息 不实现全部接收 */
+ (NSArray *)modules_events;
+ (void)providedEventModule_event:(NSString *)module_event eventObj:(id)eventObj;
@end


#endif /* WQComponentHeader_h */
