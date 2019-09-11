//
//  WQComponentHeader.h
//  ModulesProject
//
//  Created by wq on 2019/4/20.
//  Copyright © 2019年 wq. All rights reserved.
#define weakifyself autoreleasepool {} __weak typeof(self) weakself = self;
#define strongifyself autoreleasepool {} __strong __typeof(weakself) self = weakself;

#define WCRouterInstance [WXMComponentRouter sharedInstance]
#define WCMangerInstance [WXMComponentManager sharedInstance]
#define WCSeiviceInstance [WXMComponentServiceManager sharedInstance]

/** A-B界面获取参数和回调 */
#define WCBridgeParameter(target) WXMComponentBridge.parameter(target)
#define WCBridgeCallBack(target, parameter) WXMComponentBridge.callBackForward(target, parameter)

/** 信号 */
#define WCBridgeObserve(target, signal) WXMComponentBridge.observe(target, signal)
#define WCBridgeSendSignal(signal, parameter) WXMComponentBridge.sendSignal(signal, parameter)

/** Service */
#define WCService(protocols) \
[[WXMComponentServiceManager sharedInstance] serviceProvide:@protocol(protocols) depend:self]

#define WCServiceUnique(protocols) \
[[WXMComponentServiceManager sharedInstance] serviceCacheProvide:@protocol(protocols)]

#define WCError(code, message, object) [WXMComponentError error:code message:message object:object];

#import "WXMComponentBridge.h"
#import "WXMComponentRouter.h"
#import "WXMComponentManager.h"
#import "WXMComponentContext.h"

#import "WXMComponentError.h"
#import "WXMComponentData.h"
#import "WXMComponentAnnotation.h"
#import "WXMComponentConfiguration.h"
#import "WXMAllComponentProtocol.h"
#import "WXMComponentService.h"
#import "WXMComponentServiceManager.h"

