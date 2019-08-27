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

#define WCService(protocols) \
[WXMComponentServiceHelp serviceProvide:@protocol(protocols) depend:self]

#define WCRemoveServiceKey(key) \
[WXMComponentServiceHelp removePrivateKey:key depend:self];

#define WCServiceForKey(privateKey) \
[WXMComponentServiceHelp serviceforPrivateKey:privateKey depend:self];

#define WCResponse(code, message, object) \
[WXMResponse response:code errorMsg:message object:object];

#import "WXMComponentBridge.h"
#import "WXMComponentRouter.h"
#import "WXMComponentManager.h"
#import "WXMComponentContext.h"

#import "WXMComponentData.h"
#import "WXMComponentAnnotation.h"
#import "WXMComponentConfiguration.h"
#import "WXMAllComponentProtocol.h"
#import "WXMComponentServiceHelp.h"

