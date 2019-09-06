//
//  WXMComponentConfiguration.h
//  ModuleDebugging
//
//  Created by edz on 2019/7/7.
//  Copyright © 2019 wq. All rights reserved.
//
NS_ASSUME_NONNULL_BEGIN
@class WXMSignal;
@class WXMComponentError;
@class WXMParameterObject;
@class WXMComponentService;

#define WXM_COMPONENT @"component"
#define WXM_SIGNAL_KEY @"__WXM_SIGNAL_KEY"
#define WXM_SIGNAL_CALLBACK @"__WXM_SIGNAL_CALLBACK"
#define WXM_REMOVE_CALLBACK @"__WXM_REMOVE_CALLBACK"

#define WXMDEBUG DEBUG
#define WXMPreventCrashBegin  @try {
#define WXMPreventCrashEnd     } @catch (NSException *exception) {} @finally {}
#ifndef WXMComponentConfiguration_h
#define WXMComponentConfiguration_h

/** 存在data区字段 */
#define WXMKitSerName "WXMModuleClass"
#define WXMKitDATA(sectName) __attribute((used, section("__DATA, "#sectName" ")))

/** 使用该宏注册协议 */
#define WXMKitService(serviceInstance, procotol) \
class WXMComponentRouter;\
char * k##procotol##_ser \
WXMKitDATA(WXMModuleClass) = "{ \""#procotol"\" : \""#serviceInstance"\" }";

/** 路由类型 */
typedef NSString *WXM_SIGNAL NS_STRING_ENUM;
typedef void (^SignalCallBack) (id params);
typedef void (^ObserveCallBack) (WXMSignal *signal);
typedef void (^ServiceCallBack) (WXMComponentError *response);
typedef void (^FreeServiceCallBack) (WXMComponentService *service);
typedef NS_ENUM(NSUInteger, WXMRouterType) {
    WXMRouterType_component = 0, /** viewcontroller */
    WXMRouterType_push,          /** push */
    WXMRouterType_present,       /** present */
    WXMRouterType_parameter,     /** 传参 */
};

/** 模块交互协议需要处理消息的遵循该协议  */
@protocol WXMComponentFeedBack <NSObject>
@optional
- (BOOL)wc_cacheImplementer;
- (nullable NSArray <WXM_SIGNAL>*)wc_signals;
- (void)wc_receiveParameters:(WXMParameterObject * _Nullable)obj;
- (void)wc_receivesSignalObject:(WXMSignal * _Nullable)obj;
@end

/** Service协议 */
@protocol WXMServiceFeedBack <NSObject>
- (nullable WXMComponentError *)cacheDataSource;
- (void)setServiceCallback:(ServiceCallBack)callback;
- (void)sendNext:(WXMComponentError * _Nullable)response;
@end

#endif /* WXMComponentConfiguration_h */

NS_ASSUME_NONNULL_END
