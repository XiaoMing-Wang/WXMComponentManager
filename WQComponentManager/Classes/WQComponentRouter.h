//
//  WQComponentRouter.h
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef void (^Feedback)(int type, id _Nullable obj);

@interface WQComponentRouter : NSObject

+ (instancetype _Nonnull)sharedInstance;

/** 是否可以打开 */
- (BOOL)canOpenUrl:(NSString * _Nonnull)url;

/** 打开url push直接跳转 */
- (void)openUrl:(NSString * _Nonnull)url;
- (void)openUrl:(NSString * _Nonnull)url params:(NSDictionary * _Nullable)params;
- (void)openUrl:(NSString * _Nonnull)url feedback:(Feedback _Nullable)feedback;

/** 返回结果 */
- (id)resultsOpenUrl:(NSString * _Nonnull)url;
- (id)resultsOpenUrl:(NSString * _Nonnull)url params:(NSDictionary * _Nullable)params;
- (id)resultsOpenUrl:(NSString * _Nonnull)url feedback:(Feedback _Nullable)feedback;

NS_ASSUME_NONNULL_END
@end

