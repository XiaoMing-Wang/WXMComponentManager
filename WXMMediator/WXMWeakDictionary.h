//
//  WXMWeakDictionary.h
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXMWeakDictionary : NSObject

/** 弱引用字典 */
- (void)addObject:(id)object forKey:(NSString *)key;

/** 获取 */
- (id)objectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
