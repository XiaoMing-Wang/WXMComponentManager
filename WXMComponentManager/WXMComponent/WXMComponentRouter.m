//
//  WQComponentRouter.m
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMComponentRouter.h"
#import "WXMComponentHeader.h"
#import "WXMParameterContext.h"

typedef NS_ENUM(NSUInteger, WXMComponentRouterType) {
    WXMRouterTypeWhether = 0,
    WXMRouterTypeParameter = 1,
    WXMRouterTypeJump = 2,
};

@implementation WXMComponentRouter
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"

+ (instancetype)sharedInstance {
    static WXMComponentRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[self alloc] init];
    });
    return router;
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
        
        /** 判断传递参数是什么类型 */
        id parameter = nil;
        if (passObj == nil) {
            parameter = [self paramsWithString:query];
        } else if (passObj != nil && [passObj isKindOfClass:[NSDictionary class]]) {
            parameter = passObj;
        } else {
            parameter = passObj; /** block */
        }
        
        /** 剪切参数获取字符串 */
        NSString *protocol = [self protocol:host];
        NSString *action = [self action:relativePath];
        if (!protocol || !action) {
            NSLog(@"url解析不出protocol或action");
            return nil;
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
        if (routerType == WXMRouterTypeWhether) {
            return @(YES);
        } else if (routerType == WXMRouterTypeParameter)  {
            return [service performSelector:selReal withObject:parameter];
        } else if (routerType == WXMRouterTypeJump) {
            UIViewController <WXMComponentFeedBack>* vc = nil;
            vc = [service performSelector:selReal withObject:parameter];
            [self jumpViewController:vc scheme:scheme obj:parameter];
        }
        
        return nil;
    } @catch (NSException *exception) {  NSLog(@"openUrl判断崩溃 !!!!!!!"); } @finally {}
}

/** 解析url 跳转viewcontroller */
- (void)jumpViewController:(UIViewController <WXMComponentFeedBack>*)vc
                    scheme:(NSString *)scheme
                       obj:(id)obj {
    
    WXMParameterContext *context = [WXMParameterContext new];
    if ([obj isKindOfClass:[NSDictionary class]] && obj) {
        NSDictionary *parameters = (NSDictionary *)obj;
        context.parameter = parameters;
    } else if(obj != nil) {
        RouterCallBack callBack = (RouterCallBack)obj;
        context.callBack = callBack;
    }
    
    if (vc && [vc isKindOfClass:[UIViewController class]]) {
        if ([vc respondsToSelector:@selector(wc_receiveParameters:)]) {
            [vc wc_receiveParameters:context];
        }
        
        if ([scheme isEqualToString:@"push"]) {
            [self.currentNavigationController pushViewController:vc animated:YES];
        } else if ([scheme isEqualToString:@"present"]) {
            [self.currentNavigationController presentViewController:vc animated:YES completion:nil];
        } else if ([scheme isEqualToString:@""]) {
            
        }
    }
}

/** 根判断2(直接返回controller) */
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
        
        WXMParameterContext *context = [WXMParameterContext new];
        if ([obj isKindOfClass:[NSDictionary class]] && obj) {
            NSDictionary *parameters = (NSDictionary *)obj;
            context.parameter = parameters;
        } else if(obj != nil) {
            RouterCallBack callBack = (RouterCallBack)obj;
            context.callBack = callBack;
        }
        
        if ([controller respondsToSelector:@selector(wc_receiveParameters:)]) {
            [controller wc_receiveParameters:context];
        }
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

