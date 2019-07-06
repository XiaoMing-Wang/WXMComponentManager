//
//  WQComponentRouter.m
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.

#import <objc/runtime.h>
#import "WXMComponentRouter.h"
#import "WXMComponentHeader.h"
#import "WXMParameterContext.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"

typedef NS_ENUM(NSUInteger, WXMComponentRouterType) {
    WXMRouterTypeWhether = 0,
    WXMRouterTypeParameter = 1,
    WXMRouterTypeJump = 2,
};

static char parameterKey;
static char callbackKey;
@implementation WXMComponentRouter

+ (instancetype)sharedInstance {
    static WXMComponentRouter *_router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _router = [[self alloc] init];
    });
    return _router;
}

/** 是否可以打开 */
- (BOOL)canOpenUrl:(NSString * _Nonnull)url {
    id results = [self openUrl:url passObj:nil routerType:WXMRouterTypeWhether];
    if ([results boolValue] && results != nil) return YES;
    return NO;
}

/** 直接打开url */
- (void)openUrl:(NSString *)url {
    [self openUrl:url passObj:nil routerType:WXMRouterTypeJump];
}
- (void)openUrl:(NSString *)url params:(NSDictionary *_Nullable)params {
    [self openUrl:url passObj:params routerType:WXMRouterTypeJump];
}
- (void)openUrl:(NSString *)url callBack:(RouterCallBack _Nullable)callBack {
    [self openUrl:url passObj:callBack routerType:WXMRouterTypeJump];
}

/** 返回结果(模块实现类实现协议方法) */
- (id)resultsOpenUrl:(NSString *)url {
    return [self openUrl:url passObj:nil routerType:WXMRouterTypeParameter];
}
- (id)resultsOpenUrl:(NSString *)url params:(NSDictionary *_Nullable)params {
    return [self openUrl:url passObj:params routerType:WXMRouterTypeParameter];
}
- (id)resultsOpenUrl:(NSString *)url callBack:(RouterCallBack _Nullable)callBack {
    return [self openUrl:url passObj:callBack routerType:WXMRouterTypeParameter];
}

/** controller作为实现协议对象 */
- (UIViewController *)viewControllerWithUrl:(NSString *)url {
    return [self viewControllerWithUrl:url obj:nil];
}
- (UIViewController *)viewControllerWithUrl:(NSString *)url params:(NSDictionary *_Nullable)params {
    return [self viewControllerWithUrl:url obj:params];
}
- (UIViewController *)viewControllerWithUrl:(NSString *)url callBack:(RouterCallBack)callBack {
    return [self viewControllerWithUrl:url obj:callBack];
}

/** 发送消息 */
- (void)sendMessageWithUrl:(NSString *)url {
    [self sendMessageWithUrl:url event_id:nil];
}
- (void)sendMessageWithUrl:(NSString *)url params:(NSDictionary *_Nullable)params {
    [self sendMessageWithUrl:url event_id:params];
}
- (void)sendMessageWithUrl:(NSString *)url callBack:(RouterCallBack)callBack {
    [self sendMessageWithUrl:url event_id:callBack];
}

/** 根判断1 */
- (id)openUrl:(NSString *)url passObj:(id)passObj routerType:(WXMComponentRouterType)routerType {
    @try {

        NSURL *urlUrl = [NSURL URLWithString:url];
        NSString *scheme = urlUrl.scheme;             /** 操作类型 */
        NSString *host = urlUrl.host;                 /** 第一路径 */
        NSString *relativePath = urlUrl.relativePath; /** 第二路径 */
        NSString *query = urlUrl.query;               /** 参数 */
        if (!relativePath || !urlUrl || !host || !scheme) {
            NSLog(@"不是正确的url");
            return nil;
        }
        
        /** 剪切参数获取字符串 */
        NSString *protocol = [self protocol:host];
        NSString *action = [self action:relativePath];
        if (!protocol || !action) {
            NSLog(@"url解析不出protocol或action");
            return nil;
        }
        
        /** 判断传递参数是什么类型 */
        id parameter = nil;
        if (passObj == nil) {
            parameter = [self paramsWithString:query];
        } else if (passObj != nil && [passObj isKindOfClass:[NSDictionary class]]) {
            parameter = passObj;
        } else {
            /** block */
            parameter = passObj;
        }
        
        /** 获取service */
        Protocol *pro = NSProtocolFromString(protocol);
        id service = [[WXMComponentManager sharedInstance] serviceProvideForProtocol:pro];
        SEL sel = NSSelectorFromString(action);
        SEL selSuffix = NSSelectorFromString([action stringByAppendingString:@":"]);
        SEL selReal = [service respondsToSelector:sel] ? sel : selSuffix;
        if (!service || !selReal || ![service respondsToSelector:selReal]) {
           if (!service) NSLog(@"无法生成service类");
           if (!selReal) NSLog(@"无法生成action函数");
           if (![service respondsToSelector:selReal]) NSLog(@"service无法无法响应这个函数");
            return nil;
        }
        
        NSLog(@"成功调用");
        id __target = nil;
        if (routerType == WXMRouterTypeWhether) {
            return @(YES);
        } else if (routerType == WXMRouterTypeParameter)  {
            __target = [service performSelector:selReal withObject:parameter];
            [self handleParametersWithTarget:__target parameters:parameter];
        } else if (routerType == WXMRouterTypeJump) {
            UIViewController <WXMComponentFeedBack>* vc = nil;
            vc = [service performSelector:selReal withObject:parameter];
            [self handleParametersWithTarget:vc parameters:parameter];
            [self jumpViewController:vc scheme:scheme];
        }
        
        return __target;
    } @catch (NSException *exception) { NSLog(@"openUrl判断崩溃 !!!!!!!"); } @finally {}
}

/** 处理target参数 */
- (void)handleParametersWithTarget:(id<WXMComponentFeedBack>)target parameters:(id)parameter {
    if (parameter == nil || target == nil) return;
    WXMParameterContext *context = [WXMParameterContext new];
    BOOL isDictionary = [parameter isKindOfClass:NSDictionary.class];
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
    if (isDictionary) {
        context.parameter = (NSDictionary *)parameter;
        objc_setAssociatedObject(target, &parameterKey, parameter, policy);
    } else {
        context.callBack = (RouterCallBack)parameter;
        objc_setAssociatedObject(target, &callbackKey, parameter, policy);
    }
    
    if ([target respondsToSelector:@selector(wc_receiveParameters:)]) {
        [target wc_receiveParameters:context];
    }
}

/** 解析url 跳转viewcontroller */
- (void)jumpViewController:(UIViewController <WXMComponentFeedBack>*)vc scheme:(NSString *)scheme {
    if ([scheme isEqualToString:@"push"]) {
        [self.currentNavigationController pushViewController:vc animated:YES];
    } else if ([scheme isEqualToString:@"present"]) {
        [self.currentNavigationController presentViewController:vc animated:YES completion:nil];
    } else if ([scheme isEqualToString:@""]) {
        
    }
}

/** 根判断2(controller即service) */
- (UIViewController *)viewControllerWithUrl:(NSString *)url obj:(id _Nullable)obj {
    NSURL *urlUrl = [NSURL URLWithString:url];
    NSString *scheme = urlUrl.scheme;             /** 操作类型 */
    NSString *host = urlUrl.host;                 /** 第一路径 */
    if (!scheme || !host || ![scheme isEqualToString:@"component"]) {
        NSLog(@"不是正确的url");
        return nil;
    }
    
    @try {
        NSString *protocol = [self protocol:host];
        Protocol *pro = NSProtocolFromString(protocol);
        UIViewController <WXMComponentFeedBack>*controller = nil;
        controller = [[WXMComponentManager sharedInstance] serviceProvideForProtocol:pro];
        [self handleParametersWithTarget:controller parameters:obj];
        return controller ?: nil;
    } @catch (NSException *exception) { NSLog(@"viewControllerWithUrl判断崩溃 !!!"); } @finally {}
}

/** 根判断3(发送消息) */
- (void)sendMessageWithUrl:(NSString *)url event_id:(_Nullable id)event {
    NSURL *urlUrl = [NSURL URLWithString:url];
    NSString *scheme = urlUrl.scheme;             /** 操作类型 */
    NSString *host = urlUrl.host;                 /** 第一路径 */
    NSString *relativePath = urlUrl.relativePath; /** 第二路径 */
    if (!relativePath || !urlUrl || !host || !scheme || ![scheme isEqualToString:@"sendMessage"]) {
        NSLog(@"不是正确的url");
        return;
    }
    
    @try {
        relativePath = [self action:relativePath];
        WXMComponentManager * man = [WXMComponentManager sharedInstance];
        [man sendEventModule:host event:relativePath.integerValue eventObj:event];
    } @catch (NSException *exception) { NSLog(@"sendMessageWith判断崩溃 !!!!!!!"); } @finally {};
}

#pragma mark 获取参数以及回调

/** 获取参数 */
- (NSDictionary *(^)(id obj))parameter {
    return ^NSDictionary *(id obj) {
        return objc_getAssociatedObject(obj, &parameterKey);
    };
}

/** 正向回调 */
- (WXMComponentRouter * (^)(id target, NSDictionary* _Nullable parameter))callBackForward {
    return ^WXMComponentRouter *(id target, NSDictionary *parameter) {
        RouterCallBack callback = objc_getAssociatedObject(target, &callbackKey);
        if (callback) callback(parameter);
        return self;
    };
}

/** 消息回调 */
- (WXMComponentRouter *(^)(id target, NSDictionary* _Nullable parameter))callBackMessage {
    return ^WXMComponentRouter *(id target, NSDictionary *parameter) {
        RouterCallBack callback = objc_getAssociatedObject(target, &managerCallback);
        if (callback) callback(parameter);
        return self;
    };
}

/** 生成路由 */
- (NSString *(^)(WXMRouterType type, NSString *protocol, ...))createRoute {
    return ^NSString *(WXMRouterType type, NSString *protocol, ...) {
        NSString *header = @"";
        if (type == WXMRouterType_component) header = @"component";
        if (type == WXMRouterType_push) header = @"push";
        if (type == WXMRouterType_present) header = @"present";
        if (type == WXMRouterType_parameter) header = @"parameter";
        if (type == WXMRouterType_message) header = @"message";
        if (header.length == 0) return nil;
        NSString *aString = [NSString stringWithFormat:@"%@://%@",header,protocol];
        va_list params;
        va_start(params, protocol);
        NSString *arg;
        if (protocol) {
            while ((arg = va_arg(params, NSString *))) {
                if (arg) aString = [NSString stringWithFormat:@"%@/%@",aString,arg];
            }
            va_end(params);
        }
        return aString;
    };
}

/** 获取参数 */
- (NSDictionary *)paramsWithString:(NSString*)paramString {
    if (paramString.length == 0) return nil;
    NSMutableDictionary * dictionary = @{}.mutableCopy;
    NSArray *arrays = [paramString componentsSeparatedByString:@"&"];
    [arrays enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        if ([obj containsString:@"="]) {
            NSString * key = [obj componentsSeparatedByString:@"="].firstObject;
            NSString * value = [obj componentsSeparatedByString:@"="].lastObject;
            if(key) [dictionary setObject:value forKey:key];
        }
    }];
    return dictionary;
}

/** 获取协议名 */
- (NSString *)protocol:(NSString *)host {
    return host;
}

/** 获取函数名 */
- (NSString *)action:(NSString *)relativePath {
    return [relativePath stringByReplacingOccurrencesOfString:@"/" withString:@""];
}

/** 获取当前导航控制器 */
- (UINavigationController *)currentNavigationController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootVC = window.rootViewController;
    
    UINavigationController *(^controllersCallback)(UIViewController *) =
    ^UINavigationController *(UIViewController *controller) {
        if ([controller isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)controller;
        } else if ([controller isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBar = (UITabBarController *)controller;
            UIViewController * subVC = tabBar.selectedViewController;
            if ([subVC isKindOfClass:[UINavigationController class]]) {
                return (UINavigationController *)subVC;
            }
            return nil;
        }
        return nil;
    };
    
    if (rootVC.presentedViewController) {
        return controllersCallback(rootVC.presentedViewController);
    } else {
        return controllersCallback(rootVC);
    }
}

@end
#pragma clang diagnostic pop

