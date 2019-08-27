//
//  WXMComponentServiceSupplement.h
//  ModuleDebugging
//
//  Created by edz on 2019/8/26.
//  Copyright © 2019 wq. All rights reserved.
//
#define  NullB id _Nullable
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface WXMResponse : NSObject
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) NSString *errorMsg;
@property (nonatomic, strong) id object;
+ (WXMResponse *)response:(int)errorCode errorMsg:(NSString *)errorMsg object:(id)object;
@end

@interface WXMComponentServiceHelp : NSObject
+ (id)serviceProvide:(Protocol *)protocol depend:(id)depend;
+ (id)serviceforPrivateKey:(NSString *)privateKey depend:(id)depend;
@end

NS_ASSUME_NONNULL_END
