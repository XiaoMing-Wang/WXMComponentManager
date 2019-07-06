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
@property (nonatomic, assign) pthread_mutex_t mutex;
@property (nonatomic, strong) NSLock *listenLock;
@end
@implementation NSObject (WXMComponent)

- (instancetype (^)(NSString *))observeKey {
    return ^id(NSString *listen) {
        if (!self.listenLock) self.listenLock = [[NSLock alloc] init];
        [self.listenLock lock];
        self.currentListen = listen;
        [self.listenLock unlock];
        return self;
    };
}

/** block要和 listen绑定 */
- (void)wxm_subscribeNext:(void (^)(NSDictionary *parameter))callback {
    NSMutableArray * arrayM = self.listenArray ? self.listenArray.mutableCopy : @[].mutableCopy;
    if (arrayM.count >= 10) return;
    
    [self.listenLock lock];
    WXMListenObj *message = [WXMListenObj new];
    message.listen = self.currentListen;
    message.callBack = callback;
       
    [arrayM addObject:message];
    [self setListenArray:arrayM];
    [self.listenLock unlock];
}

- (void)setListenArray:(NSMutableArray *)listenArray {
    objc_setAssociatedObject(self, @selector(listenArray), listenArray, 1);
}

- (NSMutableArray *)listenArray {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCurrentListen:(NSString *)currentListen {
    objc_setAssociatedObject(self, @selector(currentListen), currentListen, 3);
}

- (NSString *)currentListen {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setListenLock:(NSLock *)listenLock {
     objc_setAssociatedObject(self, @selector(listenLock), listenLock, 1);
}

- (NSLock *)listenLock {
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)load {
    Method method1 = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
    Method method2 = class_getInstanceMethod(self, @selector(_dealloc));
    method_exchangeImplementations(method1, method2);
}

- (void)_dealloc {
    if (self.listenArray) [self.listenArray removeAllObjects];
}

- (void)setMutex:(pthread_mutex_t)mutex {
    
}
@end
