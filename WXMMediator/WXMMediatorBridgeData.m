//
//  WXMMediatorData.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/24.
//  Copyright © 2019 wxm. All rights reserved.
//

#import "WXMMediatorBridgeData.h"

@implementation WXMMediatorListen @end
@implementation WXMMediatorSignal {
    WXMSignalCallBack _callback;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:WXMMEDIATOR_SIGNAL_CALLBACK] && value) {
        _callback = (WXMSignalCallBack)value;
    }
}

- (void)sendNext:(id)parameter {
    if (!_callback) return;
    void *blockPtr = (__bridge void *)(_callback);
    @synchronized(blockPtr) {
        _callback(parameter);
    };
}
@end
