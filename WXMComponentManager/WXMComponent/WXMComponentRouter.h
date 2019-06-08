//
//  WQComponentRouter.h
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.
/**
    ** parameter获取数据
    NSString * url = @"parameter://WXMPhotoInterFaceProtocol/photoPermission";
 
    ** present push跳转
    NSString * url = @"present://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController";
    NSString * url = @"push://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController";
 
    ** component组件
    NSString * url = @"component://WXMPhotoInterFaceProtocol";
 
    ** sendMessage发消息
    NSString * url = @"sendMessage://WXMPhotoInterFaceProtocol/100";
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface WXMComponentRouter : NSObject

+ (instancetype)sharedInstance;

/** 判断url是否可以打开 */
- (BOOL)canOpenUrl:(NSString *)url;

/** 打开url push直接跳转 */
- (void)openUrl:(NSString *)url;
- (void)openUrl:(NSString *)url params:(NSDictionary *_Nullable)params;

/** 返回结果 一般返回controller(模块实现类实现协议) */
- (id)resultsOpenUrl:(NSString *)url;
- (id)resultsOpenUrl:(NSString *)url params:(NSDictionary * _Nullable)params;

/** controller作为实现协议对象 */
- (UIViewController *)viewControllerWithUrl:(NSString *)url;
- (UIViewController *)viewControllerWithUrl:(NSString *)url params:(NSDictionary * _Nullable)params;

/** 发消息 */
- (void)sendMessageWithUrl:(NSString *)url;
- (void)sendMessageWithUrl:(NSString *)url event_id:(_Nullable id)event;

NS_ASSUME_NONNULL_END
@end

//- (void)openUrl:(NSString *)url event_id:(void (^)(id _Nullable obj))event;
//- (void)openUrl:(NSString *)url event_map:(void (^)(NSDictionary *obj))event;
//- (id)resultsOpenUrl:(NSString *)url event_id:(void (^)(id _Nullable obj))event;
//- (id)resultsOpenUrl:(NSString *)url event_map:(void (^)(NSDictionary * obj))event;
