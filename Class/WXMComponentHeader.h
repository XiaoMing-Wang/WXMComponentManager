//
//  WQComponentHeader.h
//  ModulesProject
//
//  Created by wq on 2019/4/20.
//  Copyright © 2019年 wq. All rights reserved.

/** 使用该宏注册协议 */
#define WCKitService(serviceInstance, procotol) \
class NSObject; \
char *k##procotol##_ser \
WXMKitDATA(WXMModuleClass) = "{ \""#procotol"\" : \""#serviceInstance"\" }";

/** 定义信号 */
#define WCSIGNAL_DEFINE(signal, describe) \
class NSObject; \
static WXM_SIGNAL const signal = (@#signal);

/** 单例 */
#define WCRouterInstance  [WXMComponentRouter sharedInstance]
#define WCMangerInstance  [WXMComponentManager sharedInstance]
#define WCSeiviceInstance [WXMComponentServiceHelp sharedInstance]

/** 信号 */
#define WCBridgeObserve(target, signal) WXMComponentBridge.observe(target, signal)
#define WCBridgeSendSignal(signal, parameter) WXMComponentBridge.sendSignal(signal, parameter)

/** Service */
#define WCService(aString) [WCSeiviceInstance serviceProvide:@protocol(aString) depend:self];

/** Error */
#define WCError(code, msg, obj) [WXMComponentError error:code message:msg object:obj];

#import "WXMComponentBridge.h"
#import "WXMComponentRouter.h"
#import "WXMComponentManager.h"
#import "WXMComponentContext.h"

#import "WXMComponentData.h"
#import "WXMComponentAnnotation.h"
#import "WXMComponentConfiguration.h"
#import "WXMComponentBaseService.h"
#import "WXMComponentServiceHelp.h"

//#import "WXMAllComponentProtocol.h"

