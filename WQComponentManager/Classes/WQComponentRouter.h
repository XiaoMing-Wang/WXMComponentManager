//
//  WQComponentRouter.h
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.
/**
 parameter获取数据
 NSString * urlPermission = @"parameter://WXMPhotoInterFaceProtocol/photoPermission";
 
 present push跳转
 NSString * urlPermission = @"present://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController";
 NSString * urlPermission = @"present://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController";
 
 component 组件
 NSString * urlPermission = @"component://WXMPhotoInterFaceProtocol";
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface WQComponentRouter : NSObject

+ (instancetype)sharedInstance;

/** 是否可以打开 */
- (BOOL)canOpenUrl:(NSString *)url;

/** 打开url push直接跳转 */
- (void)openUrl:(NSString *)url;
- (void)openUrl:(NSString *)url params:(NSDictionary * _Nullable)params;
- (void)openUrl:(NSString *)url event_id:(void (^)(id _Nullable obj))event;
- (void)openUrl:(NSString *)url event_map:(void (^)(NSDictionary * obj))event;

/** 返回结果 一般返回controller(模块实现类实现协议方法) */
- (id)resultsOpenUrl:(NSString *)url;
- (id)resultsOpenUrl:(NSString *)url params:(NSDictionary * _Nullable)params;
- (id)resultsOpenUrl:(NSString *)url event_id:(void (^)(id _Nullable obj))event;
- (id)resultsOpenUrl:(NSString *)url event_map:(void (^)(NSDictionary * obj))event;

/** 不需实现协议 需controller作为实现协议对象 */
- (UIViewController *)viewControllerWithUrl:(NSString *)url;
- (UIViewController *)viewControllerWithUrl:(NSString *)url params:(NSDictionary * _Nullable)params;
NS_ASSUME_NONNULL_END
@end

