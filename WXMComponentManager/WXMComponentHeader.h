//
//  WQComponentHeader.h
//  ModulesProject
//
//  Created by wq on 2019/4/20.
//  Copyright © 2019年 wq. All rights reserved.

#define WXMRouterInstance [WXMComponentRouter sharedInstance]
#define WXMMangerInstance [WXMComponentManager sharedInstance]

#define WXMBridgeObserve(target, signal) WXMComponentBridge.observe(target, signal)
#define WXMBridgeSignal(signal, parameter) WXMComponentBridge.sendSignal(signal, parameter)

#define WXMBridgeParameter(target) WXMComponentBridge.parameter(target)
#define WXMBridgeCallBackForward(target,parameter) \
WXMComponentBridge.parameter.callBackForward(target,parameter)

#import "WXMComponentBridge.h"
#import "WXMComponentRouter.h"
#import "WXMComponentManager.h"
#import "WXMComponentBridgeContext.h"

#import "WXMComponentData.h"
#import "WXMComponentAnnotation.h"
#import "WXMComponentConfiguration.h"

#import "WXMAllComponentProtocol.h"


