//
//  WXMWeakDictionary.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//

#import "WXMWeakDictionary.h"

@interface WXMWeakDictionary ()
@property (nonatomic, strong) NSMapTable *weakDictionary;
@end

@implementation WXMWeakDictionary

- (instancetype)init {
    if (self = [super init]) {
        self.weakDictionary = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

- (void)addObject:(id)object forKey:(NSString *)key {
    if (object == nil || key == nil) return;

    if ([self.weakDictionary objectForKey:key] == nil) {
        [self.weakDictionary setObject:object forKey:key];
    } else {
        [self.weakDictionary removeObjectForKey:key];
        [self.weakDictionary setObject:object forKey:key];
    }
}

- (id)objectForKey:(NSString *)key {
    return [self.weakDictionary objectForKey:key];
}

@end
