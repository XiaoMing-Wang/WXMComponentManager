//
//  NSObject+WXMComponent.m
//  ModuleDebugging
//
//  Created by edz on 2019/7/6.
//  Copyright © 2019 wq. All rights reserved.
//
#import <objc/runtime.h>
#import "NSObject+WXMComponent.h"
#import "WXMListenObj.h"

@interface NSObject ()
@property (nonatomic, strong) NSMutableArray *listenArray;
@property (nonatomic, copy) NSString *currentListen;
@end
@implementation NSObject (WXMComponent)

- (instancetype (^)(NSString *))observeKey {
    return ^id(NSString *listen) {
        @synchronized (self) {
            self.currentListen = listen;
        }
        return self;
    };
}

/** block要和 listen绑定 */
- (void)wxm_subscribeNext:(void (^)(NSDictionary *parameter))callback {
    @synchronized (self) {
        WXMListenObj *message = [WXMListenObj new];
        message.listen = self.currentListen;
        message.callBack = callback;
        
        NSMutableArray * arrayM = self.listenArray.mutableCopy;
        if (arrayM.count >= 10) return;
        [arrayM addObject:message];
        [self setListenArray:arrayM];
    }
}

- (void)setListenArray:(NSMutableArray *)listenArray {
    objc_setAssociatedObject(self, @selector(listenArray), listenArray, 3);
}

- (NSMutableArray *)listenArray {
    NSMutableArray *array = objc_getAssociatedObject(self, _cmd);
    if (array == nil) {
        array = @[].mutableCopy;
        objc_setAssociatedObject(self, _cmd, array, 3);
    }
    return array.mutableCopy;
}

- (void)setCurrentListen:(NSString *)currentListen {
    objc_setAssociatedObject(self, @selector(currentListen), currentListen, 3);
}

- (NSString *)currentListen {
    return objc_getAssociatedObject(self, _cmd);
}


@end
