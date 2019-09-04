//
//  WQComponentRouter.m
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.

#import <objc/runtime.h>
#import "WXMComponentRouter.h"
#import "WXMComponentHeader.h"
#import "WXMComponentBridge.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"
typedef NS_ENUM(NSUInteger, WXMComponentRouterType) {
    WXMRouterTypeWhether = 0,
    WXMRouterTypeObject,
};

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
    id results = [self objUrl:url passObj:nil routerType:WXMRouterTypeWhether];
    if ([results boolValue] && results != nil) return YES;
    return NO;
}

/** 返回结果(模块实现类实现协议方法) */
- (id)resultsOpenUrl:(NSString *)url {
    return [self objectWithUrl:url obj:nil];
}
- (id)resultsOpenUrl:(NSString *)url params:(NSDictionary *_Nullable)params {
    return [self objectWithUrl:url obj:params];
}
- (id)resultsOpenUrl:(NSString *)url callBack:(SignalCallBack _Nullable)callBack {
    return [self objectWithUrl:url obj:callBack];
}

/** 直接打开url */
- (void)openUrl:(NSString *)url {
    [self openViewController:url obj:nil];
}
- (void)openUrl:(NSString *)url params:(NSDictionary *_Nullable)params {
    [self openViewController:url obj:params];
}
- (void)openUrl:(NSString *)url callBack:(SignalCallBack _Nullable)callBack {
    [self openViewController:url obj:callBack];
}

/** 获取object 1 */
- (id)objectWithUrl:(NSString *)url obj:(id _Nullable)obj {
    if (![NSURL URLWithString:url].scheme) return nil;
    if ([self isComponent:url]) return  [self viewControllerWithUrl:url obj:obj];
    return [self objUrl:url passObj:obj routerType:WXMRouterTypeObject];
}

/** 打开viewcontroller */
- (void)openViewController:(NSString *)url obj:(id _Nullable)obj {
    id controller = [self objectWithUrl:url obj:obj];
    if (![controller isKindOfClass:[UIViewController class]]) return;
    [self jumpViewController:controller scheme:[NSURL URLWithString:url].scheme];
}

/** 根判断1 */
- (id)objUrl:(NSString *)url passObj:(id)passObj routerType:(WXMComponentRouterType)routerType {
    @try {
        
        NSURL *urlUrl = [NSURL URLWithString:url];
        NSString *scheme = urlUrl.scheme;             /** 操作类型 */
        NSString *host = urlUrl.host;                 /** 第一路径 */
        NSString *relativePath = urlUrl.relativePath; /** 第二路径 */
        NSString *query = urlUrl.query;               /** 参数 */
        if (!relativePath || !urlUrl || !host || !scheme) {
            if (WXMDEBUG) NSLog(@"不是正确的url");
            return nil;
        }
        
        /** 剪切参数获取字符串 */
        NSString *protocol = [self protocol:host];
        NSString *action = [self action:relativePath];
        if (!protocol || !action) {
            if (WXMDEBUG) NSLog(@"url解析不出protocol或action");
            return nil;
        }
        
        /** 判断传递参数是什么类型 */
        id parameter = nil;
        if (passObj == nil) {
            parameter = [self paramsWithString:query];
        } else if (passObj != nil && [passObj isKindOfClass:[NSDictionary class]]) {
            parameter = passObj;
        } else {
            parameter = passObj;  /** block */
        }
        
        /** 获取service */
        Protocol *pro = NSProtocolFromString(protocol);
        id service = [[WXMComponentManager sharedInstance] serviceProvideForProtocol:pro];
        SEL sel = NSSelectorFromString(action);
        SEL selSuffix = NSSelectorFromString([action stringByAppendingString:@":"]);
        SEL selReal = [service respondsToSelector:sel] ? sel : selSuffix;
        if (!service || !selReal || ![service respondsToSelector:selReal]) {
            if (!service && WXMDEBUG) NSLog(@"无法生成service类");
            if (!selReal && WXMDEBUG) NSLog(@"无法生成action函数");
            if (![service respondsToSelector:selReal] && WXMDEBUG) {
                NSLog(@"service无法无法响应这个函数");
            }
            return nil;
        }
        
        if (WXMDEBUG) NSLog(@"成功调用");
        id __target = nil;
        if (routerType == WXMRouterTypeWhether) {
            return @(YES);
        } else if (routerType == WXMRouterTypeObject)  {
            __target = [service performSelector:selReal withObject:parameter];
            [self handleParametersWithTarget:__target parameters:parameter];
        }
        
        return __target ?: nil;
    } @catch (NSException *exception) { if (WXMDEBUG) NSLog(@"openUrl判断崩溃 !!!"); } @finally {}
}

/** 根判断2(controller即service) */
- (UIViewController *)viewControllerWithUrl:(NSString *)url obj:(id _Nullable)obj {
    NSURL *urlUrl = [NSURL URLWithString:url];
    NSString *scheme = urlUrl.scheme;             /** 操作类型 */
    NSString *host = urlUrl.host;                 /** 第一路径 */
    if (!scheme || !host) {
        if (WXMDEBUG) NSLog(@"不是正确的url");
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

/** 处理target参数 */
- (void)handleParametersWithTarget:(id<WXMComponentFeedBack>)target parameters:(id)parameter {
    if (parameter == nil || target == nil) return;
    
    /** Bridge对象处理参数和回调 */
    [WXMComponentBridge handleParametersWithTarget:target parameters:parameter];
}

/** 解析url 跳转viewcontroller */
- (void)jumpViewController:(UIViewController *)vc scheme:(NSString *)scheme {
    if (!vc) return;
    if ([scheme isEqualToString:@"push"]) {
        [self.currentNavigationController pushViewController:vc animated:YES];
    } else if ([scheme isEqualToString:@"present"]) {
        [self.currentNavigationController presentViewController:vc animated:YES completion:nil];
    } else if ([scheme isEqualToString:@""]) {
        
    }
}

/** 生成路由 */
- (NSString *(^)(WXMRouterType type, NSString *protocol, ...))createRoute {
    return ^NSString *(WXMRouterType type, NSString *protocol, ...) {
        NSString *header = @"";
        if (type == WXMRouterType_component) header = WXM_COMPONENT;
        if (type == WXMRouterType_push) header = @"push";
        if (type == WXMRouterType_present) header = @"present";
        if (type == WXMRouterType_parameter) header = @"parameter";
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

/** 判断是不是 */
- (BOOL)isComponent:(NSString *)url {
    return [[NSURL URLWithString:url].scheme isEqualToString:WXM_COMPONENT];
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
        UIViewController *controller = rootVC.presentedViewController;
        if ([controller isKindOfClass:[UIAlertController class]]) {
            [controller dismissViewControllerAnimated:NO completion:nil];
            return controllersCallback(rootVC);
        }
        return controllersCallback(rootVC.presentedViewController);
    } else {
        return controllersCallback(rootVC);
    }
}

@end
#pragma clang diagnostic pop

