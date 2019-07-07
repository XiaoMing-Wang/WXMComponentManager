//
//  WXMComponentContext.m
//  ModuleDebugging
//
//  Created by edz on 2019/7/7.
//  Copyright © 2019 wq. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMComponentContext.h"
#import "WXMComponentData.h"

static char parameterKey;
static char callbackKey;
static char signalArrayKey;

@interface WXMComponentContext ()
@property (nonatomic, weak) id currentTarget;
@property (nonatomic, copy) WXM_SIGNAL currentSignal;
@property (nonatomic, strong) NSLock *listenLock;
@end

@implementation WXMComponentContext

+ (void)handleParametersWithTarget:(id<WXMComponentFeedBack>)target parameters:(id)parameter {
    if (!target || !parameter) return;
    
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
    WXMParameterObject *parameterObject = [WXMParameterObject new];
    BOOL isDictionary = [parameter isKindOfClass:NSDictionary.class];
    if (isDictionary) {
        parameterObject.parameter = (NSDictionary *) parameter;
        objc_setAssociatedObject(target, &parameterKey, parameter, policy);
    } else {
        parameterObject.callback = (RouterCallBack) parameter;
        objc_setAssociatedObject(target, &callbackKey, parameter, policy);
    }
    
    /** 代理回调 */
    if ([target respondsToSelector:@selector(wc_receiveParameters:)]) {
        [target wc_receiveParameters:parameterObject];
    }
}

/** 处理信号 */
+ (void)handleSignalWithTarget:(id)target signalObject:(WXMSignalObject *)signalObject {
    NSArray <WXMListenObject *>*listens = objc_getAssociatedObject(target, &signalArrayKey);
    if (!listens || listens.count == 0) return;
    for (WXMListenObject *obj in listens) {
        if ([obj.listenKey isEqualToString:signalObject.signalName]) {
            if (obj.callback) obj.callback(signalObject.parameter);
        }
    }
}

/** 获取路由传递下来的参数 */
+ (NSDictionary *(^)(id obj))parameter {
    return ^NSDictionary *(id obj) {
        return objc_getAssociatedObject(obj, &parameterKey);
    };
}

/** 路由调用时的回调 */
+ (void (^)(id target, NSDictionary *_Nullable parameter))callBackForward {
    return ^(id target, NSDictionary *parameter) {
        RouterCallBack callback = objc_getAssociatedObject(target, &callbackKey);
        if (callback) callback(parameter);
    };
}

/** 收到信号时的回调 */
/** 组件间信号数量很多不适合用这种方式直接回调 需要保存太多block */
//+ (void (^)(id target, NSDictionary* _Nullable parameter))callBackSignal { }

/** 获取一个WXMComponentContext对象 */
+ (WXMComponentContext *(^)(id target, WXM_SIGNAL signal))observe {
    return ^WXMComponentContext *(id target, WXM_SIGNAL signal) {
        WXMComponentContext *context = [WXMComponentContext new];
        context.currentTarget = target;
        context.currentSignal = signal;
        return context;
    };
}

/** callback */
- (void)subscribeNext:(RouterCallBack)callback {
    if (!self.currentTarget || !self.currentSignal) return;
    
    [self.listenLock lock];
    WXMListenObject *listenObject = [WXMListenObject new];
    listenObject.listenKey = self.currentSignal;
    listenObject.callback = callback;
    
    NSArray *listens = objc_getAssociatedObject(self.currentTarget, &signalArrayKey);
    NSMutableArray *arrayMutable = listens ? listens.mutableCopy : @[].mutableCopy;
    [arrayMutable addObject:listenObject];
    objc_setAssociatedObject(self.currentTarget, &signalArrayKey, arrayMutable, 1);
    [self.listenLock unlock];
}

#pragma mark GET

- (NSLock *)listenLock {
    if (!_listenLock) _listenLock = [[NSLock alloc] init];
    return _listenLock;
}

@end
