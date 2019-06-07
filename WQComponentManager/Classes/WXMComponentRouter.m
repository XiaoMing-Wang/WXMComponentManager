//
//  WQComponentRouter.m
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMComponentRouter.h"
#import "WXMComponentHeader.h"
#import <objc/runtime.h>

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
- (void)openUrl:(NSString *_Nonnull)url event_id:(void (^)(id obj))event {
    [self openUrl:url passObj:event routerType:WXMRouterTypeJump];
}
- (void)openUrl:(NSString *_Nonnull)url
      event_map:(void (^)(NSDictionary *obj))event {
    [self openUrl:url passObj:event routerType:WXMRouterTypeJump];
}

/** 解析url 跳转viewcontroller */
- (void)jumpViewController:(UIViewController *)vc scheme:(NSString *)scheme {
    if (vc && [vc isKindOfClass:[UIViewController class]]) {
        if ([scheme isEqualToString:@"push"]) {
            [self.currentNavigationController pushViewController:vc animated:YES];
        } else if ([scheme isEqualToString:@"present"]) {
            [self.currentNavigationController presentViewController:vc animated:YES completion:nil];
        } else if ([scheme isEqualToString:@""]) {
            
        }
    }
}

/** 返回结果(模块实现类实现协议方法) */
- (id)resultsOpenUrl:(NSString * _Nonnull)url {
    return [self openUrl:url passObj:nil routerType:WXMRouterTypeParameter];
}
- (id)resultsOpenUrl:(NSString * _Nonnull)url params:(NSDictionary * _Nullable)params {
    return [self openUrl:url passObj:params routerType:WXMRouterTypeParameter];
}
- (id)resultsOpenUrl:(NSString * _Nonnull)url event_id:(void (^)(id obj))event {
    return [self openUrl:url passObj:event routerType:WXMRouterTypeParameter];
}
- (id)resultsOpenUrl:(NSString * _Nonnull)url event_map:(void (^)(NSDictionary * obj))event {
    return [self openUrl:url passObj:event routerType:WXMRouterTypeParameter];
}

/** 需controller作为实现协议对象 */
- (UIViewController *)viewControllerWithUrl:(NSString *)url {
    return [self viewControllerWithUrl:url params:nil];
}

/** 发送消息 */
- (void)sendMessageWithUrl:(NSString *)url {
    [self sendMessageWithUrl:url event_id:nil];
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
        if (passObj == nil) parameter = [self paramsWithString:query];
        if (passObj != nil && [passObj isKindOfClass:[NSDictionary class]]) {
            parameter = passObj;
        } else {
            parameter = passObj;
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
        if (!service | !sel | ![service respondsToSelector:selReal]) {
           if (!service) NSLog(@"无法生成service类");
           if (!sel) NSLog(@"无法生成action函数");
           if (![service respondsToSelector:selReal]) NSLog(@"service无法无法响应这个函数");
            return nil;
        }
        
        NSLog(@"成功调用");
        if (routerType == WXMRouterTypeWhether) {
            return @(YES);
        } else if (routerType == WXMRouterTypeParameter)  {
            return [service performSelector:selReal withObject:parameter];
        } else if (routerType == WXMRouterTypeJump) {
            UIViewController * vc = [service performSelector:selReal withObject:parameter];
            [self jumpViewController:vc scheme:scheme];
        }
        
        return nil;
    } @catch (NSException *exception) {  NSLog(@"openUrl判断崩溃 !!!!!!!"); } @finally { }
}

/** 根判断2(直接返回controller) */
- (UIViewController *)viewControllerWithUrl:(NSString *)url params:(NSDictionary * _Nullable)params {
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
        UIViewController *vc = [[WXMComponentManager sharedInstance] serviceProvideForProtocol:pro];
        if (params && vc) {
            objc_setAssociatedObject(vc, @"component", params, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
        return vc ?: nil;
        
    } @catch (NSException *exception) {  NSLog(@"viewControllerWithUrl判断崩溃 !!!!!!!"); } @finally { }
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
    [arrays enumerateObjectsUsingBlock:^(NSString* _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)rootVC;
        UIViewController * subVC = tabBar.selectedViewController;
        if ([subVC isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)subVC;
        }
        return nil;
    }
    
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)rootVC;
    }
    return nil;
}

@end
#pragma clang diagnostic pop

