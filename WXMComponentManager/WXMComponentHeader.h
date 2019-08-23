//
//  WQComponentHeader.h
//  ModulesProject
//
//  Created by wq on 2019/4/20.
//  Copyright © 2019年 wq. All rights reserved.

#define WXMRouterInstance [WXMComponentRouter sharedInstance]
#define WXMMangerInstance [WXMComponentManager sharedInstance]
#define WXMBridgeParameter(target) WXMComponentBridge.parameter(target)
#define WXMBridgeObserve(target, signal) WXMComponentBridge.observe(target, signal)
#define WXMBridgeSendSignal(signal, parameter) WXMComponentBridge.sendSignal(signal, parameter)

#define WXMBridgeCallBack(target, parameter) \
WXMComponentBridge.callBackForward(target, parameter)

#define WXMCreateServiceWithProtocol(protocols) \
\
Protocol *protocolSEL = @protocol(protocols); \
\
id <protocols>service = [WXMMangerInstance serviceProvideForProtocol:protocolSEL];


#import "WXMComponentBridge.h"
#import "WXMComponentRouter.h"
#import "WXMComponentManager.h"
#import "WXMComponentContext.h"

#import "WXMComponentData.h"
#import "WXMComponentAnnotation.h"
#import "WXMComponentConfiguration.h"

#import "WXMAllComponentProtocol.h"


