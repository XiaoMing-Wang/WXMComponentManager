//
//  WXMComponentConfiguration.h
//  ModuleDebugging
//
//  Created by edz on 2019/7/7.
//  Copyright © 2019 wq. All rights reserved.
//

#ifndef WXMComponentConfiguration_h
#define WXMComponentConfiguration_h
NS_ASSUME_NONNULL_BEGIN

@class WXMParameterObject;
@class WXMSignalObject;

/** 存在data区字段 */
#define WXMDEBUG DEBUG
#define WXMKitSerName "WXMModuleClass"
#define WXMKitDATA(sectName) __attribute((used,section("__DATA,"#sectName" ")))

/** 使用该宏注册协议 */
#define WXMService(procotol,impl) \
class WXMComponentRouter;\
char * k##procotol##_ser \
WXMKitDATA(WXMModuleClass) = "{ \""#procotol"\" : \""#impl"\"}";

/** 信号枚举类型 */
typedef NSString *WXM_SIGNAL NS_STRING_ENUM;
typedef void (^RouterCallBack)(NSDictionary * _Nullable params);
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
- (void)wc_receivesSignalObject:(WXMSignalObject *)obj;

@end

NS_ASSUME_NONNULL_END
#endif /* WXMComponentConfiguration_h */
