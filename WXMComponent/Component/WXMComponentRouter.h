////
////  WQComponentRouter.h
////  ModulesProject
////
////  Created by edz on 2019/4/24.
////  Copyright © 2019年 wq. All rights reserved.
//
//
//#import <UIKit/UIKit.h>
//#import <Foundation/Foundation.h>
//#import "WXMComponentConfiguration.h"
//
//NS_ASSUME_NONNULL_BEGIN
///** parameter://WXMPhotoInterFaceProtocol/photoPermission */
///** present://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController */
///** push://WXMPhotoInterFaceProtocol/routeAchieveWXMPhotoViewController */
///** component://WXMPhotoInterFaceProtocol */
//
//@interface WXMComponentRouter : NSObject
//
//+ (instancetype)sharedInstance;
//
///** 生成路由 */
//- (NSString *(^)(WCRouterType type, NSString *protocol, ...))createRoute;
//
///** 判断url是否可以打开 */
//- (BOOL)canOpenUrl:(NSString *)url;
//
///** 模块实现类实现协议 */
//- (id)resultsOpenUrl:(NSString *)url;
//- (id)resultsOpenUrl:(NSString *)url params:(NSDictionary * _Nullable)params;
//- (id)resultsOpenUrl:(NSString *)url callBack:(SignalCallBack _Nullable)callBack;
//
///** 打开 */
//- (void)openUrl:(NSString *)url;
//- (void)openUrl:(NSString *)url params:(NSDictionary * _Nullable)params;
//- (void)openUrl:(NSString *)url callBack:(SignalCallBack _Nullable)callBack;
//@end
//
//NS_ASSUME_NONNULL_END
//
//
