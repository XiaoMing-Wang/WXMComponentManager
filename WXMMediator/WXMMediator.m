//
//  WXMMediator.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//

#import "WXMMediator.h"

@interface WXMMediator ()
@property (nonatomic, strong) NSMutableDictionary *cachedTarget;
@end

@implementation WXMMediator

/** 单例 */
+ (instancetype)sharedInstance {
    static WXMMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[self alloc] init];
    });
    return mediator;
}

/*
 scheme://[target]/[action]?[params]
 url sample:
 aaa://targetA/actionB?id=1234
 */

- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *urlString = [url query];
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    
    /** 这里这么写主要是出于安全考虑，防止黑客通过远程方式调用本地模块。 */
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([actionName hasPrefix:@"native"]) {
        return @(NO);
    }
    
    id result = [self performTarget:url.host
                             action:actionName
                             params:params
                  shouldCacheTarget:NO];
    
    if (completion) {
        if (result) completion( @{@"result":result} );
        if (!result) completion(nil);
    }
    return result;
}

/**  本地组件调用入口 */
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName {
    return [self performTarget:targetName
                        action:actionName
                        params:nil
             shouldCacheTarget:NO];
}

/** runtime调用 */
- (id)performTarget:(NSString *)targetName
             action:(NSString *)actionName
             params:(NSDictionary *_Nullable)params
  shouldCacheTarget:(BOOL)shouldCacheTarget {
    
    /**  generate target */
    NSString *targetCS = [NSString stringWithFormat:@"%@", targetName];;
    NSObject *target = self.cachedTarget[targetCS];
    if (target == nil) {
        Class targetClass = NSClassFromString(targetCS);
        target = [[targetClass alloc] init];
    }
    
    /**  generate action */
    NSString *actionString = [NSString stringWithFormat:@"%@", actionName];
    NSString *actionSuffix = [NSString stringWithFormat:@"%@:", actionName];
    SEL action = NSSelectorFromString(actionString);
    SEL actionSux = NSSelectorFromString(actionSuffix);
    
    if (target == nil) {
        [self NoTargetActionResponse:targetCS
                      selectorString:actionString
                        originParams:params];
        return nil;
    }
    
    /** 缓存target */
    if (shouldCacheTarget) self.cachedTarget[targetCS] = target;
    if ([target respondsToSelector:action] || [target respondsToSelector:actionSux] ) {
        SEL realSEL = [target respondsToSelector:action] ? action : actionSux;
        return [self safePerformAction:realSEL target:target params:params];
    } else {
        /**  这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理 */
        SEL action = NSSelectorFromString(@"notFound:");
        if ([target respondsToSelector:action]) {
            return [self safePerformAction:action target:target params:params];
        } else {
            
            /**  这里也是处理无响应请求的地方，在notFound都没有的时候，这个demo是直接return了。 */
            [self NoTargetActionResponse:targetCS
                          selectorString:actionString
                            originParams:params];
            [self.cachedTarget removeObjectForKey:targetCS];
            return nil;
        }
    }
}

- (void)releaseCachedTargetWithTargetName:(NSString *)targetName {
    NSString *targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    [self.cachedTarget removeObjectForKey:targetClassString];
}

#pragma mark - private methods
- (void)NoTargetActionResponse:(NSString *)targetString
                selectorString:(NSString *)selectorString
                  originParams:(NSDictionary *)originParams {
    SEL action = NSSelectorFromString(@"Action_response:");
    NSObject *target = [[NSClassFromString(@"Target_NoTargetAction") alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"originParams"] = originParams;
    params[@"targetString"] = targetString;
    params[@"selectorString"] = selectorString;
    [self safePerformAction:action target:target params:params];
}

- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params {
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) return nil;
    
    const char* retType = [methodSig methodReturnType];

    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }

    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation =
            [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

#pragma mark - getters and setters
- (NSMutableDictionary *)cachedTarget {
    if (_cachedTarget == nil) _cachedTarget = [[NSMutableDictionary alloc] init];
    return _cachedTarget;
}

@end
