//
//  WQComponentRouter.h
//  ModulesProject
//
//  Created by edz on 2019/4/24.
//  Copyright © 2019年 wq. All rights reserved.
/**
 建议不同模块以NSDictionary作为参数传递 由模型转字典传递出去 接收方字典转模型
 NSString * url = @"parameter://WXMPhotoInterFaceProtocol/photoPermission";
 NSString * url = @"present://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController";
 NSString * url = @"push://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController";
 NSString * url = @"component://WXMPhotoInterFaceProtocol";
 NSString * url = @"sendMessage://WXMPhotoInterFaceProtocol/100";
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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

/** (初始化时)正向传递的回调数据 */
- (void)callBackParameterWithTarget:(id)target parameter:(NSDictionary *)parameter;/*1*/
- (void)callBackMessageWithTarget:(id)target parameter:(NSDictionary *)parameter;/*2*/

NS_ASSUME_NONNULL_END
@end



