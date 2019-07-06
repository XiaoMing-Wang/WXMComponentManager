//
//  WQComponentRouter.h
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/**建议不同模块以NSDictionary作为参数传递 由模型转字典传递出去 接收方字典转模型
 NSString * url = @"parameter://WXMPhotoInterFaceProtocol/photoPermission";
 NSString * url = @"present://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController";
 NSString * url = @"push://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController";
 NSString * url = @"component://WXMPhotoInterFaceProtocol";
 NSString * url = @"message://WXMPhotoInterFaceProtocol/100"; */
typedef NS_ENUM(NSUInteger, WXMRouterType) {
    WXMRouterType_component = 0,
    WXMRouterType_push,
    WXMRouterType_present,
    WXMRouterType_parameter,
    WXMRouterType_message,
};

typedef void (^RouterCallBack)(NSDictionary *_Nullable);
@interface WXMComponentRouter : NSObject

+ (instancetype)sharedInstance;

/** 判断url是否可以打开 */
- (BOOL)canOpenUrl:(NSString *)url;

/** 打开url 例 push直接跳转 */
- (void)openUrl:(NSString *)url;
- (void)openUrl:(NSString *)url params:(NSDictionary *_Nullable)params;
- (void)openUrl:(NSString *)url callBack:(RouterCallBack _Nullable)callBack;/*1*/

/** 返回结果(模块实现类实现协议) */
- (id)resultsOpenUrl:(NSString *)url;
- (id)resultsOpenUrl:(NSString *)url params:(NSDictionary *_Nullable)params;
- (id)resultsOpenUrl:(NSString *)url callBack:(RouterCallBack _Nullable)callBack; /*1*/

/** controller作为实现协议对象 */
- (UIViewController *)viewControllerWithUrl:(NSString *)url;
- (UIViewController *)viewControllerWithUrl:(NSString *)url params:(NSDictionary *_Nullable)params;
- (UIViewController *)viewControllerWithUrl:(NSString *)url callBack:(RouterCallBack)callBack;/*1*/

/** 发消息 */
- (void)sendMessageWithUrl:(NSString *)url;
- (void)sendMessageWithUrl:(NSString *)url params:(NSDictionary *_Nullable)params;
- (void)sendMessageWithUrl:(NSString *)url callBack:(RouterCallBack)callBack;/*2*/

#pragma mark 获取参数以及回调

/** 获取参数 and 正向回调 */
- (NSDictionary *(^)(id obj))parameter;
- (NSString *(^)(WXMRouterType type, NSString *protocol, ...))createRoute; /** 生成路由 */
- (WXMComponentRouter *(^)(id target, NSDictionary* _Nullable parameter))callBackForward;
- (WXMComponentRouter *(^)(id target, NSDictionary* _Nullable parameter))callBackMessage;
@end

NS_ASSUME_NONNULL_END


