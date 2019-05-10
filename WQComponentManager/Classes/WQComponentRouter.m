//
//  WQComponentRouter.m
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WQComponentRouter.h"
#import "WQComponentManager.h"
typedef NS_ENUM(NSUInteger, WXMComponentRouterType) {
    WXMRouterTypeWhether = 0,
    WXMRouterTypeParameter = 1,
    WXMRouterTypeJump = 2,
};

@implementation WQComponentRouter
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wundeclared-selector"

+ (instancetype)sharedInstance {
    static WQComponentRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[WQComponentRouter alloc] init];
    });
    return router;
}

/** 是否可以打开 */
- (BOOL)canOpenUrl:(NSString * _Nonnull)url {
    id results = [self openUrl:url passObj:nil routerType:WXMRouterTypeWhether];
    if ([results boolValue] && results != nil) return YES;
    return NO;
}

/** 解析url 跳转viewcontroller */
- (void)jumpViewController:(UIViewController *)vc scheme:(NSString *)scheme {
    if (vc && [vc isKindOfClass:[UIViewController class]]) {
        if ([scheme isEqualToString:@"push"]) {
            [self.currentNavigationController pushViewController:vc animated:YES];
        } else if ([scheme isEqualToString:@"present"]) {
            [self.currentNavigationController presentViewController:vc animated:YES completion:nil];
        } else if ([scheme isEqualToString:@""]) { }
    }
}
- (void)openUrl:(NSString *)url {
    [self openUrl:url passObj:nil routerType:WXMRouterTypeJump];
}
- (void)openUrl:(NSString *)url params:(NSDictionary * _Nullable)params {
    [self openUrl:url passObj:params routerType:WXMRouterTypeJump];
}
- (void)openUrl:(NSString * _Nonnull)url event_id:(void (^)(id obj))event {
    [self openUrl:url passObj:event routerType:WXMRouterTypeJump];
}
- (void)openUrl:(NSString * _Nonnull)url event_map:(void (^)(NSDictionary * obj))event {
    [self openUrl:url passObj:event routerType:WXMRouterTypeJump];
}

/** 返回结果 id 或者 viewcontroller */
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
/** 根判断 */
- (id)openUrl:(NSString *)url passObj:(id)passObj routerType:(WXMComponentRouterType)routerType {
    @try {

        NSURL *urlUrl = [NSURL URLWithString:url];
        NSString *scheme = urlUrl.scheme;             /** 操作类型 */
        NSString *host = urlUrl.host;                 /** 第一路径 */
        NSString *relativePath = urlUrl.relativePath; /** 真实子路径 */
        NSString *query = urlUrl.query; /** 参数 */
        if (!relativePath || !urlUrl || !host || !scheme) { NSLog(@"不是正确的url");}
        if (!relativePath || !urlUrl || !host || !scheme) return nil;
        
        /** 判断传递参数是什么类型 */
        id parameter = nil;
        if (passObj == nil) parameter = [self paramsWithString:query];
        if (passObj != nil && [passObj isKindOfClass:[NSDictionary class]]) parameter = passObj;
        else parameter = passObj;
        
        
        /** 剪切参数获取字符串 */
        NSString *protocol = [self protocol:host];
        NSString *action = [self action:relativePath];
        if (!protocol || !action) { NSLog(@"url解析不出protocol或action");}
        if (!protocol || !action) return nil;
   
        /** 获取service */
        Protocol *pro = NSProtocolFromString(protocol);
        id service = [[WQComponentManager sharedInstance] serviceProvideForProtocol:pro];
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
//    if ([relativePath hasPrefix:@"/"]) relativePath = [relativePath substringFromIndex:1];
//    if (relativePath == nil || ![relativePath containsString:@"/"]) return nil;
//    NSString* protocol = [relativePath componentsSeparatedByString:@"/"].firstObject;
//    if (protocol.length == 0 || !protocol) return nil;
    return host;
}
/** 获取函数名 */
- (NSString *)action:(NSString *)relativePath {
//    if ([relativePath hasPrefix:@"/"]) relativePath = [relativePath substringFromIndex:1];
//    if (relativePath == nil || ![relativePath containsString:@"/"]) return nil;
//    NSString* action = [relativePath componentsSeparatedByString:@"/"].lastObject;
//    if (action.length == 0 || !action) return nil;
    return [relativePath stringByReplacingOccurrencesOfString:@"/" withString:@""];
}

/** 获取当前导航栏 */
- (UINavigationController *)currentNavigationController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootVC = window.rootViewController;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)rootVC;
        UIViewController * subVC = tabBar.selectedViewController;
        if ([subVC isKindOfClass:[UINavigationController class]]) return (UINavigationController *)subVC;
        return nil;
    }
    
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)rootVC;
    }
    
    /** 判断一波 */
    return nil;
}

@end
#pragma clang diagnostic pop
