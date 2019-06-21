//
//  WQComponentHeader.h
//  ModulesProject
//
//  Created by wq on 2019/4/20.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMParameterContext.h"
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

/**  WXMPhotoInterFaceProtocol(100)
     WXMPhotoInterFaceProtocol(100,104,105)
     WXMPhotoInterFaceProtocol(100-200)
     WXMPhotoInterFaceProtocol(100-105,200)
     WXMPhotoInterFaceProtocol(-) */
/** 模块交互协议需要处理消息的遵循该协议  */
@protocol WXMComponentFeedBack <NSObject>
@optional

/** 是否缓存当前类对象 noti:controller会被导航控制器强引用能够接收到消息 而NSObject则会被释放掉 */
- (BOOL)wc_cacheImplementer;

/** 消息接受类型指定和消息接受 */
- (NSArray *)wc_modules_events;

/** 接收初始化接收的参数 */
- (void)wc_receiveParameters:(WXMParameterContext *)parameterContext;

/** 接收其他模块发出的消息 */
- (void)wc_receivesMessageWithEventModule:(WXMMessageContext *)eventContext;

@end

#endif

