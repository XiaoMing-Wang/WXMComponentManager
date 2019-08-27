//
//  WXMComponentServiceSupplement.m
//  ModuleDebugging
//
//  Created by edz on 2019/8/26.
//  Copyright © 2019 wq. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMComponentService.h"
#import "WXMComponentManager.h"
#import "WXMComponentConfiguration.h"
#import "WXMComponentServiceHelp.h"

@implementation WXMResponse
+ (WXMResponse *)response:(int)errorCode errorMsg:(NSString *)errorMsg object:(id)object {
    WXMResponse *response = [[WXMResponse alloc] init];
    response.errorCode = errorCode;
    response.errorMsg = errorMsg;
    response.object = object;
    return response;
}
@end

static char serviceArrayKey;
@implementation WXMComponentServiceHelp

+ (id)serviceProvide:(Protocol *)protocol depend:(id)depend {
    id service = [[WXMComponentManager sharedInstance] serviceProvideForProtocol:protocol];
    if (![service respondsToSelector:@selector(setServiceCallback:)]) return nil;
    if (![service isKindOfClass:WXMComponentService.class]) return nil;
    if (service) [[self dependArray:depend] addObject:service];
    return service;
}

+ (id)serviceforPrivateKey:(NSString *)privateKey depend:(id)depend {
    NSMutableArray *dependArray = [self dependArray:depend];
    WXMComponentService *callService = nil;
    for (WXMComponentService *service in dependArray.reverseObjectEnumerator) {
        if ([service.privateKey isEqualToString:privateKey]) {
            callService = service;
        }
    }
    
    void (^removeBlock)(void) = [WXMComponentServiceHelp removeBlock:privateKey depend:depend];
    [callService setValue:removeBlock forKey:WXM_REMOVE_CALLBACK];
    return callService;
}

+ (void)removePrivateKey:(NSString *)privateKey depend:(id)depend {
    NSMutableArray *dependArray = [self dependArray:depend];
    for (WXMComponentService *service in dependArray.reverseObjectEnumerator) {
        if ([service.privateKey isEqualToString:privateKey]) {
            [dependArray removeObject:service];
        }
    }
}

/** 获取数组 */
+ (NSMutableArray *)dependArray:(id)depend {
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
    NSMutableArray *dependArray = objc_getAssociatedObject(depend, &serviceArrayKey);
    if (!dependArray) {
        dependArray = @[].mutableCopy;
        objc_setAssociatedObject(depend, &serviceArrayKey, dependArray, policy);
    }
    return dependArray;
}

/** 删除 */
+ (void (^)(void))removeBlock:(NSString *)key depend:(id)depend  {
    __weak typeof(depend) weakD = depend;
    return ^{ if (weakD) [WXMComponentServiceHelp removePrivateKey:key depend:weakD];};
}
@end
