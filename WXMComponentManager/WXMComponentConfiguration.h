//
//  WXMComponentConfiguration.h
//  ModuleDebugging
//
//  Created by edz on 2019/7/7.
//  Copyright © 2019 wq. All rights reserved.
//
#define WXM_SIGNAL_KEY @"__WXM_SIGNAL_KEY"
#define WXM_SIGNAL_CALLBACK @"__WXM_SIGNAL_CALLBACK"

#define WXMDEBUG DEBUG
#define WXMPreventCrashBegin  @try {
#define WXMPreventCrashEnd     } @catch (NSException *exception) {} @finally {}
#ifndef WXMComponentConfiguration_h
#define WXMComponentConfiguration_h
NS_ASSUME_NONNULL_BEGIN

@class WXMParameterObject;
@class WXMSignal;
@class WXMResponse;

/** 存在data区字段 */
#define WXMKitSerName "WXMModuleClass"
#define WXMKitDATA(sectName) __attribute((used,section("__DATA, "#sectName" ")))

/** 使用该宏注册协议 */
#define WXMKitService(serviceInstance, procotol) \
class WXMComponentRouter;\
char * k##procotol##_ser \
WXMKitDATA(WXMModuleClass) = "{ \""#procotol"\" : \""#serviceInstance"\" }";

/** 信号枚举类型 */
typedef NSString *WXM_SIGNAL NS_STRING_ENUM;
typedef void (^SignalCallBack) (id params);
typedef void (^ObserveCallBack) (WXMSignal *signal);
typedef void (^ServiceCallBack) (WXMResponse *response);
typedef NS_ENUM(NSUInteger, WXMRouterType) {
    WXMRouterType_component = 0, /** viewcontroller */
    WXMRouterType_push,          /** push */
    WXMRouterType_present,       /** present */
    WXMRouterType_parameter,     /** 传参 */
    WXMRouterType_signal,        /** 模块数据交互 */
};

/** 模块交互协议需要处理消息的遵循该协议  */
@protocol WXMComponentFeedBack <NSObject>
@optional

/** 是否缓存当前类对象 noti:controller会被导航控制器强引用能够接收到消息 而NSObject则会被释放掉 */
- (BOOL)wc_cacheImplementer;

/** 接收信号类型 */
- (nullable NSArray <WXM_SIGNAL>*)wc_signals;

/** 接收初始化接收的参数 */
- (void)wc_receiveParameters:(WXMParameterObject *)obj;

/** 接收其他模块发出的消息 */
- (void)wc_receivesSignalObject:(WXMSignal *)obj;

@end

@protocol WXMServiceFeedBack <NSObject>

/** 设置callback */
- (void)setServiceCallback:(ServiceCallBack)callback;

/** 释放当前Service */
- (void)closeCurrentService;

/** 回调 */
- (void)sendNext:(WXMResponse *)response;

@end
NS_ASSUME_NONNULL_END
#endif /* WXMComponentConfiguration_h */
