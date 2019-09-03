//
//  WQComponentHeader.h
//  ModulesProject
//
//  Created by wq on 2019/4/20.
//  Copyright © 2019年 wq. All rights reserved.
#define weakifyself autoreleasepool {} __weak typeof(self) weakself = self;
#define strongifyself autoreleasepool {} __strong __typeof(weakself) self = weakself;


#define WXMRouterInstance [WXMComponentRouter sharedInstance]
#define WXMMangerInstance [WXMComponentManager sharedInstance]
#define WXMBridgeParameter(target) WXMComponentBridge.parameter(target)
#define WXMBridgeObserve(target, signal) WXMComponentBridge.observe(target, signal)
#define WXMBridgeSendSignal(signal, parameter) WXMComponentBridge.sendSignal(signal, parameter)

#define WXMBridgeCallBack(target, parameter) \
WXMComponentBridge.callBackForward(target, parameter)

#define WCService(protocols) \
[[WXMComponentServiceManager sharedInstance] serviceProvide:@protocol(protocols) depend:self]

#define WCError(code, message, object) \
[WXMComponentError error:code message:message object:object];

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

