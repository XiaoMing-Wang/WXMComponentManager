//
//  WQComponentRouter.h
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.

#import <Foundation/Foundation.h>
typedef void (^Feedback)(int type, id _Nullable obj);

@interface WQComponentRouter : NSObject

+ (instancetype _Nonnull)sharedInstance;

/** 打开url */
- (void)openUrl:(NSString * _Nonnull)url;
- (void)openUrl:(NSString * _Nonnull)url params:(NSDictionary * _Nullable)params;
- (void)openUrl:(NSString * _Nonnull)url feedback:(Feedback _Nullable)feedback;

@end
