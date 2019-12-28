//
//  WXMMediator.h
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//
#define WXMMEDIATOR_PERFORM(target) [self performTarget:target action:NSStringFromSelector(_cmd)];
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXMMediator : NSObject

+ (instancetype)sharedInstance;

/**  远程App调用入口 */
- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *info))completion;

/**  本地组件调用入口 */
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName;

/**  本地组件调用入口 */
- (id)performTarget:(NSString *)targetName
             action:(NSString *)actionName
             params:(NSDictionary *_Nullable)params
  shouldCacheTarget:(BOOL)shouldCacheTarget;

/** 删除 */
- (void)releaseCachedTargetWithTargetName:(NSString *)targetName;

@end

NS_ASSUME_NONNULL_END
