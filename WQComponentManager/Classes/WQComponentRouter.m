//
//  WQComponentRouter.m
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WQComponentRouter.h"
#import "WQComponentManager.h"

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
/** 解析url */
- (void)openUrl:(NSString *)url {
    [self openUrl:url params:nil];
}
- (void)openUrl:(NSString *)url params:(NSDictionary * _Nullable)params {
    [self openUrl:url passObj:params];
}
- (void)openUrl:(NSString * _Nonnull)url feedback:(Feedback _Nullable)feedback {
    [self openUrl:url passObj:feedback];
}
- (void)openUrl:(NSString *)url passObj:(id)passObj {
    NSURL * urlUrl = [NSURL URLWithString:url];
    NSString *relativePath = urlUrl.relativePath;
    NSString *query = urlUrl.query;
    if (!relativePath || !urlUrl) { NSLog(@"不是正确的url");}
    if (!relativePath || !urlUrl)return;
    
    /** 判断传递参数是什么类型 */
    id parameter = nil;
    if (passObj == nil) parameter = [self paramsWithString:query];
    if (passObj != nil && [passObj isKindOfClass:[NSDictionary class]]) parameter = passObj;
    else parameter = passObj;
    
    
    /** 剪切参数获取字符串 */
    NSString *protocol = [self protocol:relativePath];
    NSString *action = [self action:relativePath];
    if (!protocol || !action) { NSLog(@"url解析不出protocol或action");}
    if (!protocol || !action) return;
      
    /** 获取service */
    Protocol *pro = NSProtocolFromString(protocol);
    id service = [[WQComponentManager sharedInstance] serviceProvideForProtocol:pro];
    SEL sel = NSSelectorFromString(action);
    SEL selSuffix = NSSelectorFromString([action stringByAppendingString:@":"]);
    SEL selReal = [service respondsToSelector:sel] ? sel : selSuffix;
    if (!service | !sel | ![service respondsToSelector:selReal]) {
        NSLog(@"无法生成service类 或 action函数 或 无法响应");
        return;
    }
    
    NSLog(@"成功调用");
    UIViewController *viewcontroller = [service performSelector:selReal withObject:parameter];
    [self.currentNavigationController pushViewController:viewcontroller animated:YES];
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
- (NSString *)protocol:(NSString *)relativePath {
    if ([relativePath hasPrefix:@"/"]) relativePath = [relativePath substringFromIndex:1];
    if (relativePath == nil || ![relativePath containsString:@"/"]) return nil;
    NSString* protocol = [relativePath componentsSeparatedByString:@"/"].firstObject;
    if (protocol.length == 0 || !protocol) return nil;
    return protocol;
}
/** 获取函数名 */
- (NSString *)action:(NSString *)relativePath {
    if ([relativePath hasPrefix:@"/"]) relativePath = [relativePath substringFromIndex:1];
    if (relativePath == nil || ![relativePath containsString:@"/"]) return nil;
    NSString* action = [relativePath componentsSeparatedByString:@"/"].lastObject;
    if (action.length == 0 || !action) return nil;
    return action;
}
/** 获取当前导航栏 */
- (UINavigationController *)currentNavigationController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UINavigationController *nav = (UINavigationController *)window.rootViewController;
    
    /** 判断一波 */
    return nav;
}

@end
#pragma clang diagnostic pop

