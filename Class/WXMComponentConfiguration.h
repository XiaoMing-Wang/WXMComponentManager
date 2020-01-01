//
//  WXMComponentConfiguration.h
//  ModuleDebugging
//
//  Created by edz on 2019/7/7.
//  Copyright © 2019 wq. All rights reserved.
//
@class WXMSignal;
@class WXMComponentError;
@class WXMParameterObject;
@class WXMComponentBaseService;

#define WXM_COMPONENT @"component"
#define WXM_SIGNAL_KEY @"__WXM_SIGNAL_KEY"
#define WXM_SIGNAL_CALLBACK @"__WXM_SIGNAL_CALLBACK"
#define WXM_REMOVE_CALLBACK @"__WXM_REMOVE_CALLBACK"

#define WXMDEBUG 0
#define WXMPreventCrashBegin  @try {
#define WXMPreventCrashEnd     } @catch (NSException *exception) {} @finally {}
#ifndef WXMComponentConfiguration_h
#define WXMComponentConfiguration_h

/** 存在data区字段 */
#define WXMKitSerName "WXMModuleClass"
#define WXMKitDATA(sectName) __attribute((used, section("__DATA, "#sectName" ")))

/** 路由类型 */
typedef NSString *WXM_SIGNAL NS_STRING_ENUM;
typedef void (^SignalCallBack) (id params);
typedef void (^ObserveCallBack) (WXMSignal *signal);
typedef void (^ServiceCallBack) (WXMComponentError *response);
typedef void (^FreeServiceCallBack) (WXMComponentBaseService *service);
typedef NS_ENUM(NSUInteger, WCRouterType) {
    WCRouterType_component = 0, /** viewcontroller */
    WCRouterType_push,          /** push */
    WCRouterType_present,       /** present */
    WCRouterType_parameter,     /** 传参 */
};

/** Service协议 */
@protocol WXMServiceFeedBack <NSObject>
@optional
@property (nonatomic, assign) BOOL accessCache;
- (void)setServiceCallback:(ServiceCallBack _Nonnull)callback;
@end

#endif /* WXMComponentConfiguration_h */

