//
//  WQComponentConfiguration.h
//  ModulesProject
//
//  Created by edz on 2019/4/26.
//  Copyright © 2019年 wq. All rights reserved.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
#ifndef WQComponentConfiguration_h
#define WQComponentConfiguration_h

/** 消息传递协议 需要处理回调的需要遵循该协议  */
@protocol WQComponentFeedBack <NSObject>
@optional
/** 接收频段 不实现全部接收 */
+ (NSArray *)events;
/** 事件派发 不实现不发送 */
+ (void)providedType:(NSString *)types event:(id)event;
@end

/** WXMService注册服务 service协议 impl协议实现类 */
#define WXMKitSerName "WXMModuleClass"
#define WXMKitDATA(sectName) __attribute((used,section("__DATA,"#sectName" ")))
#define WXMService(service,impl) \
class FDLrpc; char * k##service##_ser WXMKitDATA(WXMModuleClass) = "{ \""#service"\" : \""#impl"\"}";

/** 单例 runtime类 */
#define WQComponentRouterClass @"WQComponentRouter"
#define WQComponentManagerClass @"WQComponentManager"
#define WQSingleton @"sharedInstance"


/** 调用协议方法 */
static inline void WQComponentRouterUrlWithObj(NSString * url, id obj) {
    Class classManager = NSClassFromString(WQComponentRouterClass);
    SEL sharedInstance = NSSelectorFromString(WQSingleton);
    if (![classManager respondsToSelector:sharedInstance]) return;
    id wqComponentRouter = [classManager performSelector:sharedInstance];
    if (wqComponentRouter == nil) return;

    NSString * actionString = nil;
    if (obj == nil) actionString = @"openUrl:";
    if (obj != nil) actionString = @"openUrl:feedback:";
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]]) {
        actionString = @"openUrl:params:";
    }
    
    SEL sel = NSSelectorFromString(actionString);
    if (!sel) return;
    if ([wqComponentRouter respondsToSelector:sel]) {
        [wqComponentRouter performSelector:sel withObject:url withObject: obj ?: nil];
    }
}

/** 发送消息 */
static inline void WQSendEventWithObj(NSString * eventType, id obj) {
    Class classManager = NSClassFromString(WQComponentManagerClass);
    SEL sharedInstance = NSSelectorFromString(WQSingleton);
    if (![classManager respondsToSelector:sharedInstance]) return;
    id wqComponentRouter = [classManager performSelector:sharedInstance];
    if (wqComponentRouter == nil) return;
    
    NSString * actionString = @"sendEventType:eventObj:";
    SEL sel = NSSelectorFromString(actionString);
    if (!sel) return;
    if ([wqComponentRouter respondsToSelector:sel]) {
        [wqComponentRouter performSelector:sel withObject:eventType withObject:obj];
    }
}

#pragma clang diagnostic pop
#endif /* WQComponentConfiguration_h */
