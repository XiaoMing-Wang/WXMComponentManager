//
//  WQComponentHeader.h
//  ModulesProject
//
//  Created by wq on 2019/4/20.
//  Copyright © 2019年 wq. All rights reserved.

#define WXMRouterInstance [WXMComponentRouter sharedInstance]
#define WXMMangerInstance [WXMComponentManager sharedInstance]
#define WXMContextObserve(target,signal) WXMComponentContext.observe(target,signal)
#define WXMContextParameter(target) WXMComponentContext.parameter(target)
#define WXMContextCallBackForward(target,parameter)\
WXMComponentContext.callBackForward(target,parameter)

#import "WXMComponentRouter.h"
#import "WXMComponentContext.h"
#import "WXMComponentManager.h"
#import "WXMComponentData.h"
#import "WXMComponentAnnotation.h"
#import "WXMComponentConfiguration.h"
#import "WXMAllComponentProtocol.h"


