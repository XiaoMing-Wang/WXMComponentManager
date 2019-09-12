//
//  WQCpmponentAnnotation.m
//  ModulesProject
//
//  Created by edz on 2019/4/25.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <objc/runtime.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/ldsyms.h>
#import "WXMComponentAnnotation.h"
#import "WXMComponentHeader.h"

/** 获取存储在WXMModuleClass里的字段集合 */
static NSArray<NSString *>* WQReadConfiguration(char *section) {
    NSMutableArray *configs = [NSMutableArray array];
    
    Dl_info info;
    dladdr(WQReadConfiguration, &info);
    
#ifndef __LP64__
    // const struct mach_header *mhp = _dyld_get_image_header(0); // both works as below line
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    // 找到之前存储的数据段(Module找BeehiveMods段 和 Service找BeehiveServices段)的一片内存
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", section, & size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, "__DATA", section, & size);
#endif /* defined(__LP64__) */
    
    // 把特殊段里面的数据都转换成字符串存入数组中
    for(int idx = 0; idx < size/sizeof(void*); ++idx){
        char *string = (char*)memory[idx];

        NSString *str = [NSString stringWithUTF8String:string];
        if (!str) continue;
        if(str) [configs addObject:str];
    }
    return configs;
}

@implementation WXMComponentAnnotation


/** 注册组件 */
+ (void)load {
    NSArray *array = WQReadConfiguration(WXMKitSerName);
    [array enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * dictionary = [self jsonToDictionary:obj];
        if (![dictionary isKindOfClass:NSDictionary.class]) return;
        
        NSString *protocol = dictionary.allKeys.firstObject;
        NSString *service = dictionary.allValues.firstObject;
        
        
        /** 注册组件 */
        [[WXMComponentManager sharedInstance] addService:service protocol:protocol];
    }];
}

/** json字符串转字典 */
+ (NSDictionary *)jsonToDictionary:(NSString *)string {
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) return nil;
    return [NSJSONSerialization JSONObjectWithData:jsonData
                                           options:NSJSONReadingMutableContainers
                                             error:nil];
}
@end
